# M1 · 首次记账闭环

- 源码标签 `alice-m1`，Android 版本 0.2.0+2，以开发证书签名。安装件 `artifacts/M1/alice-m1.apk`。[SHA-256](SHA256SUMS) · [构建](android-build.log)
- Linux 真实临时 SQLite 测试执行空家庭、儿童权限拒绝、3 分小事发布和申报、20 次单次结算及重开后验证。最终余额 3，奖励流水 1、有效成果 1。独立测试验证 PIN 锁定与重启限流。[测试日志](tests.log)
- 桌面 Flutter Widget 测试核对三宠六阶段。云端静态分析无问题。[分析](analyze.log)
- iOS 编译与账号签名待 macOS/Xcode 家庭设备环境。

Android 11 模拟器在飞行模式下以 release APK 实测建家、选兔、换阶段预览后返回 0 分、家长发布 3 分小事、孩子申报、家长确认、查看唯一一条奖励流水并强制停止进程重启。重启仍为 3 分且保留所选伙伴。[设备日志](android-flow.log) · [空白家园](android-empty-home.png) · [发布](android-publish.png) · [申报](android-submitted.png) · [确认页](android-parent-pending.png) · [积分流水](android-ledger.png) · [冷启动](android-restarted.png)
