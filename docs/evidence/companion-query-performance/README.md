# 0.21.1 伙伴经验查询

家庭版 **0.21.1+20** 使用原安卓签名，构建源码为 `772db06b8df394332a8aee1297ec05658ed5e66a`。[APK 与签名摘要](package.json) · [构建检查](build.log)

原私有下载分支在同一提交中提供 APK、更新清单和 SHA-256 清单。用独立 Git 副本重新取回 APK 和更新清单，逐字节核对通过。[下载家庭 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.21.1-android.apk?raw=true) · [发布回执](github-download.json)

查询源码提交为 `4d084d5e959f33d9b05a20d85ee05d78150a3023`。每笔经验关联一条成果。查询利用 SQLite 结构 8 中已有的成果有效性索引和归属索引，读取有效与已更正成果中较少的一组，按伙伴计算经验。[实现](../../../apps/mobile/lib/application/companion_progress.dart) · [纠错回归](../../../apps/mobile/test/companion_unlock_test.dart)

10,706 条流水的原合成档共有 10,698 条成果，其中 1 条已更正。相同数据上的 SQLite 查询 p95 从 9.624 毫秒降至 1.577 毫秒。将约一半或全部成果设为已更正后，逐次比对新旧查询的经验值，结果一致。这两组对照在独立测试事务中执行并回滚。[查询计划与原始计时](timing.log)

| Linux Flutter 调试环境 | 已发布 0.21 两轮 | 查询修订两轮 |
|---|---:|---:|
| 点击确认至反馈 p95 | 406.3 / 307.4 毫秒 | 278.2 / 244.2 毫秒 |
| 其中数据刷新 p95 | 72.4 / 48.1 毫秒 | 42.8 / 45.4 毫秒 |
| 重开至家园首帧最慢 | 1.542 / 1.356 秒 | 1.239 / 1.107 秒 |

两轮修订版各确认 20 件小事。每次确认加 2 分和 1 经验，结束时余额 32,117 分，桃桃有 10,717 经验，账本有 10,726 条流水。一轮云端 p95 高于 250 毫秒，AC-39 的正式包耗时待双端真机测量。[原发布版计时](../companion-unlock/task-performance.log) · [真机验收](../device-acceptance/README.md#计时)

按现有复测步骤下载合成档，检出 `772db06`，使用 `ALICE_UI_PROBE_UPGRADE_SCHEMA=8` 运行同一份 Flutter 探针。[复测步骤](../task-performance/README.md#复测)

静态分析、加密参考向量和 80 项 Flutter 回归均通过。新增用例覆盖唯一成果被更正、有效经验回到 0 的情况，原有双伙伴经验、旧档、扣分纠错和备份迁移用例同轮执行。[检查日志](checks.log)

## 安卓覆盖安装

在 Android 9 x86_64 软件模拟器的飞行模式下，用系统文件选择器在原签名 0.21.0 恢复结构 8 的合成家庭，用测试输入法设置新的本机凭据。家园有两个已拥有伙伴、5 分、一件待确认小事、衣饰、家具与雨天地图进度。[升级前的小家](before-update.png)

使用 `adb install --no-streaming -r` 同签覆盖到 0.21.1+20。冷启动后原应用 UID、首次安装时间、活动存储代及 30 张业务表的摘要一致。奶油仍为 3 级、16 经验，团团仍为 1 级、0 经验，家园余额为 5 分。[升级后的小家](after-update.png) · [数据库与安装摘要](android-upgrade.json)

在伙伴页切换到已解锁的团团，并在家长入口确认待办。重开后余额 7 分，团团有 1 经验，奶油有 16 经验，原家具、穿戴、回忆和雨天地图进度均保留。[升级后伙伴](partners-after-update.png) · [确认反馈](approval-after-update.png) · [重开后的团团](restart-with-independent-experience.png)
