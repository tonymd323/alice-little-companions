# 家庭版 0.20.0+18 小事加载性能

构建源码 `0b3aa4d8b6a2de22be99bd35666a9b7e66ffbf6a`。冷启动和家长确认刷新待完成、待确认及等待前一阶段的小事。成长、已完成、误奖更正和小事管理打开时才查历史列表，浏览时按需呈现列表项，打开详情可核对原内容、完成标准、申报备注和家长反馈。[真机验收夹具](../device-acceptance/README.md)

## 万条流水复测

三次均使用同一个安卓恢复后的合成 SQLite 文件。起始状态为 10,706 条流水、21 件待确认、32,077 分、10,697 经验。环境为 Debian 13 x86_64、Flutter 3.50.0 / Dart 3.14.0 调试 JIT。测试为 390 × 844 的 Flutter 界面，计时期间关闭安卓模拟器。

| 测量 | 0.19.0+17 | 0.20.0+18 第一次 | 0.20.0+18 第二次 |
|---|---:|---:|---:|
| 重开控制器并显示家园首帧，10 次最慢 | 1.785 秒 | 1.193 秒 | 1.123 秒 |
| 点击「确认并入账」到显示确认反馈，20 次 p95 | 866.04 毫秒 | 282.81 毫秒 | 224.93 毫秒 |
| 其中数据刷新，20 次 p95 | 628.03 毫秒 | 44.53 毫秒 | 30.37 毫秒 |

每次通过真实家长界面确认 20 项，逐笔核对 2 分、1 经验和待确认数量。结束时共有 10,726 条流水、32,117 分、10,717 经验。0.19 每次查询包含约 24.4 MiB 已结束小事的内容、标准、反馈与处理备注。定时复测保留两次完整结果，其中一次的界面 p95 高于 250 毫秒。安卓与 iPad 的真机点击和系统冷启动仍待验收。[原始计时](timing.log) · [验收表](../acceptance.csv)

## 安卓覆盖与签发

78 项 Flutter 回归、静态分析和备份参考密文校验通过。专项用例核对了成长与已完成列表的反馈和标准，以及小事跨日到期时详情页的状态更新。[测试记录](tests.log) · [工具链](preflight.json)

将已恢复的合成 SQLite 放入一次性 Android 9 软件模拟器的 0.19 测试安装，用 `adb install --no-streaming -r` 在飞行模式覆盖至 0.20。冷启动后核对原积分、经验、待确认小事，再从已完成列表打开原任务内容和完成标准。两次数据库的 28 张业务表摘要一致，使用同一存储代。模拟器曾显示系统无响应提示，选择等待后完成界面核对。[覆盖摘要](android-upgrade.json) · [家园](android-home.png) · [已完成详情](android-task-details.png)

APK 使用原家庭签名，通过 16 KiB 对齐及内置素材检查。同一 Git 提交发布 APK 与版本记录，独立 Git 副本重新取回，两份文件逐字节一致。[家庭 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.20.0-android.apk?raw=true) · [包与签名](package.json) · [GitHub 回执](github-download.json) · [家园素材](art-daily.json) · [暖廊素材](art-wind.json)

## 复测

下载合成档到本机。以下命令用测试口令在独立目录解密后计时。将检出提交换成 `c55dbd1` 可复测 0.19。[合成档下载](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/acceptance/alice-qa-019.alicebackup?raw=true) · [测试源码](ui_performance_test.dart)

```sh
alice_repo=$(git rev-parse --show-toplevel)
alice_probe=$(mktemp -d)
git worktree add --detach "$alice_probe/source" 0b3aa4d
cp "$alice_repo/docs/evidence/task-performance/ui_performance_test.dart" "$alice_probe/source/apps/mobile/test/"
cd "$alice_probe/source/apps/mobile"
flutter pub get --enforce-lockfile
ALICE_UI_PROBE_LABEL=0.20.0 ALICE_UI_PROBE_FILE=/absolute/path/to/alice-qa-019.alicebackup \
  flutter test --no-pub --reporter expanded test/ui_performance_test.dart
```

复测 0.21 时，检出 `f3a7184`，给上面的测试增加 `ALICE_UI_PROBE_UPGRADE_SCHEMA=8`。测试先打开并保护旧档，核对迁移后的 SQLite 结构，再记录十次重开与二十次确认。旧档准备耗时随原始结果一并保留。[0.21 计时记录](../companion-unlock/README.md#万条流水确认计时)
