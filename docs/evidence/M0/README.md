# M0 · 原生家园

- Git 基线 `devpack-v2.0` 指向 `f8d4727`，开发分支为 `codex/native-app`。
- Flutter 3.50.0，Dart 3.14.0，固定 Flutter revision 见 [version](flutter-version.json)。云端 Debian 13 x86_64，JDK 21，Gradle 9.5.0，AGP 9.3.1，Kotlin 2.4.20，SDK 36，NDK 28.2.13676358。Android minSdk 26，iOS deployment target 16.0。
- Flutter 静态分析与 18 套预览的 Widget 测试通过。家园使用 C 版空场景与角色独立图层。Android release 模式 APK 以云端开发证书签名。安装文件位于 `artifacts/M0/alice-m0.apk`，[摘要](SHA256SUMS)。
- Android 11 使用 x86_64 模拟器的软件加速。iPad 实机及 iOS 编译受 macOS、Xcode、设备与签名条件限制，状态 BLOCKED。文件互通探针随 M3 执行。

Android 11 模拟器在飞行模式下安装并打开了 `alice-m0`（`1dc9dfd`）。[390 × 844](android-390x844.png) · [360 × 800](android-360x800.png) · [834 × 1194](android-834x1194.png) · [1194 × 834](android-1194x834.png)。四个尺寸均为 Android 模拟器视口。截图中的树屋、木桥、溪水及第四阶段月牙耳兔使用 Demo 的原始 WebP 图层，构图见 [C 版参考](../../../design/references/garden-color.png)。发布 Demo 第 2 版的提交号与交接一致。网页域名经云端代理访问返回 HTTP 403，发布页面的同屏截图为 BLOCKED。阶段选择文字对比度在 M1 修正。
