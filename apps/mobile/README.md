# 小小伙伴 Flutter 工程

目标 Android 8+、iOS/iPadOS 16+。Flutter 固定版本见 `.flutter-version`，Dart 包版本见 `pubspec.lock`。

在此目录运行：

```sh
flutter --version --machine
flutter pub get --enforce-lockfile
dart run build_runner build
flutter analyze
flutter test --reporter expanded
flutter build apk --release
```

`integration_test/preview_and_storage_test.dart` 在设备上探测平台安全存储和真实 SQLite，并对三宠六阶段的预览前后状态做比较。设备命令为 `flutter test integration_test -d <DEVICE_ID>`。

Mac 签名、安装及安卓发布密钥配置见 [交付说明](../../docs/DELIVERY.md)。用户的文件操作流程见 [家庭备份与换机](../../docs/BACKUP_MIGRATION.md)。
