# 0.22.0+23 亲密度与糖果

安卓家庭候选版取自 `a9e44b4722730e6737e8352c3e8ff87f3e7b4498`。沿用原家庭签名，核对了 16 KiB 对齐、247 个运行素材和 58 个暖廊文件。[包摘要](package.json) · [构建记录](build.log)

每只伙伴按家庭日期独立累计亲密度。当天第一次摸摸和第一次呼唤各加 1，第一次互动仍保留在伙伴回忆。3 分兑换一颗亲密度糖果，喂给当前伙伴后加 3。亲密度和未用糖果随加密家庭档迁移。[业务规则](../../RULES.md#成长与空间) · [换机说明](../../BACKUP_MIGRATION.md#022-亲密度与糖果)

Flutter 3.50.0 锁定依赖解析、静态分析和 83 项回归通过。新增用例跨北京时间午夜检验每日去重和两只伙伴的独立亲密度，从结构 8 加密文件恢复原首次互动并继续累计，验证兑换幂等、喂食及退款、加密备份恢复后的糖果库存。外观预览仍通过完整业务状态一致性检查。[静态分析](analyze.log) · [回归日志](flutter-tests.log) · [开工包自检](devpack.json)

Android 9 x86_64 模拟器在飞行模式下先载入项目的结构 8 合成测试档。原签名覆盖安装从 `0.21.3+22` 升到 `0.22.0+23`，应用 UID、首次安装时间、活动数据代和原有 30 张业务表摘要一致。奶油和团团的原回忆分别转为 2 点和 1 点亲密度。[覆盖前](before.json) · [覆盖后](upgraded.json) · [版本身份](package-after.json) · [小家截图](upgraded-home.png)

同一天重复摸摸和呼唤，奶油亲密度从 2 增至 4，共新增两条记录。兑换使余额从 5 分降至 2 分，库存增加一颗。喂给奶油后亲密度到 7，库存回到 0，账本和经验与喂食前一致。团团保留 1 点。[每日互动](daily.json) · [成长](growth.png) · [兑换](redeemed.json) · [喂食](fed.json) · [糖果页](candy-ready.png)

关闭应用进程后冷启动，32 张业务表摘要与喂食后相同。伙伴列表显示团团 1 点和奶油 7 点。加密备份的库存恢复另有自动化用例覆盖。[冷启动记录](cold.json) · [伙伴列表](companion-scores.png) · [模拟器日志](android-test.log)

私有下载分支提交 `dc4854c` 同时更新了 APK、版本清单、SHA-256 和下载页。从独立 Git 副本回取的 APK 与清单逐字节匹配。[下载 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.22.0-android.apk?raw=true) · [发布回执](github-download.json)

iPad 签名安装和两端真机迁移待接入。需要匹配 Xcode 的 Mac、可用 Apple Team、iPad 和安卓真机。[安装与设备条件](../../DELIVERY.md#ipad-首次试装)
