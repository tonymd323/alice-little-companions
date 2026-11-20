# 安卓与 iPad 真机验收

双端使用同一候选版本。最新候选为 0.20.0+18，构建源码 `0b3aa4d8b6a2de22be99bd35666a9b7e66ffbf6a`。记录设备型号、系统版本、签名方式和测试证据。[安卓安装包](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.20.0-android.apk?raw=true) · [iPad 签名安装](../../DELIVERY.md#ipad-首次试装)

## 导入测试家庭

把合成档保存到设备本地，在飞行模式从「从备份恢复」选文件。测试口令为 `Alice-QA-Fixture-019`。激活时为测试设备设置新 PIN。请使用专门的测试安装，恢复会替换设备上的当前小家。[下载合成档](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/acceptance/alice-qa-019.alicebackup?raw=true) · [文件摘要与预期数字](fixture.json)

恢复后核对第六阶段桃桃、已佩戴的围巾、已兑换家具、扶手椅心愿、扣分撤销与成果更正。彩窗已修复，雨天地图完成过 12 块石板和近路挑战，重玩进度留在第一块石板。家长入口可见 21 项编号待确认小事。[玩法与换机路径](../../BACKUP_MIGRATION.md)

该文件解密后的 SQLite 有 49.95 MiB，包含 10,706 条流水和 10,697 项有效成果。用 Flutter 3.50.0 / Dart 3.14.0 调试模式从独立云端存档恢复，前后业务摘要一致。连续确认 20 件后增加 40 分、20 经验，应用服务调用 p95 为 13.69 毫秒。生成时并行启动了安卓软件模拟器，记录的导出为 21.455 秒、恢复为 14.792 秒。[云端日志](fixture-tests.log)

独立 Git 副本已从原私有下载分支取回文件，逐字节校验一致。Android 9 软件模拟器在飞行模式下通过系统文件选择器导入同一文件。0.19.0+17 签名包的预览、激活、冷启动均已核对，活动 SQLite 的业务摘要与合成档一致。冷启动后可见第六阶段桃桃、21 件待确认小事和原心愿。[GitHub 回执](github-fixture.json) · [安卓恢复预览](android-preview.png) · [冷启动画面](android-restored-home.png) · [安卓恢复摘要](android-restoration.json)

## 双向迁移

1. 在 iPad 从「备份与迁移 → 迁移到新设备」生成文件，用同一测试口令保存并回读。确认源机保持只读。把文件交给安卓，从系统文件选择器导入，核对预览数字和恢复后家园。安卓在新增记录前导出一份普通备份，核对它与 iPad 迁移档的业务 SHA-256 相同。
2. 在安卓确认「测试待确认 01」，核对增加 2 分和 1 经验。生成迁移档并保存、回读，确认安卓源机冻结。将文件交给 iPad，从备份恢复后冷启动，核对新增记录和既有剧情与物品。iPad 导出普通备份，与安卓迁移档比对业务 SHA-256。

文件 SHA-256 用于校验传输。业务 SHA-256 来自解密后的规范化 SQLite 内容。用下面的复核命令分别读取源端和目标端的文件，每个方向的两个 `business_sha256` 应相同。[AC-29、AC-30](../../ACCEPTANCE.md#3-备份恢复和迁移)

## 计时

| 验收项 | 记录方法 | 通过条件 |
|---|---|---|
| 冷启动 | 每台设备强制退出后从桌面打开，用录屏记录从点图标到家园画面和主要按钮可用，重复 10 次 | 最慢≤3 秒 |
| 常用本地命令 | 从至少 10,000 条流水的合成档开始，依次确认 20 件待确认小事。记录每次确认到入账反馈的时间及积分、经验增量。20 个用时升序排列后取第 19 个为 p95 | p95≤250 毫秒 |
| 大档导出 | 合成档恢复后，从点「生成并保存文件」到系统文件面板出现计时。另记保存、关闭文件面板及回读的用时 | 应用内导出≤20 秒 |
| 大档恢复 | 先备好一个有少量数据的独立测试家庭。分别记录点「验证并预览」到预览、点「保护当前数据并确认」到确认、点「激活恢复后的存档」到家园可用的时间，三段相加 | 应用内恢复≤20 秒 |

两端都核对进度和取消。分别取消生成、解密预览和保护当前数据，再冷启动并校验当前家庭和此前保存的备份。[AC-39、AC-40](../../ACCEPTANCE.md#4-视觉性能与安装)

## 生成和复核

在仓库根目录运行。复核只处理本测试档和从它派生的设备文件。每次生成使用新的家庭标识和随机加密参数，以随包的 `fixture.json` 核对摘要。

```sh
alice_repo=$(git rev-parse --show-toplevel)
alice_probe=$(mktemp -d)
git worktree add --detach "$alice_probe/source" c55dbd1605215c78cb13101a273bfa53ace01819
cp "$alice_repo/docs/evidence/family-offline/backup_50m_benchmark_test.dart" "$alice_probe/source/apps/mobile/test/"
cd "$alice_probe/source/apps/mobile"
flutter pub get --enforce-lockfile
ALICE_QA_OUTPUT_DIR="$alice_probe" flutter test --no-pub --reporter expanded test/backup_50m_benchmark_test.dart
```

输出在 `$alice_probe/alice-qa-019-*`。检查从任一设备导出的文件时使用绝对路径。

```sh
ALICE_QA_REVIEW_FILE=/absolute/path/to/test.alicebackup \
  flutter test --no-pub --reporter expanded test/backup_50m_benchmark_test.dart
```

实体设备的安装、迁移和计时仍待配对设备。验收表保留对应状态。[逐项记录](../acceptance.csv)
