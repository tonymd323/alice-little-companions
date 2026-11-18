#!/usr/bin/env python3
"""Read-only host tool inventory. Excludes account, device and credential identifiers."""
import json
import platform
import shutil
import subprocess

def version(command):
    name = command[0]
    if not shutil.which(name):
        return {"status": "not_on_path"}
    try:
        result = subprocess.run(command, capture_output=True, text=True, timeout=30)
    except (OSError, subprocess.TimeoutExpired) as error:
        return {"status": "probe_failed", "error_type": type(error).__name__}
    lines = (result.stdout + "\n" + result.stderr).strip().splitlines()
    return {
        "status": "available" if result.returncode == 0 else "probe_failed",
        "version_output": next((line.strip() for line in lines if line.strip()), ""),
    }

def main():
    commands = [
        ["git", "--version"], ["flutter", "--version"], ["dart", "--version"],
        ["java", "-version"], ["adb", "version"], ["sdkmanager", "--version"],
        ["xcodebuild", "-version"],
    ]
    print(json.dumps({
        "host": platform.system(), "architecture": platform.machine(),
        "scope": "tools on PATH; devices, signing and building untested",
        "tools": {cmd[0]: version(cmd) for cmd in commands},
    }, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()
