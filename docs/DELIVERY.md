# 家庭交付候选 0.9.0+6

源码候选标签为 `alice-rc1`。Android 包使用 release 模式和云端开发签名，适用于家庭试装。iOS/iPadOS 工程已随源码交付，签名安装需接入 Mac、Apple Team 和 iPad。整体验收还需两台实体机交叉迁移、更新和性能测量。

- [验收逐项记录](evidence/acceptance.csv)
- [云端与设备证据](evidence/M5/README.md)
- [家长最终体验](OWNER_WALKTHROUGH.md)
- [家庭备份与换机](BACKUP_MIGRATION.md)

## Android 试装

取 `artifacts/M5/alice-0.9.0-android.apk`，对照 `artifacts/M5/SHA256SUMS`。通过系统文件管理器打开 APK，按系统提示允许这一来源安装。也可连测试机运行 `adb install -r alice-0.9.0-android.apk`。安装后开启飞行模式，从主屏幕打开「小小伙伴」。测试版本由同一云端开发证书签名，模拟器已使用这一身份覆盖升级并核对旧存档。

正式家庭签名可在 Mac 或可信 Android 构建机的 `apps/mobile/android/key.properties` 中配置以下四项。该文件和签名私钥应保存在签名机。构建结果输出到 `build/app/outputs/flutter-apk/app-release.apk`。后续同包名覆盖升级使用同一证书和递增版本号。若试装版未来改用不同证书，先在试装版导出并回读完整备份，再迁到新签名版本。

```properties
storeFile=/absolute/path/to/family-signing.jks
storePassword=...
keyAlias=...
keyPassword=...
```

## iPad 首次试装

1. 在可运行匹配 Xcode 的 Mac 上克隆交付的 Git bundle，检出 `alice-rc1`。使用 Flutter 3.50.0，revision `ab2912035e160d9cad6306df307576da6128ebdb`。检查 `flutter doctor -v`、`xcodebuild -version` 和 `xcrun --sdk iphoneos --show-sdk-version`。
2. 在 `apps/mobile` 运行 `flutter pub get --enforce-lockfile`。先用 `flutter build ios --simulator` 验证 iPad 模拟器，再用 `flutter build ios --release --no-codesign` 验证设备编译。Flutter 生成 SwiftPM 项目依赖，Mac 完成解析后保存实际生成的锁文件。
3. 用 Xcode 打开 `apps/mobile/ios/Runner.xcworkspace`。连接 iPad，在设备上处理系统信任和开发者模式提示。家长在 Xcode 登录 Apple 账号并选可用 Team，为 Runner 使用可签名的唯一 Bundle Identifier。以后更新沿用相同标识及签名身份。
4. 家庭试装可用 Xcode Personal Team 直接 Run 到这台 iPad。描述文件有效期通常为 7 天。若已有合适的付费会员和注册设备，可按已选分发方式构建，例如 `flutter build ipa --release --export-method ad-hoc`。以实际签名、安装结果和描述文件期限为准。
5. 安装后离开调试器，从 iPad 主屏幕在飞行模式启动。按备份迁移说明用测试家庭分别跑 iPad 到 Android、Android 到 iPad，逐项检查记录、积分、搭配、布置和心愿。

家长可在最终确认后决定长期使用方式。签名凭据、真实家庭存档和口令留在家庭设备或签名机。
