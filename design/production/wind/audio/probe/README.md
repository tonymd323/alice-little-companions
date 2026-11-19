# Android 原生声音探针

探针使用同一份 Dart 通道、Android Activity 和七个 WAV。它以 `local.family.verandafoleyprobe` 安装，适用于和家庭版隔离的测试模拟器。先从仓库根目录构建，终端最后一行是临时 APK 的绝对路径。

```sh
python3 design/production/wind/audio/probe/build.py
```

将 APK 安装在测试模拟器后，每个用例强制停止探针，再以 Flutter 初始路由启动。以下命令以端口 5556 为例。

```sh
adb -s emulator-5556 install -r /tmp/veranda-foley-probe-XXXXXXXX/build/app/outputs/flutter-apk/app-release.apk
adb -s emulator-5556 shell am force-stop local.family.verandafoleyprobe
adb -s emulator-5556 shell am start -n local.family.verandafoleyprobe/local.family.alice_companions.MainActivity --es route /line
adb -s emulator-5556 logcat -s flutter:I
```

| 两次启动之间的路由 | 期待观察 |
|---|---|
| `/unmute` 接 `/line` | 第二次启动读出 `initialMuted=false`。从窗风到桥上脚步的七种事件依次请求播放。|
| `/mute` 接 `/raw` | 第二次启动读出 `initialMuted=true`。探针直接向 Android 请求播放风声，已静音的数字回放应为静音。|
| `/unmute` 接 `/stop` | 一次 2.55 秒的风声在调用后约 0.45 秒截止。|
| `/unmute` 接 `/raw` | 同一条原生请求在取消静音后播放风声，可作静音回读的阳性对照。|

日志标记以 `FOLEY_PROBE` 开头。它们用于定位发出事件的时刻，扬声器听感和数字音频回放各自记录。真机替换目标架构时，构建命令可加 `--target android-arm64`。
