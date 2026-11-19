"""Build a separate probe APK using the shipping Flutter channel, Activity and WAVs."""
from argparse import ArgumentParser
from pathlib import Path
import shutil
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
MOBILE = ROOT / "apps/mobile"
PROBE_ID = "local.family.verandafoleyprobe"


def main():
    parser = ArgumentParser(description=__doc__)
    parser.add_argument("--target", default="android-x64", choices=["android-x64", "android-arm64"])
    args = parser.parse_args()
    target = Path(tempfile.mkdtemp(prefix="veranda-foley-probe-"))
    print(f"Building in {target}", flush=True)

    # Only tracked scaffold files are used, excluding developer-specific signing and SDK files.
    paths = subprocess.check_output(
        ["git", "ls-files", "apps/mobile/android"], cwd=ROOT, text=True
    ).splitlines()
    for path in paths:
        source = ROOT / path
        dest = target / source.relative_to(MOBILE)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, dest)
    gradle = target / "android/app/build.gradle.kts"
    lines = gradle.read_text().splitlines()
    application_id = [i for i, line in enumerate(lines) if line.lstrip().startswith("applicationId = ")]
    if len(application_id) != 1:
        raise RuntimeError("Check the app Android ID declaration before building this probe")
    lines[application_id[0]] = f'        applicationId = "{PROBE_ID}"'
    gradle.write_text("\n".join(lines) + "\n")

    (target / "lib/illustration").mkdir(parents=True)
    shutil.copy2(MOBILE / "lib/illustration/wind_sound.dart", target / "lib/illustration")
    shutil.copy2(HERE / "main.dart", target / "lib/main.dart")
    shutil.copytree(MOBILE / "assets/wind/audio", target / "assets/wind/audio")
    (target / "pubspec.yaml").write_text("""name: wind_sound_probe
version: 1.0.0+1
environment:
  sdk: ^3.14.0
dependencies:
  flutter:
    sdk: flutter
flutter:
  assets:
    - assets/wind/audio/
""")
    subprocess.run(["flutter", "pub", "get", "--offline"], cwd=target, check=True)
    subprocess.run(["flutter", "build", "apk", "--release", "--target-platform", args.target,
                    "--no-pub"], cwd=target, check=True)
    print(target / "build/app/outputs/flutter-apk/app-release.apk")


if __name__ == "__main__":
    main()
