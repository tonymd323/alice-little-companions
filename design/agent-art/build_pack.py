"""Assemble self-contained art briefs with the exact project references they use."""

import argparse
import csv
import hashlib
import io
import json
import os
import re
import subprocess
import tempfile
import zipfile
from graphlib import TopologicalSorter
from pathlib import Path, PurePosixPath


HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
DOCUMENTS = ('README.md', 'PROMPTS.md', 'ACCEPTANCE.md', 'jobs.csv',
             'references.csv', 'build_pack.py')
KINDS = ('场景', '互动道具', '家具', '服装', '配饰', '物种设定', '六阶段进化', '动作')
REVIEW_STAGES = ('概念与身份', '制作与合成', '游戏内验证', '家长终验')
REVIEW_COLUMNS = ('工单', '资产ID', '名称', '回件版本', '参考或上游版本', '实测阶段与搭配',
                  *REVIEW_STAGES, '证据文件和帧号',
                  '实见与预期', '返修部位', '复测结果', '评审者')


def rows(name):
    with (HERE / name).open(encoding='utf-8-sig', newline='') as source:
        return list(csv.DictReader(source))


def indexed(records, key):
    result = {}
    for row in records:
        value = row[key]
        if not value or value in result:
            raise ValueError(f'Missing or repeated {key}: {value!r}')
        result[value] = row
    return result


def identifiers(value):
    return [part.strip() for part in value.split('|') if part.strip()]


def safe_relative(value):
    path = PurePosixPath(value)
    if not path.parts or path.is_absolute() or '..' in path.parts or '\\' in value:
        raise ValueError(f'Expected a relative file path: {value!r}')
    return path


def sections():
    source = (HERE / 'PROMPTS.md').read_text(encoding='utf-8')
    parts = re.split(r'^## (.+)$', source, flags=re.MULTILINE)
    return {key.strip(): body.strip() for key, body in zip(parts[1::2], parts[2::2])}


def validate(jobs, refs, prompts):
    indexed(refs.values(), 'file')
    indexed(jobs.values(), 'asset_id')
    graph = TopologicalSorter()
    for job in jobs.values():
        if not re.fullmatch(r'[A-Z]+-\d+', job['id']) or job['kind'] not in KINDS:
            raise ValueError(f'Invalid job identifier or kind: {job["id"]}')
        if any(not job.get(field, '').strip() for field in
               ('asset_id', 'title', 'refs', 'scope', 'canvas', 'brief', 'outputs', 'check')):
            raise ValueError(f'Incomplete brief: {job["id"]}')
        if job['kind'] not in prompts:
            raise ValueError(f'Missing prompt for {job["kind"]}')
        parents = identifiers(job['depends_on'])
        if set(parents) - jobs.keys() or set(identifiers(job['refs'])) - refs.keys():
            raise ValueError(f'Unknown dependency or reference: {job["id"]}')
        graph.add(job['id'], *parents)
    graph.prepare()


def brief(job, jobs, refs, prompts):
    parents = [f'{code} {jobs[code]["title"]}' for code in identifiers(job['depends_on'])]
    upstream = ('请随单附上已通过内部复核的上游母稿和版本号。上游工单为 ' + '、'.join(parents)
                if parents else '可直接从包内参考开始。')
    references = [f'- {key}　refs/{refs[key]["file"]}　{refs[key]["use"]}'
                  for key in identifiers(job['refs'])]
    parts = [f'银杏家园 · {job["id"]} · {job["title"]}',
             f'资产前缀　{job["asset_id"]}\n交件目录　returns/{job["id"]}/r01/',
             job['scope'], '本单主参考在前\n' + '\n'.join(references), upstream,
             '画布和机位\n' + job['canvas'], '请画出\n' + job['brief'],
             '本单应交\n' + job['outputs'], '单项复核\n' + job['check'],
             prompts['通用绘制'], prompts[job['kind']]]
    if job['kind'] == '六阶段进化':
        parts.append('原有三宠的设定对照\n' + prompts['三宠阶段对照'])
    return '\n\n'.join(parts) + '\n'


def gather_reference(ref, previous):
    name = 'refs/' + str(safe_relative(ref['file']))
    source_name = safe_relative(ref['source'])
    if (HERE / 'refs').is_dir():
        data = (HERE / name).read_bytes()
        old = previous.get(ref['id'], {})
        source_hash = old.get('source_sha256') if (
            old.get('source') == str(source_name) and
            old.get('sha256') == hashlib.sha256(data).hexdigest()) else None
    else:
        source = REPO / source_name
        original = source.read_bytes()
        source_hash = hashlib.sha256(original).hexdigest()
        if source.suffix.lower() == '.webp' and name.lower().endswith('.png'):
            from PIL import Image

            with Image.open(io.BytesIO(original)) as painting:
                output = io.BytesIO()
                painting.save(output, format='PNG')
                data = output.getvalue()
        else:
            data = original
    receipt = {**ref, 'file': name, 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest(),
               'source_sha256': source_hash}
    return name, data, receipt


def pack(target):
    jobs = indexed(rows('jobs.csv'), 'id')
    refs = indexed(rows('references.csv'), 'id')
    prompts = sections()
    validate(jobs, refs, prompts)
    if (HERE / 'reference-index.json').is_file():
        previous = json.loads((HERE / 'reference-index.json').read_text(encoding='utf-8'))
        revision = previous['reference_checkout']
        old = indexed(previous['references'], 'id')
    else:
        revision = subprocess.check_output(['git', '-C', str(REPO), 'rev-parse', 'HEAD'], text=True).strip()
        old = {}
    target.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=target.parent) as work:
        candidate = Path(work) / 'batch.zip'
        with zipfile.ZipFile(candidate, 'w', compression=zipfile.ZIP_DEFLATED) as archive:
            for document in DOCUMENTS:
                archive.write(HERE / document, document)
            for section, filename in [('制单与分派', 'plan'), ('独立评审', 'review'), ('定向返修', 'revise')]:
                archive.writestr(f'roles/{filename}.txt', prompts[section] + '\n')
            reports = io.StringIO(newline='')
            writer = csv.DictWriter(reports, fieldnames=REVIEW_COLUMNS, lineterminator='\n')
            writer.writeheader()
            for job in jobs.values():
                archive.writestr(f'jobs/{job["id"]}.txt', brief(job, jobs, refs, prompts))
                writer.writerow({'工单': job['id'], '资产ID': job['asset_id'], '名称': job['title'],
                                 **{stage: 'NOT_RUN' for stage in REVIEW_STAGES}})
            archive.writestr('review-log.csv', reports.getvalue().encode('utf-8-sig'))
            receipts = []
            for ref in refs.values():
                name, data, receipt = gather_reference(ref, old)
                archive.writestr(name, data, compress_type=zipfile.ZIP_STORED)
                receipts.append(receipt)
            index = {'reference_checkout': revision, 'references': receipts}
            archive.writestr('reference-index.json', json.dumps(index, ensure_ascii=False, indent=2) + '\n')
        os.replace(candidate, target)
    print(f'{target}: {len(jobs)} jobs, {len(refs)} references')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    pack(parser.parse_args().output)
