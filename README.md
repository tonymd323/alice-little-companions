# 小小伙伴 · 正式开发启动包

2026-11-18　｜　交付基线 2.0　｜　iOS、iPadOS、Android

把本目录作为家庭 App 独立项目的根目录打开，在 Codex 中使用 [启动指令](START_CODEX.md)。Codex 按 [开发计划](docs/PLAN.md) 连续实现、自测、修复和打包。家长主要体验最终安装版本。

## 首个可验收成果

Alice 在飞行模式下打开家园，免费选择银杏狐、月牙耳兔或云翼猫。家长在本机设置 PIN，自定义一件小事及完成标准，选择类型。孩子申报后，家长确认，积分和一条可回看的成果记录同时出现。杀进程重开仍能看到。Codex 在两端跑通这条路径，再扩展完整目录。

| 问题 | 本轮依据 |
|---|---|
| 正式做什么 | [产品范围](docs/PRD.md)、[页面与角色操作](docs/UX_SPEC.md) |
| 积分、兑换和升级如何计算 | [业务规则](docs/RULES.md)、[任务配置](config/rules.json)、[兑换目录](config/catalog.json) |
| 实现应做到什么样子 | [Demo 与正式版差异](docs/DEMO_TO_APP.md)、[新版交互 Demo](https://alice-little-companions-demo.tonymei323.chatgpt.site/?pet=rabbit&stage=4)、[美术规范](docs/DESIGN_SPEC.md)、[素材清单](design/asset_manifest.json) |
| 怎样离线工作并完整换机 | [技术规格](docs/TECH_SPEC.md)、[备份协议](docs/BACKUP_FORMAT.md)、[数据交接](docs/DATA_HANDOFF.md) |
| 在哪里开发 | [开发环境及开工命令](docs/ENVIRONMENT.md)、[云端工具盘点](docs/evidence/cloud-preflight.json) |
| 做到什么程度可以交给家长 | [家长验收单](docs/OWNER_WALKTHROUGH.md)、[逐项验收](docs/ACCEPTANCE.md)、[验收执行表](docs/evidence/acceptance.csv)、[项目约定](AGENTS.md) |
| 本包已检查什么 | [准备工作校验结果](DOCS_CHECK.md)、[交付文件摘要](MANIFEST.json) |

## 已确认的产品方向

- 家长决定任务内容。只有家长确认后，真实成果才进入记录并获得积分。只使用一种积分，只能兑换 App 内的物品、布置和空间。
- 日常陪伴与升级有明确的视觉区别。三只伙伴各有六阶段，每次升级都有可辨认的外观变化。长大的纪念来自现实成果，开店、点击宠物和在线时长不产分。
- C 版银杏家园采用手绘笔触、明亮色彩和可交互的独立图层。免费家园里的桥、树屋是背景；兑换的功能区和店铺可进入、命名、单独布置。
- 已安装的 App 能离线完成首次建家和日常操作。外部加密备份可由家长保管，并可在 iPad 和安卓之间双向完整迁移。

## 实施默认与待验证条件

| 事项 | 本次采用的默认 |
|---|---|
| 技术和范围 | Flutter + Dart，Drift + SQLite。本机管理一个家庭、一名孩子。一次显示一位伙伴，换伙伴沿用同一份成长记录。 |
| 经济与成长 | 三类投入分别 2、3、5 分。成果发生日期累计到 3、10、20、35、55 天时依次开放外观。分值和阈值是本版可验收的设计参数。 |
| 设备使用方式 | 一台当前设备记账。家长把完整存档迁往下一台；旧机保留只读状态。独立修改的两份存档由家长选定一种整体状态。 |
| 兼容目标 | 以 iOS/iPadOS 16+ 和 Android 8+ 作为工程目标。Codex 在 M0 用实际设备及插件最低要求核对。 |
| iPad 分发 | 先用已有 Mac 与可用 Apple 账号验证家庭真机，再决定长期安装方式。付费、公开上架、输入账户凭据另行处理。 |

## 交付状态

网页 Demo 已发布。本包包含可重用的场景与宠物图、正式规则、测试数据和执行入口。尚未创建原生应用工程、安装工具链或操作用户的 Mac。Flutter 首次构建、原生实机签名和 iPad ↔ Android 迁移属于后续实施与实测。

重跑准备检查，在本目录执行 `python3 tools/validate_devpack.py`。检查通过后从 M0 开始。文件校验以 `MANIFEST.json` 为准；开发后配置变更由 Codex 在对应提交中维护。
