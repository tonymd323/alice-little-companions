# M5 · 云端交付候选

源码标签 `alice-rc1`，Git 提交 `f870931122b6ec4104ee0138a570ec113f85e2d5`。版本 0.9.0+6。构建环境为 Debian 13 x86_64、Flutter 3.50.0、Dart 3.14.0、JDK 21、Gradle 9.5.0、Android SDK 36。安装件为 `artifacts/M5/alice-0.9.0-android.apk`，使用云端开发签名。[APK 摘要](APK-SHA256SUMS) · [构建日志](android-build.log) · [签名](android-signature.txt) · [安装包元数据](android-metadata.txt) · [权限](android-permissions.txt)

- [干净检出的锁文件复现](locked-deps.log)、[静态分析](analyze.log)与[完整自动化回归](tests.log)保留原检查结果，包含真实 SQLite 数据代、备份认证、设备冻结及视觉测试。签名 APK 经 `apksigner verify` 和 `zipalign -c -P 16` 核对，最低 Android API 26。
- [构图对照](scene-comparison.png)左侧以交接包 Demo 原始 WebP 和第四阶段月牙耳兔的机位参数重组，右侧裁切自 Android 390 × 844 原生截图。核对同一棵树、木桥、溪流和落脚点。云代理对发布域名返回 403，发布站点的直接截图仍为 BLOCKED。
- Android 11 模拟器和 Linux Flutter 测试提供云端证据。iPad 签名安装、Android 真机升级、两端真机文件互换、实际高像素密度检查以及真机性能仍需设备接入。[Linux 上的 iOS 构建探测](ios-build.log) · [iOS 工程静态核查](ios-project-check.log) · [逐项状态](../acceptance.csv)

Android 11 模拟器在飞行模式下以同签名安装 0.9.0+6，保留小花瓶和 2 分余额。取消一次系统文件选择后，经系统本地存储重新选择 M3 的加密备份。家长重新解锁，核对当前 2 分与待恢复 3 分，建立内部恢复点并确认替换，设置新凭据。恢复后省略已回退时间点的小花瓶，冷启动仍为 3 分。[候选安装后](android-candidate.png) · [文件面板返回后的锁定](android-import-relock.png) · [恢复比较](android-restore-comparison.png) · [恢复后的家园](android-restored-home.png) · [设备日志](android-device-flow.log)
