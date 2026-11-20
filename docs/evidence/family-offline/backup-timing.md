# 50 MiB 加密备份基线

家庭版 `0.17.0+15`，源码 `28da3a76621f8d13c00ff57f8cf7f426f26239ca`。Debian 13 x86_64，Xeon Platinum 8573C，容器 CPU 配额 4 核。使用 Flutter 3.50.0 与 Dart 3.14.0 的 `flutter_tester` 调试 JIT 模式。源和目标为两个隔离的测试目录，同一云电脑也在启动安卓软件模拟器。

压测以仓库的 37 分迁移样本为起点，补充成套的合成任务、成果、流水和命令回执。计时前通过 SQLite 完整性、外键、账本和业务关联校验。一致快照大小为 **52,256,768 字节（49.84 MiB）**，共 6,871 条流水、6,866 项成果、5 件物品和 1 个空间。计时只包含下表的实际应用服务操作。

| 云端步骤 | 秒 |
|---|---:|
| 导出总计 | **27.033** |
| 一致快照 | 0.182 |
| 校验源快照 | 4.979 |
| 打包和加密 | 11.440 |
| 解密回读和生成内部回执 | 10.422 |
| 本地文件复制和交接回执 | 0.078 |
| 恢复总计 | **21.880** |
| 解密和预览 | 10.526 |
| 保护目标原存档 | 0.174 |
| 激活并校验目标库 | 11.178 |

激活后目标切换到新存档。源、恢复预览和激活后数据的规范化业务 SHA-256 一致，源存档余额保留。两项云端用时均超过 20 秒。安卓和 iPad 的 release 安装包仍需在各自真机计时，并检查系统文件面板和取消响应。[原始计时字段](timing-50m.log)

## 复测

在仓库根目录运行。命令创建一次性检出，测试退出时自动清理临时数据库与加密文件。

```sh
alice_repo=$(git rev-parse --show-toplevel)
alice_probe=$(mktemp -d)
git worktree add --detach "$alice_probe/source" 28da3a7
cp "$alice_repo/docs/evidence/family-offline/backup_50m_benchmark_test.dart" "$alice_probe/source/apps/mobile/test/"
cd "$alice_probe/source/apps/mobile"
flutter pub get --enforce-lockfile
flutter test --no-pub --concurrency=1 --reporter expanded test/backup_50m_benchmark_test.dart
```

[合成夹具与计时代码](backup_50m_benchmark_test.dart)
