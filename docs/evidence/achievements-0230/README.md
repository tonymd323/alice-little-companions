# 0.23.0+24 成长进度与成就

小家、成长页和伙伴列表用两条进度条显示各伙伴的经验和亲密度。进度条按累计值与下一门槛的比例填充。到最终阶段后显示满格，数字继续显示累计值。「成长 → 成就」可切换查看已拥有的伙伴，每只可收集五枚进化徽章和四枚亲密度徽章。[门槛与结算规则](../../RULES.md#成长与空间) · [家长验收步骤](../../OWNER_WALKTHROUGH.md#023-的进度条和成就)

源码为 `c2269c517be401a3c0f1ef938445efda1997fd61`。Flutter 3.50.0 锁定依赖解析、静态分析及 84 项回归通过。专项测试操作小家的真实互动，核对两条进度和成就页，再用 360 × 800、130% 字体视口确认第三件成果，见到进化徽章。全量测试核对成果更正后的进化徽章保留，以及加密备份恢复后不同伙伴的进化和亲密度徽章。[依赖](pub-get.log) · [静态分析](analyze.log) · [专项测试](targeted.log) · [全量回归](flutter-tests.log)

安卓 APK 沿用原家庭签名，核对了 16 KiB 对齐、247 个运行素材和 58 个暖廊文件。[包摘要](package.json) · [构建记录](build.log)

Android 9 x86_64 模拟器在飞行模式下从 `0.22.0+23` 同签覆盖到 `0.23.0+24`。应用 UID、首次安装时间、活动数据代及原 32 张业务表摘要一致。奶油的经验条显示 16 / 20，亲密度条显示 7 / 8，旧档自动点亮奶油 4 枚和团团 1 枚徽章。在成就页切换查看后，复核了同一份存档摘要。[包身份](package-after.json) · [覆盖前数据](before.json) · [覆盖后数据](after-upgrade.json) · [成就页查看后](after-viewing.json) · [小家](home-progress.png) · [成长页](growth-progress.png) · [成就页](fox-achievements.png)

带团团回小家后，当天第一次摸摸让它的亲密度从 1 增到 2，获得「默契」徽章。重复摸摸及冷启动后的业务摘要均与首次互动后相同。冷启动再进入成就，团团显示 2 枚，切到奶油显示 4 枚。[首次互动](cat-first-touch.json) · [重复互动](cat-repeat-touch.json) · [冷启动](cold.json) · [团团成就截图](cat-achievements-cold.png) · [模拟器日志](android-test.log)

私有下载分支提交 `e8411b0` 同批发布 APK、版本清单、SHA-256 和下载页。独立 Git 副本回取的 APK 和版本清单与构建产物逐字节匹配。[下载 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.23.0-android.apk?raw=true) · [发布回执](github-download.json)

iPad 签名安装和双端真机迁移待接入。需要匹配 Xcode 的 Mac、可用 Apple Team、iPad 和安卓真机。[安装与设备条件](../../DELIVERY.md#ipad-首次试装)
