# 0.21.1 大存档取消与恢复

家庭候选版为 **0.21.1+20**，构建源码 `772db06b8df394332a8aee1297ec05658ed5e66a`。测试使用私有 GitHub 下载分支的加密合成家庭，导入后升级为 SQLite 结构 8。快照为 54,800,384 字节，含 10,706 条积分流水。[合成档回执](../device-acceptance/github-fixture.json) · [APK 与签名摘要](../companion-query-performance/package.json)

Android 9 x86_64 软件模拟器在飞行模式下安装已发布的原签名 APK。从首页「从备份恢复」经系统文件选择器导入旧档。激活后余额为 32,077 分，桃桃为 6 级、10,697 经验，家长待确认小事 21 件。30 张业务表通过 SQLite 完整性、外键和余额核对。[安装环境](environment.json) · [恢复预览](seed-compare.png) · [家园](large-family-home.png) · [业务摘要](seeded.json)

随后从家长入口将 18,589,159 字节的加密备份保存到 Android 系统的 Downloads。用「回读验证导出文件」重新选中同一文件，App 显示「已验证外部文件」。取回云端解密后，完整业务摘要也与同一旧档经云端升级后的摘要一致。软件模拟器的保存面板等候曾超时，面板打开后接续完成。正式耗时继续在两端真机测量。[系统保存](system-save.png) · [App 回读](verified-existing-backup.png) · [文件与解密摘要](android-export.json)

同一构建源码在云端 Flutter 回归中两轮生成普通加密备份，并验证保存的本地副本。生成含内部回读分别为 **18.212 秒和 20.337 秒**。初次恢复到空存档的解密预览及激活分别为 **14.861 秒和 17.165 秒**。这是同时运行安卓模拟器时测得的 Linux 调试模式应用服务耗时。[原始记录](large-transfer.log)

在迁移加密、写出后的内部回读、恢复解密和恢复点加密开始一秒后分别触发取消。每次都保留原活动存储代、已验证回执和加密备份，迁移取消后恢复可写，临时文件已清理。取消建立恢复点也保留了已有恢复点。关掉再打开存档后，全量业务摘要仍与升级后的合成档一致。原有 5 项进度与取消测试全部通过。[大档测试源码](published_large_transfer_probe_test.dart) · [原始记录](large-transfer.log)

双端真机的系统文件回读、取消和耗时归入 AC-21 和 AC-40，继续等待设备。[逐项验收](../acceptance.csv) · [设备计时](../device-acceptance/README.md#计时)

## 复测

从源码仓库运行，Git 需要读取原私有下载分支。探针只写临时测试家庭。

```sh
alice_repo=$(git rev-parse --show-toplevel)
alice_probe=$(mktemp -d)
git fetch origin android-downloads
git show 52f8732ea55c770481014fa7301db81dfd0fb57f:acceptance/alice-qa-019.alicebackup > "$alice_probe/fixture.alicebackup"
git worktree add --detach "$alice_probe/source" 772db06b8df394332a8aee1297ec05658ed5e66a
cp "$alice_repo/docs/evidence/backup-cancellation-0211/published_large_transfer_probe_test.dart" "$alice_probe/source/apps/mobile/test/"
cd "$alice_probe/source/apps/mobile"
flutter pub get --enforce-lockfile
ALICE_QA_INPUT_FILE="$alice_probe/fixture.alicebackup" \
  flutter test --no-pub --concurrency=1 --reporter expanded test/published_large_transfer_probe_test.dart
```
