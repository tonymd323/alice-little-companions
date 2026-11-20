# 家庭版 0.19.0+17 备份性能

构建源码 `c55dbd1605215c78cb13101a273bfa53ace01819`。校验存档时先汇总与成果对应的流水键，再逐笔核对奖励流水。回归用例在合法存档中额外写入一笔无对应成果的奖励并同步余额，校验仍拒绝该存档。加密备份沿用 ALICEBK1 格式和口令参数。[备份规范](../../BACKUP_FORMAT.md) · [回归源码](../../../apps/mobile/test/backup_test.dart)

## 49.84 MiB 加密备份

2026-11-20，Debian 13 x86_64，4 核容器，Flutter 3.50.0 / Dart 3.14.0 调试 JIT、SQLite 3.54.1。计时期间关闭安卓软件模拟器。三次使用相同构造方式的合成家庭，每份 52,256,768 字节、6,871 条流水、6,866 项有效成果。各次使用独立生成的家庭标识。

| 云端步骤 | 0.18.0+16 | 0.19.0+17 第一次 | 0.19.0+17 第二次 |
|---|---:|---:|---:|
| 导出（含加密回读） | 21.131 秒 | 18.415 秒 | 18.486 秒 |
| 其中源快照校验 | 2.756 秒 | 1.311 秒 | 1.347 秒 |
| 本地复制与交接回执 | 0.115 秒 | 0.055 秒 | 0.058 秒 |
| 恢复（含预览、保护目标原档和激活） | 19.414 秒 | 13.968 秒 | 13.963 秒 |

每次分别对比源存档、预览和激活后的业务 SHA-256，三者一致。目标切换了存储代，源存档积分保留。两台实体机仍需用 release 安装包计时，并走系统文件选择、取消和双向迁移。[原始计时](timing.log) · [合成夹具与复测方式](../family-offline/backup-timing.md#复测)

## 安卓覆盖与签发

76 项 Flutter 回归通过，包括 37 分存档往返、取消恢复、旧档升级和预览零入账。静态分析与 ALICEBK1 参考密文校验通过。[测试记录](tests.log) · [工具链](preflight.json)

在 Android 9 x86_64 模拟器开启飞行模式，用 `adb install --no-streaming -r` 从 0.18.0+16 覆盖至 0.19.0+17。打开测试家园，再停止 App 并冷启动，两次均保留同一存储代。28 张业务表的摘要一致，彩窗和暖廊进度保留。[升级前后摘要](android-upgrade.json) · [冷启动后家园](android-home.png)

APK 沿用原家庭签名并通过 16 KiB 对齐检查。APK 和版本记录同批发布到私有 `android-downloads`，用独立 Git 副本取回，两份文件逐字节一致。[家庭 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.19.0-android.apk?raw=true) · [APK 签名与摘要](package.json) · [远端取回回执](github-download.json) · [家园素材](art-daily.json) · [暖廊素材](art-wind.json)
