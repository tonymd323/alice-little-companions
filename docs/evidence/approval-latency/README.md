# 0.21.2 家长确认计时

用 0.21.2 的发布源码 `ae09472`，在 Linux x86_64 上运行 Flutter 3.50.0 调试探针，视口为 390 × 844。把同一个 10,706 条流水的合成档升级到数据库结构 8。每轮重开应用 10 次，通过家长入口确认 20 项小事，逐项核对增加 2 分、1 经验，待确认项从 21 减到 1，流水从 10,706 增至 10,726。计时期间关闭安卓模拟器。[合成档及摘要](../device-acceptance/github-fixture.json) · [原始计时](timing.log)

| 版本和方法 | 第一次 p95 | 第二次 p95 | 家长页初始待确认行组件 |
|---|---:|---:|---:|
| 发布版，原探针 | 224.5 毫秒 | 264.3 毫秒 | — |
| 发布版，分段探针 | 218.4 毫秒 | 270.7 毫秒 | 21 |
| 待确认行按需构建，探索探针 | 300.1 毫秒 | 275.9 毫秒 | 4 |
| 按需构建并在确认页显示回执，分段探针 | 462.4 毫秒 | 217.4 毫秒 | 4 |

分段探针从点击「确认并入账」计时，到首次找到带积分和经验的回执文本。在发布版的 40 次确认中，点击到开始刷新、刷新本身、刷新结束到回执出现的中位数分别为 34.5、22.6、97.1 毫秒。第三段也包含组件构建与帧调度。原探针的两轮重开到首帧最慢为 1.164 秒。AC-39 仍待两端用正式包在真机上测量。[真机计时方法](../device-acceptance/README.md#计时)

单独测试按需构建时，探索探针以回执标题出现为终点。合并在确认页显示回执后，用与发布版相同的分段探针对照，两轮结果的快慢方向相反。两项界面试验保留在实验分支，家庭下载继续使用 0.21.2。[按需构建提交](https://github.com/tonymd323/alice-little-companions/commit/d20591859383d3ebb7709ec06ecc9f75ca3fcd6f) · [同页回执提交](https://github.com/tonymd323/alice-little-companions/commit/02c2a29cbd6b6f36c19ecaea85c3d160592fb8fc) · [安卓家庭 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.21.2-android.apk?raw=true)

在 Android 9 软件模拟器的飞行模式下，用发布包从系统文件恢复合成家庭。把已解锁、1 级 0 经验的团团带回小家，余额仍为 5 分。家长确认一件小事后，回执显示反馈、2 分和 1 经验，待确认项归零。强制停止并重开后，余额为 7 分，团团为 1 级、1 经验，奶油保持 3 级、16 经验。账本增加一笔，原剧情、回忆、物品与衣饰保留。[入账回执](confirmation-feedback.png) · [重开后的家园](home-after-confirmation.png) · [存档核对](android-confirmation.json)

## 复测

在 `ae09472` 或实验提交 `02c2a29` 的 `apps/mobile` 下，把本目录的分段探针复制到 `test/approval_profile_test.dart`。设置 `ALICE_UI_PROBE_FILE` 为下载的合成档路径。也可用原探针按同样方式复测。[分段探针](approval_profile_test.dart) · [原探针](../task-performance/ui_performance_test.dart) · [下载合成档](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/acceptance/alice-qa-019.alicebackup?raw=true)

```sh
flutter pub get --enforce-lockfile
ALICE_UI_PROBE_FILE=/absolute/path/to/alice-qa-019.alicebackup \
  ALICE_UI_PROBE_UPGRADE_SCHEMA=8 ALICE_UI_PROBE_LABEL=confirmation-rerun \
  flutter test --no-pub --concurrency=1 --reporter expanded test/approval_profile_test.dart
```
