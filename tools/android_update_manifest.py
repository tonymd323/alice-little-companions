#!/usr/bin/env python3
"""Write the private download branch's update record from a signed APK."""

import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path


APPLICATION_ID = 'local.family.alice_companions'
FAMILY_CERTIFICATE = 'c046191e27395fff3ea806f44b1e501cc7577d70acdbae7639f0061158200e05'


def manifest(apk: Path, build_tools: Path) -> dict:
    size = apk.stat().st_size
    if not 0 < size <= 100 * 1024 * 1024:
        raise ValueError('APK exceeds the GitHub update size limit')

    signing = subprocess.check_output(
        [build_tools / 'apksigner', 'verify', '--print-certs', apk], text=True
    )
    certificates = re.findall(r'certificate SHA-256 digest: (\w+)', signing)
    if certificates != [FAMILY_CERTIFICATE]:
        raise ValueError('Expected the single installed family signing certificate')

    badging = subprocess.check_output([build_tools / 'aapt2', 'dump', 'badging', apk], text=True)
    package = re.search(r"^package: name='([^']+)' versionCode='(\d+)' versionName='([^']+)'", badging, re.M)
    if package is None or package[1] != APPLICATION_ID:
        raise ValueError('APK uses a different application ID')
    build, version = int(package[2]), package[3]
    if not (0 < build <= 2100000000 and re.fullmatch(r'\d{1,5}\.\d{1,5}\.\d{1,5}', version)):
        raise ValueError('Invalid installable family version')

    with apk.open('rb') as content:
        checksum = hashlib.file_digest(content, 'sha256').hexdigest()
    return {
        'schema': 1,
        'version': version,
        'versionCode': build,
        'file': f'alice-{version}-android.apk',
        'sha256': checksum,
        'sizeBytes': size,
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('apk', type=Path)
    parser.add_argument('--build-tools', required=True, type=Path)
    args = parser.parse_args()
    try:
        print(json.dumps(manifest(args.apk, args.build_tools), indent=2))
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        parser.error(str(error))
