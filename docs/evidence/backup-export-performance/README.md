# 0.21.2 大存档导出

候选版为 **0.21.2+21**，构建源码 `ae09472607a72dcc1bad1ab6574cd4ef337f6873`。导出仍检查 SQLite 完整性、外键、余额、成果、所有权和素材。新生成的加密包从磁盘回读，验证 AES-GCM 认证、ZIP 结构和快照 SHA-256。回读边解压边计算摘要，省去一份临时 SQLite 文件。恢复和激活仍核对逐表业务摘要。[导出流程](../../../apps/mobile/lib/application/transfer.dart) · [备份格式](../../BACKUP_FORMAT.md)

在 Linux x86_64 上用 Flutter 3.50.0、SQLite 3.54.1 和同一份合成家园计时。关闭安卓软件模拟器。合成档升级后快照为 54,800,384 字节，含 10,706 条流水。[合成档回执](../device-acceptance/github-fixture.json) · [分段计时](timing.log)

| 应用服务步骤 | 0.21.1 两轮 | 0.21.2 两轮 |
|---|---:|---:|
| 导出和内部回读 | 18.087 / 18.209 秒 | 15.606 / 15.004 秒 |
| 其中源快照校验 | 1.642 / 1.701 秒 | 0.200 / 0.291 秒 |
| 其中内部回读与收尾 | 8.479 / 8.432 秒 | 7.146 / 6.582 秒 |
| 恢复与激活，含保护目标原档 | 15.316 / 14.813 秒 | 14.678 / 13.979 秒 |

每次用临时测试家庭执行导出和恢复。恢复后的全量业务摘要与源快照相同，余额为 32,077 分，桃桃有 10,697 经验。两端真机的 20 秒指标继续按 AC-40 计时。[逐项验收](../acceptance.csv) · [设备计时](../device-acceptance/README.md#计时)

80 项 Flutter 回归、静态分析和 ALICEBK1 参考向量通过。新增断言验证导出仍拒绝缺少对应成果的奖励流水，内部回读仍拒绝与实际解压内容不符的摘要。大档专项分别在迁移加密、内部回读、恢复解密和建立恢复点时取消。重开后存储代和完整业务摘要一致，已有备份和恢复点可用。[回归记录](tests.log) · [取消过程](timing.log) · [备份断言](../../../apps/mobile/test/backup_test.dart)

安卓原签名 APK 通过 16 KiB 对齐和素材核对。在 Android 9 x86_64 软件模拟器飞行模式下，从 0.21.1 同签覆盖并冷启动，应用身份、活动存储代和 30 张业务表摘要一致。测试家庭保留 5 分、奶油 16 经验、团团 0 经验，以及窗花、雨天地图和衣饰。[安装包校验](package.json) · [构建日志](build.log) · [覆盖摘要](android-upgrade.json) · [覆盖后的家园](after-update-home.png)

从家长入口导出普通备份，在 Android 系统 Downloads 保存，再用 App 重新选中文件回读。冷启动后核对已验证回执、原存储代及完整业务摘要。用 0.21.1 的读取服务解密同一文件，核对 5 分、两位伙伴和 16 件有效成果。[App 回读](verified-existing-backup.png) · [备份与重启摘要](android-backup.json) · [旧版读取结果](tests.log)

APK、`latest.json` 和 SHA-256 清单在私有下载分支同批发布。用独立 Git 副本重新取回安装包和更新清单，两份文件均与原构建逐字节一致。[下载家庭 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.21.2-android.apk?raw=true) · [发布回执](github-download.json)

复测使用已发布的合成档。按旧版复测说明提取文件，分别在 `772db06` 和 `ae09472` 的 `apps/mobile` 下将计时探针复制到 `test`，设置 `ALICE_QA_INPUT_FILE` 为合成档路径，运行 `flutter test --no-pub --concurrency=1 --reporter expanded test/backup_50m_benchmark_test.dart`。[取合成档](../backup-cancellation-0211/README.md#复测) · [计时探针](../family-offline/backup_50m_benchmark_test.dart)
