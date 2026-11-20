# 备份迁移界面复测

在发布包 0.21.2 对应的 Flutter 源码上，通过家长入口保存并返回备份页。调试环境复现 `setState` 回调返回 `Future` 的断言，备份页未重绘。修好刷新后，继续到恢复密钥的确认页，又触发勾选控件缺少就近 `Material` 的断言。该控件也用于首次建家和重设 PIN。[复现记录](tests.log)

源码 `7ce0537` 把备份、伙伴、扣分、兑换、空间和小事页面的异步查询与界面状态赋值分开，并给恢复确认的勾选控件补上透明 `Material`。同一提交等待下一次原签名构建。当前可覆盖安装的安卓家庭包为 0.21.2+21，构建提交为 `ae09472`。[修复源码](https://github.com/tonymd323/alice-little-companions/commit/7ce053762a12ba2b602e5adf67b4355ef926d60a) · [家长安装入口](../../DELIVERY.md)

复测在 Linux x86_64 上使用 Flutter 3.50.0 的调试测试。键盘通过 `viewInsets` 模拟，占 300–360 逻辑像素。文件选择器用临时本地文件和失焦事件模拟，业务层实际执行加密、回读、恢复与归档。实体 iPad 的键盘、文件选择器、钥匙串与两端迁移继续按设备验收执行。[真机验收](../device-acceptance/README.md)

完整回归 84 项通过，包含原有 80 项与四种参考尺寸的单伙伴迁移。四轮均用 130% 字体，经正常家长入口取消保存、重新解锁、重试保存、取消选文件、再选并回读。新家园恢复一件成果和一笔流水后，旧家园归档为只读。[回归日志](tests.log)

双伙伴复测覆盖 360 × 800、390 × 844 安卓参考尺寸和 834 × 1194、1194 × 834 iPad 参考尺寸。用 30 分解锁奶油后，余额从 35 分变为 5 分。四次经加密档恢复均读到奶油 1 级、0 经验，团团 2 级、7 经验，桃桃仍待解锁。七件成果和八笔流水都能读回。[双伙伴日志](tests.log)

```sh
cd apps/mobile
cp ../../docs/evidence/transfer-layout/transfer_layout_probe_test.dart test/
flutter pub get --enforce-lockfile
flutter test --no-pub --concurrency=1 --reporter expanded test/transfer_layout_probe_test.dart
```

[可复跑的界面测试](transfer_layout_probe_test.dart)
