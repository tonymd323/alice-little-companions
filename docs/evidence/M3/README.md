# M3 · 加密备份与恢复

源码标签 `alice-m3`。Android release 模式 0.4.0+4，云端开发证书签名。安装件 `artifacts/M3/alice-m3.apk`。[构建](android-build.log) · [SHA-256](SHA256SUMS)

[Dart 文件与事务测试](backup-tests.log) 和 [仓库 Node 参考向量](reference-vector.log)通过定长 ALICEBK1 容器校验。独立源/目标 SQLite 数据代验证 37 分、22 条流水、17 份成果、5 件物品、搭配、摆放和心愿。目标用新凭据激活，重新导入复用已恢复状态，确认一份待处理成果后余额 42 分；源仍是 37 分且只读。测试也覆盖错误口令、损坏、未知版本、越界 ZIP 目录、缺素材、内部副本无法创建、中断、数据代指针和 5 份轮换。Drift 日志中的多实例提示对应独立临时 SQLite 和一个 schema 内存库。

Schema 1 与 2 的快照保存在 `apps/mobile/drift_schemas`，v1 升级前产生 ALICECP1 内部恢复点。两台实体设备的文件选择器操作与 iPad ↔ Android 实机互换待设备环境。[分析](analyze.log)
