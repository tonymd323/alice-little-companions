# 银杏家园手绘互动体验版

Android 0.10.0+7 对应源码标签 `alice-illustrated-rc2` 和提交 `302a0727de753f29911e154f36d9c4f88c1c29dd`。APK 使用与 0.9.0 相同的云端开发证书和 applicationId，最低 Android 8。ARM64 ZIP 适合 64 位 ARM 手机，通用 ZIP 还含 32 位 ARM 与 x86_64。解压后点 APK 覆盖安装。[包大小、证书与摘要](installation-files.json) · [SHA-256](SHA256SUMS)

## 手机上可以体验什么

- 在银杏庭院里点伙伴，轻划它的头部，或点可行走的空地。银杏狐摆尾，月牙耳兔动耳轻跳，幼年云翼猫摇尾，长出云翼后会舒展翅膀。待机时胸口轻动、眼睛眨动。动作在 Flutter 原生绘图层对透明原画做局部网格变形。三宠并排短片使用安装版相同的绘制代码，按 24 帧每秒离屏取样，适合看各自的动作细节。[三宠动作对照](companions-motion.mp4) · [Android 安装版操作录屏](android-interaction.mp4)
- 点暖廊可以进屋，窗外仍能看见院中的树、溪和桥。点布置后，家具按原存档的空间、位置和层级读取，脚边投影随物体落脚，地毯依地板透视绘制。已有基础布置的家庭重启时先打开暖廊。[C 版原画与安装版对照](home-comparison.jpg) · [庭院](courtyard-2x.png) · [暖廊](veranda-2x.png) · [布置](layout.png) · [冷启动](reopened.png)
- 三宠六阶段和云翼猫第四阶段的收翼姿态均按原设定重绘，六件常用家具和装饰也更新为带柔和透明边缘的手绘素材。旧初始兔为 156 × 141 像素、2 档透明度，新图为 450 × 408 像素、248 档透明度。25 个文件的尺寸、透明区域、过渡像素与已登记 SHA-256 均已核验。[深浅底边缘对照](edges.png) · [逐文件结果](alpha.json) · [复验脚本](../../../tools/check_illustrated_art.py)

## 本轮实测

| 环境 | 结果 | 证据 |
|---|---|---|
| Flutter 3.50.0、Dart 3.14 | 静态分析通过，23 项测试通过。覆盖原有授权、扣分、纠错、兑换、文件迁移与损坏恢复。新增或扩展触摸、抚摸、暂停动效、减少动态效果、跨画幅坐标和零入账验证 | [分析](analyze.log) · [完整测试](tests.log) |
| 390 × 844 及其他三个参考视口 | 130% 字体下三宠六阶段可操作。已有 3 分的家庭切换暖廊、点宠和预览全部外观后，流水仍为一笔 3 分，余额、命令计数、真实伙伴与成长日和进入前相同 | [SQLite 核对用例](../../../apps/mobile/test/delivery_test.dart) · [姿态与布置用例](../../../apps/mobile/test/illustration_test.dart) |
| Android 11 x86_64 模拟器，飞行模式 | 旧家庭覆盖打开后的余额为 3 分。小床与编织毯保存后强行停止进程，再次打开，两件物品仍在暖廊。开启系统减少动态效果后，触摸有文字回应。高密度截图为 780 × 1688、320 dpi，横屏截图取自同一模拟器 | [设备日志](android-flow.log) · [减少动态效果](reduced-motion.png) · [横屏界面](tablet-landscape.png) |
| 两种 APK | 通过签名及 16 KiB 对齐检查，ZIP 解压后 APK 逐字节一致。独立干净检出的 ARM64 版与通用版的 ARM64 机器指令段 SHA-256 相同，所有画面资源相同。原生 SQLite 库清单按所含架构生成 | [ARM64 对照](abi-parity.json) · [通用包构建](build.log) · [干净检出的 ARM64 构建](arm64-clean-build.log) · [锁文件复现](locked-deps.log) |

安装版操作录屏由 Android 系统直接录制，片长 20.7 秒，云端软件模拟器共采集到 27 帧。三宠动作对照另有 90 帧，可逐帧看耳朵、尾巴和云翼的变化。验收表中的实体机性能、iPad 签名和双向真机迁移需接入设备后测量。当前需要可运行匹配 Xcode 的 Mac、可用 Apple Team、一台 iPad 和一台 Android 手机。[视频参数](video.json) · [已安装 APK 摘要](install.log) · [构建环境](preflight.json) · [43 项验收记录](../acceptance.csv) · [备份换机说明](../../BACKUP_MIGRATION.md)
