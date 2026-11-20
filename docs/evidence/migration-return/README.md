# 0.20 原机回迁与万条档备份

家庭版 `0.20.0+18`，构建源码 `0b3aa4d8b6a2de22be99bd35666a9b7e66ffbf6a`。云端补测用独立的存档目录和家长凭据模拟两台设备。换机使用正式的加密导出、回读和恢复流程。[家庭使用说明](../../BACKUP_MIGRATION.md) · [双端真机验收](../device-acceptance/README.md)

## 归档后回迁

原机以 5 分、10 经验、第三阶段迁出，回读加密文件后将它交给新机。新机恢复后业务摘要与原机一致，家具、围巾、心愿、彩窗、雨天地图和伙伴回忆均可核对。原机确认归档后关闭并重开存档，仍处于只读状态。新机确认一件小事并推进一块石板，随后保存和回读返程文件。

原机使用该机原有 PIN 查看返程预览。完整替换时先生成内部恢复点，恢复点摘要与初次迁出一致。激活并重开存档后得到 7 分、11 经验及第二块石板，业务摘要与新机迁出的文件一致。用新 PIN 解锁，重复导入显示已经恢复。原机再补录一件成果达到 9 分、12 经验，新机归档，原机上一代 5 分存档仍可校验。[专项测试源码](../../../apps/mobile/test/family_features_test.dart) · [测试日志](tests.log)

## 万条流水计时

两轮使用同一个已发布的 `.alicebackup` 合成文件。解密后的 SQLite 为 52,379,648 字节（49.95 MiB），共 10,706 条流水。Debian 13 x86_64，Flutter 3.50.0 / Dart 3.14.0 调试 JIT，SQLite 3.54.1。关闭安卓模拟器，先恢复合成档作为源家庭，再单独计时。[夹具摘要](../device-acceptance/fixture.json)

| 步骤 | 第一轮 | 第二轮 |
|---|---:|---:|
| 导出，含加密回读 | 18.662 秒 | 18.843 秒 |
| 复制和交接回执 | 0.064 秒 | 0.060 秒 |
| 恢复，含预览、保护目标当前档和激活 | 14.458 秒 | 15.884 秒 |

每轮源存档、恢复预览与激活后的业务 SHA-256 一致。系统文件面板和两端 release 真机计时仍待实测。[原始计时](dense-backup.log)

在仓库根目录运行，使用同一份已下载的合成档和同一构建源码复测。[下载合成档](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/acceptance/alice-qa-019.alicebackup?raw=true) · [复测源码](../family-offline/backup_50m_benchmark_test.dart)

```sh
alice_repo=$(git rev-parse --show-toplevel)
alice_probe=$(mktemp -d)
git worktree add --detach "$alice_probe/source" 0b3aa4d
cp "$alice_repo/docs/evidence/family-offline/backup_50m_benchmark_test.dart" "$alice_probe/source/apps/mobile/test/"
cd "$alice_probe/source/apps/mobile"
flutter pub get --enforce-lockfile
ALICE_QA_INPUT_FILE=/absolute/path/to/alice-qa-019.alicebackup \
  flutter test --no-pub --concurrency=1 --reporter expanded test/backup_50m_benchmark_test.dart
```
