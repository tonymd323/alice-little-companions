# 0.17.0+15 家庭功能版

2026-11-20。Android release 构建提交 `28da3a76621f8d13c00ff57f8cf7f426f26239ca`，Flutter 3.50.0，应用标识 `local.family.alice_companions`。APK 沿用 0.16 家庭版签名，支持 `arm64-v8a`、`armeabi-v7a` 和 `x86_64`。签名、16 KiB 对齐和包内离线资源已核对。从 GitHub 的 `2d3644c` 取回的 APK 具有相同长度和 SHA-256。[家庭 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.17.0-android.apk?raw=true) · [包摘要](package.json) · [包内美术](assets-daily.json) · [暖廊资源](assets-wind.json)

| 验收范围 | 实测结果 |
|---|---|
| 原家庭覆盖更新 | Android 9 x86_64 模拟器在飞行模式从 0.16.0+14 同签 `adb install -r`。安装身份不变，全部 26 张旧表的行摘要一致，SQLite 从 6 升到 7。旧家园仍选桃桃，保留完成的彩窗，冷启动再次读出相同数据。[升级回执](family-upgrade.json) · [冷启动画面](reopened-home.png) |
| 安装包内的新功能 | 在同一台模拟器摸桃桃，在成长页读到首次回忆。打开雨天地图，踩第一块后强停并重开，第一块保留勾记、第二块仍为下一步。存档余额、经验和流水条数均为零。[回忆页面](android-memory.png) · [重开后续玩](android-after-restart.png) · [测试摘要](android-features.json) |
| 家庭日常 | 自动回归覆盖建家、三宠、各阶段经验阈值、家长自定义与确认、扣分与撤销、纠错、固定家具、衣饰、兑换和预览零入账。纠错后相同命令重试返回原补记结果，另一条补记请求不重复记账。[完整日志](tests-final.log) |
| 主线与伙伴 | 独立试玩从正式家庭首页用五片叶修好暖廊的三扇彩窗，再进入雨天地图。第一段中途重开保留两块已踩石板，四段盖齐四印后可结束，近路试过八和十后用九块通关。成长手记保留两章回忆。试玩前后都是 3 分、1 经验、1 条原有流水。[独立试玩](independent-playtest.md) · [四印结局](four-stamps.png) · [九块近路](nine-stones.png) |
| 加密备份 | 37 分旧夹具验证完整恢复。另用两个测试存档执行加密往返，保留雨天地图当前轮次、已解锁结局、近路挑战和不同伙伴的回忆。取消生成、解密和恢复保护不改原存档或已有备份。上一份备份的回执也在模拟意外退出后保留。[完整日志](tests-final.log) · [换机说明](../../BACKUP_MIGRATION.md) |

## 复核方式

安装包可用 Android SDK `apksigner verify --verbose --print-certs` 与 `zipalign -c -P 16 4` 复核。完整回归使用提交 `7b2107a`，应用运行文件与 APK 的构建提交一致。可在 Flutter 工程目录运行下列命令。测试进程的等待上限用于共享云端，设备性能需另行计时。

```sh
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub --timeout=180s --concurrency=2 --reporter expanded
```

静态分析无问题，68 项自动回归通过。43 项历次逐项验收中有 32 项通过，11 项仍有真机等验收条件。[分析日志](analyze-final.log) · [自动回归](tests-final.log) · [逐项验收](../acceptance.csv) · [家长路线](../../OWNER_WALKTHROUGH.md) · [双端安装](../../DELIVERY.md) · [环境检查](preflight.json)

本章复用了 C 版现有庭院和暖廊。踩石板时用勾、下一块提示和分段站位反馈。独立试玩观察到雨水冲掉脚印主要由对白交代，同段的狐狸保持坐姿。日常移动的原画返工、实际孩子的体验和两端真机安装另有验收项。iPad 安装和飞行模式下的双向真机迁移、设备性能仍待 Mac、Apple Team、iPad 与安卓真机。[开发计划](../../PLAN.md)
