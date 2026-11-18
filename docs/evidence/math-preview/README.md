# 暖廊的彩窗

《小小伙伴》的二年级数学试玩是独立安卓应用，版本 0.1.0+1。解压 ZIP 后打开 APK，桌面点「暖廊的彩窗」。应用标识为 `local.family.alice_companions.windowmath`，书签保存在该应用自己的私有目录里。已通关的花纹可在重开后继续看。小样运行数学玩法，经验升级属于下一版家庭应用。[安装元数据与文件摘要](installation.json) · [最新成长规则](../../RULES.md)

孩子和桃桃给三扇窗做窗花，先按组计数，再推理还需补多少片。可以展开图文提示，也可以心算后直接选择。点亮彩窗后即到达基础结局。加一道可选挑战时，每格在三片与五片之间切换，用十九片金叶铺满五格。程序接受任意两格选五片的排法，完成时留下孩子所选的位置。[开场](opening.png) · [补齐窗花](missing.png) · [可选挑战](challenge.png) · [完成后的排列](finished.png)

## 验证

- Flutter 静态分析通过，完整回归 26 项通过，含 3 项样章用例。覆盖 360 × 800 且字体 130% 的手机和 1194 × 834 的横屏视口、答错重试、提示、跳出挑战、回放和书签。样章专项逐一点击十种可行排法，并核对保存的位置。损坏的小样书签会回到第一扇窗。[静态分析](analyze.log) · [完整回归](full-tests.log) · [样章专项](chapter-tests.log) · [样章测试源码](../../../apps/mobile/test/window_math_test.dart)
- Android 11 云端模拟器在飞行模式安装 release 版，走通基础结局和可选挑战，强行停止再启动，完成页与第一、第五格的五叶图案得到恢复。同机家庭应用的安装文件摘要保持为已验收的 0.10.0。[设备实测](android-flow.log)
- APK 包含 ARM64、32 位 ARM 和 x86_64，通过 APK 签名和 16 KiB 对齐检查。下载 ZIP 中的 APK 与安装到模拟器的文件逐字节一致。[构建日志](android-build.log) · [签名与摘要](installation.json)

## 复现

在标签 `alice-window-math-preview1` 的 `apps/mobile` 目录使用已锁定的 Flutter 3.50.0 与 Android 工具链。运行以下命令可测试并构建独立的数学样章。[样章入口](../../../apps/mobile/lib/main_window_math.dart) · [关卡与绘制](../../../apps/mobile/lib/features/window_math.dart)

```sh
flutter pub get --enforce-lockfile
flutter test --no-pub
flutter build apk --release --target lib/main_window_math.dart --build-name 0.1.0 --build-number 1
```
