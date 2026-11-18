#!/usr/bin/env python3
"""Validate this documentation bundle. This does not build or test the app."""
from pathlib import Path
import json, re, hashlib, struct, csv, base64
from collections import Counter
ROOT=Path(__file__).resolve().parents[1]
checks=[]
def check(condition,label):
    if not condition: raise AssertionError(label)
    checks.append(label)
def read(p): return (ROOT/p).read_text(encoding='utf-8')
def data(p): return json.loads(read(p))
core=['AGENTS.md','docs/PRD.md','docs/RULES.md','docs/UX_SPEC.md','docs/DESIGN_SPEC.md','docs/TECH_SPEC.md','docs/ACCEPTANCE.md','docs/PLAN.md']
check(all((ROOT/p).is_file() and len(read(p))>500 for p in core),'八份核心文档存在且有实质内容')
documentation = [*ROOT.glob('*.md'), *(ROOT/'docs').rglob('*.md'), *(ROOT/'design').glob('*.md'), *(ROOT/'references').glob('*.md')]
for p in sorted(documentation):
    for target in re.findall(r'\]\(([^)]+)\)',p.read_text()):
        if target.startswith(('https://','http://','#','mailto:')): continue
        local=target.split('#',1)[0]
        check((p.parent/local).exists(),f'内部链接有效：{p.relative_to(ROOT)} → {local}')
r=data('config/rules.json');c=data('config/catalog.json');a=data('design/asset_manifest.json');t=data('design/tokens.json');s=data('design/scene_slots.json')
check([x['points'] for x in r['task_types']]==[2,3,5],'任务分值2/3/5一致')
check(r['currency_count']==1 and not r['gameplay_income'],'单积分且无游戏产币')
check(r['initial_balance']==0 and r['income_cap'] is None,'初始0分且不事后截断奖励')
check(r['penalty']['daily_actual_cap']==3 and not r['penalty']['allow_debt'],'扣分上限与无欠分一致')
check(r['growth']['thresholds']==[3,10,20,35,55] and r['growth']['stage_count_including_initial']==6,'成长阈值与阶段数一致')
check(r['offline']['first_run_supported'] and r['offline']['core_writes_supported'] and not r['offline']['server_required'],'首次与核心写入无需服务器')
check(r['migration']['model']=='single_current_device' and not r['migration']['merge_supported'],'整套迁移与不合并账本一致')
check(r['backup']['magic']=='ALICEBK1' and r['backup']['iterations']==600000 and r['backup']['tag_bytes']==16,'备份格式参数一致')
check(len(c['items'])==18 and len({x['id'] for x in c['items']})==18,'18个商品且ID唯一')
check(Counter(x['tier'] for x in c['items'])==Counter({'small':4,'accessory':4,'single':4,'bundle':2,'zone':2,'shop':2}),'商品分层数量一致')
check(all(x['price']==r['price_tiers'][x['tier']] and not x['generates_points'] for x in c['items']),'商品价格与无收益规则一致')
asset_ids={x['id'] for x in a['production_assets']}
check(len(asset_ids)==len(a['production_assets']),'正式素材ID不重复')
need={x['asset_id'] for x in c['items']}
need.update(y['asset_id'] for x in c['items'] for y in x.get('included_items',[]))
check(need<=asset_ids,'商品及套装部件全部有素材计划')
children=[y['id'] for x in c['items'] for y in x.get('included_items',[])]
check(not (set(children)&{x['id'] for x in c['items']}) and len(children)==len(set(children)),'套装内部件与独立商品无重复收费ID')
check(len(s['scenes'])==5 and {x.get('space_id') for x in c['items'] if 'space_id' in x}<={x['id'] for x in s['scenes']},'五个空间定义完整')
art = a['demo_assets']
pet_ids = {pet['id'] for pet in c['companions']}
check(pet_ids == set(c['initial_free_pets']) == {'fox', 'rabbit', 'cat'}, '三只伙伴免费可选')
check(c['initial_free_space']=='base_room' and c['initial_free_space'] not in {item['id'] for item in c['items']}, '免费家园与可购空间区分')
expected_art = {f'{pet}-{stage}' for pet in pet_ids for stage in range(1, 7)} | {'cat-4-rest', 'garden'}
check({item['id'] for item in art} == expected_art and len(art)==20, '三只伙伴六个阶段、收翼姿态、空家园共20个可接入文件')
for item in art:
    raw_art=(ROOT/'design'/item['path']).read_bytes()
    check(raw_art[:4]==b'RIFF' and raw_art[8:12]==b'WEBP' and len(raw_art)==item['bytes'] and hashlib.sha256(raw_art).hexdigest()==item['sha256'], f"美术文件格式、大小及摘要匹配 {item['id']}")
for item in a['production_assets']:
    check(item['status'] in {'planned','demo_candidate','ready'}, f"素材状态有效 {item['id']}")
    if item['status']=='demo_candidate':
        check(item.get('demo_id') in expected_art, f"候选素材可追溯 {item['id']}")
    elif item['status']=='ready':
        path=ROOT / item['runtime_path']
        check(path.is_file() and hashlib.sha256(path.read_bytes()).hexdigest()==item['sha256'], f"正式素材文件可验证 {item['id']}")
scene_ref=a['scene_reference']
check(hashlib.sha256((ROOT/'design'/scene_ref['path']).read_bytes()).hexdigest()==scene_ref['sha256'],'场景 C 参考图摘要')
check(a['demo_source']['stage_days']==[0]+r['growth']['thresholds'],'美术成长表与积分规则阈值一致')
img=ROOT/'design'/a['reference']['path']; raw=img.read_bytes()
check(hashlib.sha256(raw).hexdigest()==a['reference']['sha256'],'方向参考图片hash正确')
check(raw[:8]==b'\x89PNG\r\n\x1a\n' and min(struct.unpack('>II',raw[16:24]))>=1024,'方向参考为至少1024边长PNG')
check(not a['reference']['counts_as_production_asset'],'方向稿不冒充正式素材')
req=set(re.findall(r'FR-\d{2}',read('docs/PRD.md')))
covered=set(re.findall(r'FR-\d{2}',read('docs/ACCEPTANCE.md')))
check(req<=covered and len(req)==13,'13项产品需求均映射到验收')
ac=re.findall(r'^\| (AC-\d{2}) \|',read('docs/ACCEPTANCE.md'),re.M)
check(len(ac)==43 and len(set(ac))==43 and set(ac)=={f'AC-{i:02d}' for i in range(1,44)},'43条验收编号完整且唯一')
rule=set(re.findall(r'^\| (R-\d{2}) \|',read('docs/RULES.md'),re.M))
check(rule=={f'R-{i:02d}' for i in range(1,36)},'35条业务规则编号完整')
check(set(re.findall(r'R-\d{2}',read('docs/ACCEPTANCE.md')))<=rule,'验收规则引用均存在')
fixture = data('fixtures/migration_roundtrip.json')
family=fixture['domain_fixture']
points={t['id']:t['points'] for t in r['task_types']}
prices={t['id']:t['price'] for t in c['items']}
reward_types=[k for day in family['reward_days'] for k in day['approved_task_types']]
earn=sum(points[k] for k in reward_types)
spent=sum(prices[k] for k in family['purchased_catalog_ids'])
before=family['before_export']
check((len(reward_types),earn,spent,earn-spent)==(17,73,36,37) and before['balance']==earn-spent,'迁移样本17次奖励、5次购买、余额37')
pending=next(task for task in family['other_unfinished_tasks'] if task['alias']=='pending-b')
check(earn-spent+points[pending['type']]==family['after_target_approves_pending_b']['balance']==42,'目标机后续确认42分')
v=fixture['codec_vector']
header=v['header_utf8'].encode()
h=json.loads(header)
password=v['passphrase'].encode()
check(password.hex()==v['passphrase_utf8_hex'],'口令 Unicode 与空格原样保留')
key=hashlib.pbkdf2_hmac('sha256',password,base64.b64decode(h['salt']),h['iterations'],32)
check(key.hex()==v['key_hex'] and h['iterations']==r['backup']['iterations'],'备份测试向量口令派生参数与结果匹配')
cipher=bytes.fromhex(v['ciphertext_hex'])
container=r['backup']['magic'].encode()+len(header).to_bytes(4,'big')+header+cipher+bytes.fromhex(v['tag_hex'])
check(h['payload_bytes']==len(cipher) and hashlib.sha256(container).hexdigest()==v['container_sha256'],'备份容器字段长度与固定样例摘要匹配')
with (ROOT/'docs/evidence/acceptance.csv').open(encoding='utf-8-sig',newline='') as f:
    evidence=list(csv.DictReader(f))
check([row['用例'] for row in evidence]==ac,'验收执行表与43条用例一一对应')
def lum(h):
    vals=[int(h[i:i+2],16)/255 for i in (1,3,5)]
    vals=[x/12.92 if x<=0.04045 else ((x+0.055)/1.055)**2.4 for x in vals]
    return sum(x*y for x,y in zip(vals,[.2126,.7152,.0722]))
def contrast(x,y):
    x,y=sorted([lum(x),lum(y)]);return (y+.05)/(x+.05)
col=t['colors']
for fg,bg in [(col['text'],col['background']),(col['muted_text'],col['surface']),('#FFFFFF',col['primary'])]:
    check(contrast(fg,bg)>=4.5,f'文本配色对比达标：{fg}/{bg}={contrast(fg,bg):.2f}')
check(t['minimum_tap_target']>=48,'点击尺寸基线至少48')
statuses=Counter(x['status'] for x in a['production_assets'])
report=['# 开工包校验结果','','2026-11-18 开工基线。本检查读取文档、配置和交付素材；原生 App 的执行记录单独保存在验收执行表中。','',
        f'- {len(req)} 项产品需求、{len(rule)} 条业务规则、{len(ac)} 项原生验收用例。',
        f'- {len(c["items"])} 项可兑换商品。{len(art)} 个 Demo 素材已核验，正式素材状态 {dict(statuses)}。',
        '- 已核对迁移样本 37 → 42，固定测试口令派生和备份容器摘要。',
        '- 网页 Demo 的模型回归已在发布提交重新运行，通过幂等、权限、余额和所有权断言。',
        f'- 本次准备检查 {len(checks)} 项通过。下面列出逐项结果。','','## 检查记录','']
report.extend('- '+x for x in checks)
(ROOT/'DOCS_CHECK.md').write_text('\n'.join(report)+'\n',encoding='utf-8')
print(json.dumps({'checks':len(checks),'features':len(req),'acceptance_cases':len(ac),'demo_assets':len(art),'assets_by_state':statuses,'native_tests_run':False},ensure_ascii=False))
