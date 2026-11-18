# 家庭版 0.11.0 · 暖廊的彩窗

在原有「小小伙伴」上安装更新，打开 **银杏家园 → 数学 · 暖廊的彩窗**。孩子和自己选的伙伴从等量分组玩到补齐窗花，还可以试试用十九片叶子铺五格。左上角箭头回到同一家的暖廊。[Android 安装包](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.11.0-android.apk?raw=true) · [家园入口](home.png) · [章节画面](chapter.png) · [完成画面](finished.png)

| 验证 | 实际记录 |
|---|---|
| 覆盖安装 | 在只装有家庭版的另一台模拟器，0.10.0+7 直接更新为 0.11.0+8。Android 保留应用 UID 与首次安装时间，云翼猫和「小花瓶」心愿随存档保留。团团陪孩子解题，重启后回到第二题。[安装元数据](installation.json) · [旧版直接更新](direct-upgrade.log) |
| 离线续玩 | 飞行模式下 Android 报告没有活动的默认网络。云端模拟器完成两道基础题和十九片挑战，强行停止后能找回具体花纹，回到小家时余额仍为 3 分。[运行记录](android-upgrade.log) |
| 家庭备份 | 验证旧存档升级前的加密恢复点、历史账本、家庭书签、只读迁移状态和在新的存储目录恢复花纹。37 分迁移夹具保留账本及章节进度。[备份测试](../../../apps/mobile/test/backup_test.dart) |
| 回归 | Flutter 静态分析通过，28 项测试通过，含家庭入口、当前伙伴、旧存档及十种可行花纹。[静态分析](analyze.log) · [回归记录](full-tests.log) |
| 下载 | 从 GitHub 的新检出目录读取安装包，核对 68,734,394 字节及 SHA-256，与本地交付件完全一致。[远端复核](github-download.json) |

源码标签为 `alice-family-math-v0.11.0`，提交为 `a79a3c6`。在 `apps/mobile` 下使用锁定的 Flutter 3.50.0，运行 `flutter build apk --release` 即构建家庭版。SQLite 结构版本为 3，沿用原有加密容器。独立试玩的本机书签在试玩 App 内，家庭版从自己的书签续玩。[构建日志](android-build.log) · [备份与换机](../../BACKUP_MIGRATION.md)

本轮安装和界面验证使用 Android 11 云端模拟器。iPad 签名安装与实体手机、iPad 的双向迁移仍待真机验证。
