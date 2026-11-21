# 0.21.3 家庭版

`0.21.3+22` 合入备份页返回后的状态刷新、恢复密钥确认控件和相关家长页面的刷新修复。构建源码是 `27c38ac41461720defcca73d848ca81cf1f18b32`。安卓 APK 使用原家庭签名，验证了 16 KiB 对齐、247 个运行素材和 58 个暖廊文件。[界面修复](../transfer-layout/README.md) · [构建日志](build.log) · [包与签名](package.json)

Flutter 3.50.0 锁定依赖解析和静态分析通过，80 项回归通过。覆盖首宠免费入住、积分解锁、伙伴独立经验、重复确认与纠错、离线剧情及加密备份。[静态分析](analyze.log) · [回归日志](flutter-tests.log)

另有 4 项迁移界面复测使用安卓与 iPad 参考视口、130% 字体和模拟键盘。每轮从家园兑换一位伙伴，再取消保存、重新解锁、重选与回读，最后恢复并归档。两只伙伴的等级、经验和账本均核对一致。测试用临时文件模拟系统选择器，实际运行加密与恢复。[复测源码](../transfer-layout/transfer_layout_probe_test.dart) · [界面日志](transfer-layout.log)

在 Android 9 x86_64 模拟器的飞行模式下，使用 `adb install -r` 从同签的 `0.21.2+21` 覆盖到 `0.21.3+22`。应用 UID、首次安装时间、活动存储代与 30 张业务表摘要一致。冷启动后保留 5 分、一件待确认小事、团团 1 级 0 经验和奶油 3 级 16 经验。[冷启动家园](cold-after-upgrade.png) · [覆盖记录](coverage.json)

通过安卓系统文件面板将普通加密备份存到 Downloads。在家长入口重选同一文件并回读，返回「备份与迁移」后显示验证时间。独立使用 Node 解密实际保存的 `ALICEBK1` 文件，再以 Python SQLite 核对文件内 30 张表，业务摘要与原档一致。[系统文件保存](system-save.png) · [回读后的备份页](backup-hub-refreshed.png) · [应用回读](external-readback.json) · [独立校验](independent-readback.json)

原私有下载分支提交 `1750b2b` 同时包含 APK、更新清单、SHA-256 和下载页链接。从独立 Git 副本取回 APK 与更新清单，逐字节匹配签名构建，并核对摘要及下载页版本。[下载 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.21.3-android.apk?raw=true) · [发布回执](github-download.json)

iPad 签名安装、真机私库授权更新及跨系统双向迁移仍待设备验收。两端采用同一构建提交。[设备验收](../device-acceptance/README.md)
