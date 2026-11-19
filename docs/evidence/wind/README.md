# 风过暖廊 · 0.14.0+11

从原来的「小小伙伴」打开 **小家 → 主线 · 风过暖廊**。故事里的桃桃处于第三阶段，家里的伙伴、穿戴和共享经验由原存档决定。修窗、重玩、观看和试戴都不会产生积分、经验或新物品。

[56 秒完整试玩，含动作声](capture/wind-veranda.mp4) · [两种修窗顺序对照](capture/wind-contact-sheet.jpg) · [取帧方法与原始操作记录](capture/README.md)

## 一次试玩可以看什么

| 玩家操作 | 看画面中的哪一处 |
|---|---|
| 让开场自然演完 | 一片叶子从窗边落下，桃桃转耳、用爪压围巾、俯身推篮、松爪，再朝 Alice 招手。 |
| 从篮里拿一片，补中窗右下角 | 中间的彩玻璃合拢，对应木板和桥面受光，奶油可以走到下一段桥的缺口。 |
| 在另一轮先把四片都给远窗 | 远处的窗与地面先亮。奶油抬眼望向远处，仍在原来的断口等，直到玩家补好中窗。 |
| 补完五处，看完团聚并回小家 | 奶油跑到暖廊，桃桃招手。日常暖廊的窗、靠垫后方及木板上都有新的光影，已购家具位于近景。 |
| 中途离开，或通关后「再演一次」 | 每次嵌叶立即保存。重演会重新摆出七片已有的玻璃，日常暖廊仍保留结局。旧版书签在「章节选项」，通关后可玩「十九片叶子」。 |

右上角喇叭可静音，在同一设备重开也会记住。右上角「章节选项」可收起对白。此章采用逐姿绘画和局部形变，动作音来自七种离线拟音。[角色分层与动作预演](../../../design/production/wind/actors/README.md) · [场景原稿与四种窗光](../../../design/production/wind/room/README.md) · [围巾的六幅家庭穿戴成画](wardrobe.jpg) · [声音来源与试听](../../../design/production/wind/audio/README.md)

同一机位的四张静帧分别取自桃桃刚探爪、双爪贴到篮沿、后腿蹬伸以及迎到奶油的时刻。它们来自 Flutter 绘制的角色与场景。[推篮与迎接的接触帧](paw-contact.jpg) · [奶油等待、望远、跑动和进门](bridge-contact.jpg)

## 家庭数据

0.14 使用 SQLite 结构 6。家庭存档内记录具体哪一格修好、本轮编号、首次通关与旧数学书签。0.13 加密文件可直接恢复到新版本。家庭原有的账本、经验和物品照常使用。[备份步骤](../../BACKUP_MIGRATION.md) · [家庭安装说明](../../DELIVERY.md)

## Android 构建核对

候选 APK 为 0.14.0+11，80,517,060 字节。SHA-256 为 `493b3939daddef425f941a545d01569f435589640651eb419f3d3cffcc14a623`。家庭版包名为 `local.family.alice_companions`，签名证书和 0.13 相同。Android Build Tools 36 已验证签名、16 KB 对齐、Android 8+ 和三种 CPU 架构。[签名与构建信息](installation.json) · [构建日志](build.log) · [静态分析](analyze.log)

将 APK 解包并逐文件对照本标签的 25 张角色及道具图、18 张场景图、6 张围巾穿戴成画、7 个 PCM 音效和 2 份坐标数据。另核对原家庭版的 193 个素材编号。[新增素材核查](packaged-art.json) · [家庭素材核查](family-art.json) · [舞台及连续帧检查](stage-frames.log)

48 项 Flutter 自动测试全部通过，覆盖旧家庭与加密恢复、两种补窗顺序、快速连点、最后一片的声音时序、减少动态效果和试穿零入账。已从 GitHub 的全新检出取回安装文件，大小和字节与签名构建一致。[全量测试](flutter-tests.log) · [GitHub 取回校验](github-download.json)

在仓库根目录可运行 `python3 tools/check_wind_release.py /path/to/family.apk`，在 `apps/mobile` 运行 `flutter test --no-pub --reporter expanded`。iPad 签名、双向真机迁移与实体设备性能仍需可用的 Mac、Apple Team、iPad 和安卓手机。[设备交接](../../DELIVERY.md)
