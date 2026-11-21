# 小小伙伴 · 正式开发启动包

2026-11-18　｜　交付基线 2.0　｜　iOS、iPadOS、Android

安卓家庭候选版 **0.23.0+24** 将经验和亲密度统一为进度条，并增加进化与亲密度徽章。0.18 及后续家庭版可在「家长入口 → 应用更新」检查并覆盖安装。也可以在手机浏览器登录 GitHub 后下载家庭包。[下载家庭 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.23.0-android.apk?raw=true) · [应用更新说明](docs/DELIVERY.md#app-内更新) · [本轮测试](docs/evidence/achievements-0230/README.md)

修好暖廊彩窗后，从小家的「主线」打开《奶油的雨天地图》。小家显示当前伙伴的两条成长进度，「成长 → 成就」可切换查看各伙伴已获得的徽章。[家庭功能实测](docs/evidence/family-functions/README.md)

伙伴步态和场景融稿继续按原画制作批次推进。奶油的固定镜头录像和桃桃的同机位基线已归档。[奶油步态](docs/evidence/fox-walk/README.md) · [桃桃基线](docs/evidence/rabbit-hop/README.md) · [开发计划](docs/PLAN.md)

## 家庭离线闭环

Alice 在飞行模式下打开家园，从银杏狐、月牙耳兔和云翼猫中免费选一位入住。家长在本机设置 PIN，自定义一件小事及完成标准，选择类型。孩子申报后，家长确认，家庭积分、当前伙伴的经验和一条可回看的成果记录同时保存。重启后可继续使用。[家庭规则](docs/RULES.md)

| 问题 | 本轮依据 |
|---|---|
| 正式做什么 | [产品范围](docs/PRD.md)、[页面与角色操作](docs/UX_SPEC.md) |
| 积分、兑换和升级如何计算 | [业务规则](docs/RULES.md)、[任务配置](config/rules.json)、[兑换目录](config/catalog.json) |
| 实现应做到什么样子 | [Demo 与正式版差异](docs/DEMO_TO_APP.md)、[新版交互 Demo](https://alice-little-companions-demo.tonymei323.chatgpt.site/?pet=rabbit&stage=4)、[美术规范](docs/DESIGN_SPEC.md)、[素材清单](design/asset_manifest.json) |
| 怎样离线工作并完整换机 | [技术规格](docs/TECH_SPEC.md)、[备份协议](docs/BACKUP_FORMAT.md)、[数据交接](docs/DATA_HANDOFF.md) |
| 接下来谁来负责美术、表演和剧情 | [游戏制作组、试玩反馈与首段样片](docs/GAME_STUDIO.md) |
| 在哪里开发 | [开发环境及开工命令](docs/ENVIRONMENT.md)、[云端工具盘点](docs/evidence/cloud-preflight.json) |
| 做到什么程度可以交给家长 | [家长验收单](docs/OWNER_WALKTHROUGH.md)、[逐项验收](docs/ACCEPTANCE.md)、[验收执行表](docs/evidence/acceptance.csv)、[项目约定](AGENTS.md) |
| 本包已检查什么 | [准备工作校验结果](DOCS_CHECK.md)、[交付文件摘要](MANIFEST.json) |

## 已确认的产品方向

- 家长决定任务内容，家长确认的真实成果获得积分。家里使用同一种积分兑换伙伴、物品和空间。
- 在「小家 → 伙伴」可用 30 分解锁一位新伙伴。每位伙伴有独立经验，解锁时为 1 级、0 经验。家长每确认一件有效成果，当时陪伴的伙伴获得 1 经验，在 3、10、20、35、55 经验时依次进化。剧情、触摸和试穿可反复体验，期间积分与经验增量为零。
- C 版银杏家园采用手绘笔触、明亮色彩和可交互的独立图层。免费家园里的桥、树屋是背景；兑换的功能区和店铺可进入、命名，内有专属手绘陈设。
- 已安装的 App 能离线完成首次建家和日常操作。家长保管外部加密备份。iPad 与安卓之间的双向整家迁移是双端交付目标，两个方向均待真机验收。

## 家庭版实施口径与设备条件

| 事项 | 本次采用的默认 |
|---|---|
| 技术和范围 | Flutter + Dart，Drift + SQLite。本机管理一个家庭、一名孩子。一次带一位已解锁伙伴回小家，切换后读该伙伴的等级与搭配。 |
| 旧档升级 | 旧档的当前伙伴视为免费首宠，继承原有经验与最高已获阶段。以后两只伙伴可凭积分解锁。原有搭配、回忆和任务记录照常保留。 |
| 设备使用方式 | 一台当前设备记账。家长把完整存档迁往下一台；旧机保留只读状态。独立修改的两份存档由家长选定一种整体状态。 |
| 兼容目标 | 以 iOS/iPadOS 16+ 和 Android 8+ 作为工程目标。Codex 在 M0 用实际设备及插件最低要求核对。 |
| iPad 分发 | 先用已有 Mac 与可用 Apple 账号验证家庭真机，再决定长期安装方式。付费、公开上架、输入账户凭据另行处理。 |

## 交付状态

安卓 0.14.0+11 将《风过暖廊》接入原来的小家。从「主线 · 风过暖廊」进门，看桃桃听风压住围巾，把叶篮推到手边。点篮子取一片，再点要补的空窗格。先修中窗或先修远窗，奶油会看到不同的回家路。回暖廊后，彩窗和木地板会留下修好的光影。0.13 的家庭、兑换、经验和数学书签可继续使用。

0.14.1 修复了小家庭院左侧木梯随风弯曲的问题，留下早期步态对照。[下载 0.14.1 安卓安装包](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.14.1-android.apk?raw=true) · [木梯和步态基线](docs/evidence/courtyard-motion/README.md)

[0.14.0 安卓安装包](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.14.0-android.apk?raw=true) · [风过暖廊样片与检查](docs/evidence/wind/README.md) · [历次 APK](https://github.com/tonymd323/alice-little-companions/tree/android-downloads/downloads) · [备份与换机](docs/BACKUP_MIGRATION.md)

真机 iPad 安装、设备性能与双向实机迁移需要匹配的 Mac、Apple Team 及家庭设备。开发顺序与逐项验收条件见[开发计划](docs/PLAN.md)。

重跑准备检查，在本目录执行 `python3 tools/validate_devpack.py`。开工包的 `MANIFEST.json` 对应 `devpack-v2.0`。原生运行素材的摘要以 `design/asset_manifest.json`、各阶段构建摘要和 Git 标签为准。
