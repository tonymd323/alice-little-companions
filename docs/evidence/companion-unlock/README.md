# 0.21.0+19 伙伴解锁与独立成长

家庭包沿用原应用标识和签名，构建源码为 `f3a7184aaeff2589f3ffe6ef6618ac21c0618288`。从「小家 → 伙伴」邀请新的伙伴。首位免费，另两位各花 30 分永久解锁。新伙伴从 1 级、0 经验开始，切换已解锁伙伴免费。[APK 与签名摘要](package.json) · [旧档与换机](../../BACKUP_MIGRATION.md#021-伙伴成长档案)

## 业务回归

79 项 Flutter 测试及静态分析通过。备份校验识别结构 8 的伙伴归属和成果关联，旧结构 1–7 可按原摘要校验后升级。[测试记录](tests.log)

- 锁定伙伴无法切换，余额不足时兑换失败。重复兑换同一位只扣一次，模拟拥有记录写入后中断时整笔回滚。
- 先由首宠陪伴申报，再切到新伙伴确认。经验随确认时的伙伴保存。切回首宠更正该成果后，只调整原来收到经验的新伙伴，保留它已经获得的等级。
- 两次加密迁移保存两位伙伴各自的归属、经验、等级、搭配和回忆，以及雨天地图、彩窗、账本和待确认小事。回迁后可继续确认。覆盖旧格式、错误口令和中断保护。

在 `apps/mobile` 运行 `flutter test --no-pub test/companion_unlock_test.dart test/family_features_test.dart test/backup_test.dart` 复测专项。Android 家庭包可离线显示的素材和暖廊音效已逐项核对。[专项源码](../../../apps/mobile/test/companion_unlock_test.dart) · [回迁源码](../../../apps/mobile/test/family_features_test.dart) · [素材](art-daily.json) · [暖廊](art-wind.json)

## 安卓覆盖与重开

在 Android 9 云端模拟器的 0.20.0 家庭版中使用合成档，启用飞行模式，再原地升级到 0.21.0。应用 UID、首次安装时间和存储代一致。原有 28 张业务表导出行的 SHA-256 相同。奶油成为首宠，保留 3 级、16 经验和家庭的 35 分。伙伴页另两位等待积分解锁。[覆盖后截图](01-legacy-companion.png)

打开团团的兑换确认并返回，余额仍为 35 分。重新打开并确认，积分只扣 30 分，团团显示 1 级、0 经验。切换到团团后，家长确认原先申报的一件 2 分小事。杀进程重开，余额为 7 分，团团拥有 1 经验，奶油拥有 16 经验。[解锁后截图](02-new-companion.png) · [重开后截图](03-independent-experience.png) · [数据库复核](android-verification.json)

预览尚未解锁的桃桃 6 级外观后返回小家，积分、账本、当前伙伴、解锁记录和两位实际拥有的伙伴经验均与预览前相同。[外观预览截图](04-locked-rabbit-preview.png)

同一个 GitHub 提交发布 APK、`latest.json` 和 SHA-256 清单。独立 Git 副本取回 APK 和更新记录，与签名机构建结果逐字节一致。[下载家庭 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.21.0-android.apk?raw=true) · [发布回执](github-download.json)

## 万条流水旧档

原 0.19 合成档升级到结构 8 后有 54,800,384 字节，保留 32,077 分、10,706 条流水和 10,697 份有效成果。桃桃继承 10,697 经验和 6 级。重新加密导出并整体恢复后，摘要与结构 8 的源存档一致。云端调试运行时同机安卓模拟器也在运行，导出为 21.518 秒，恢复为 16.688 秒。[复核日志](large-fixture.log) · [真机计时方法](../device-acceptance/README.md#计时)

iPad 安装与双向真机迁移等待 Mac、Apple Team 和家庭设备接入。[设备条件](../../DELIVERY.md#ipad-首次试装)
