# 资料与需求来源

初版调研日期为 2026-11-17。2026-11-18 的工具链与签名核查见 [开发环境](../docs/ENVIRONMENT.md)。以下链接支撑工具能力或分发条件，不代表本项目已经实施或通过测试。

## 用户要求

本会话明确：家庭使用；Alice有iPad；iOS和安卓可用；家长自定义任务并选择类型；家长确认完成或按约定扣分；只兑换App内成果；目标为正反馈和成就感；完整离线、本地备份、跨设备迁移；Codex负责开发、用户主要最终验收。

此前业务规则：[Alice_任务类型与积分经济系统.md](https://chatgpt.com/library?file_id=libfile_fde3_f-89a44d1b333c8191be5dc2a3fe61bf1e_1811d76daad481919ba046f4fb77e951&account_id=personal)，读取到版本1，文内版本v0.2。其后用户新增离线要求，本包RULES/TECH_SPEC已据此更新。

## 技术一手资料

| 资料 | 本项目使用的事实 |
|---|---|
| [Flutter数据库选择](https://docs.flutter.dev/data-and-backend/persistence/choose-a-database) | 本地SQLite可用于无需云后端的持久化；单靠本地存储不自动实现跨设备同步 |
| [Drift Native](https://drift.simonbinder.eu/platforms/vm/) | NativeDatabase支持本地SQLite，可放后台isolate；据此选择本地数据库层 |
| [SQLite VACUUM](https://www.sqlite.org/lang_vacuum.html) | VACUUM INTO可生成一致性快照，但执行中断仍需检测与处理 |
| [cryptography维护者文档](https://pub.dev/packages/cryptography) | 提供AES-GCM、PBKDF2及跨平台密码算法；具体备份格式为本项目设计 |
| [Flutter iOS构建](https://docs.flutter.dev/deployment/ios) | iOS构建和发布依赖macOS/Xcode及相应签名条件 |
| [Flutter Android构建](https://docs.flutter.dev/deployment/android) | Android正式包需要签名与实际安装验证 |
| [Flutter integration_test](https://docs.flutter.dev/testing/integration-tests) | 可在设备上执行集成测试，设备和测试范围须如实记录 |
| [Apple分发方式](https://help.apple.com/xcode/mac/current/en.lproj/dev31de635e5.html) | Ad Hoc针对注册设备，须具备相应开发者及签名条件 |
| [Apple TestFlight](https://testflight.apple.com/) | 单个测试构建最长测试期90天，不能当作永久免维护安装 |
| [Codex AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md) | 持久项目约定入口；其他文档通过引用组织 |
| [Codex长任务实践](https://developers.openai.com/blog/run-long-horizon-tasks-with-codex) | 明确目标、阶段验证和持续状态记录可以用于组织长任务 |

Flutter平台支持、依赖最低版本与构建工具会更新；M0应以锁定版本及实际设备核查。不同官方页面可能更新不同步，不直接照抄某页面最低系统版本作为用户设备结论。

未采用的云端技术研究不构成实施要求。没有引用公开资料证明积分方案必然带来某种教育结果，积分与视觉数值均为本项目设计建议。
