# 小小伙伴家庭安装说明

当前 Android 家庭候选版是 **0.19.0+17**，构建提交为 `c55dbd1`，沿用原家庭签名。0.18 家庭版可在家长入口检查更新，也可在手机浏览器登录私有仓库，下载通用 APK 后选择「更新」。[下载 0.19.0 家庭 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.19.0-android.apk?raw=true) · [下载目录及旧版](https://github.com/tonymd323/alice-little-companions/tree/android-downloads/downloads)

0.14.1 和 0.15.0 家庭包的签名指纹一致。安卓 9 云端模拟器在飞行模式下覆盖后冷启动，测试家庭与已修好的彩窗均保留。早期候选 `alice-0.15.0-cat-preview.apk` 使用另一张测试证书，仅供单独试装。[双包摘要](evidence/cat-walk/family-package.json) · [覆盖与重启实测](evidence/cat-walk/family-upgrade.json)

0.17 的云端回归覆盖加密备份取消、应用意外退出后的回执保护、旧存档、新数学主线和伙伴回忆。[功能与签发记录](evidence/family-functions/README.md)

0.9.0+6 的历史标签为 `alice-rc1`。Android 包使用 release 模式和云端开发签名，适用于家庭试装。iOS/iPadOS 工程已随源码交付，签名安装需接入 Mac、Apple Team 和 iPad。整体验收还需两台实体机交叉迁移、更新和性能测量。

- [验收逐项记录](evidence/acceptance.csv)
- [风过暖廊试玩与安装校验](evidence/wind/README.md)
- [0.13 家庭日用版本记录](evidence/daily/README.md)
- [0.10 手绘互动版本记录](evidence/M6/README.md)
- [0.9.0 云端与设备证据](evidence/M5/README.md)
- [家长最终体验](OWNER_WALKTHROUGH.md)
- [家庭备份与换机](BACKUP_MIGRATION.md)

## Android 试装

家庭包文件名是 `alice-0.19.0-android.apk`。通过系统文件管理器打开，按提示允许该来源安装。在连接的项目测试机上也可以执行 `adb install -r alice-0.19.0-android.apk`。安装后从主屏幕打开「小小伙伴」。[包与签名](evidence/backup-performance/README.md)

### App 内更新

1. 打开「家长入口 → 应用更新 → 检查更新」。应用先按当前的访问配置检查。公开 GitHub 仓库可直接读取版本和安装包。
2. 当前下载仓库是私有的。GitHub 若提示需要授权，在 GitHub 的 Fine-grained tokens 页面为 `tonymd323/alice-little-companions` 创建能读取仓库内容的令牌，选 **Contents: Read-only**。将它填到这台设备的「应用更新」。令牌保存在设备安全存储里，可在该页移除，不随家庭备份迁移。也可使用页面上的「在浏览器下载」。[GitHub 令牌设置](https://github.com/settings/personal-access-tokens/new)
3. 发现新版本时点「下载并安装」。下载完成后，App 验证文件大小、SHA-256、包名、递增版本和签名。初次安装来源授权可能会打开安卓设置。开启对应权限，回到 App 解锁家长入口，点「安装更新」，在系统界面确认。

版本查询和下载由家长主动触发。建家、账本、剧情、备份和恢复仍可在飞行模式下使用。iPad 的更新沿用 Apple 签名安装方式。

后续签发用下列命令从原签名 APK 生成 `latest.json`。在私有 `android-downloads` 分支的同一个提交发布 `downloads/latest.json`、对应 APK 和 `SHA256SUMS.txt`，让应用检查一次即可获得完整的一版。核对 GitHub 取回的包与本地摘要一致。

```sh
python3 tools/android_update_manifest.py app-release.apk --build-tools "$ANDROID_HOME/build-tools/36.0.0" > latest.json
```

正式家庭签名可在 Mac 或可信 Android 构建机的 `apps/mobile/android/key.properties` 中配置以下四项。该文件和签名私钥应保存在签名机。构建结果输出到 `build/app/outputs/flutter-apk/app-release.apk`。后续同包名覆盖升级使用同一证书和递增版本号。若试装版未来改用不同证书，先在试装版导出并回读完整备份，再迁到新签名版本。

```properties
storeFile=/absolute/path/to/family-signing.jks
storePassword=...
keyAlias=...
keyPassword=...
```

### 新会话接续安卓签名

家庭版 Android 签名证书的公开 SHA-256 为 `c046191e27395fff3ea806f44b1e501cc7577d70acdbae7639f0061158200e05`。新会话先核对所在的构建机。同一台原云电脑可运行 `source /workspace/scratch/alice-sdk/env.sh`，从已验收的源码在 `apps/mobile` 执行 `flutter build apk --release`。用 Android Build Tools 的 `apksigner verify --verbose --print-certs` 检查输出 APK，逐字比对上述指纹，再用 `adb install -r` 对项目测试家庭做覆盖验证。源码、APK、证书指纹和升级证据可随 Git 交接。

若在独立云电脑上持续签包，由新会话在仓库外的私有目录创建一次性 RSA 接收密钥和 X.509 证书，限制目录和私钥只对当前用户可读。经家长指定的会话只传回 PEM 公开证书（`BEGIN CERTIFICATE`）。原签名机用该证书封装加密交接包，接收机本地解密并保管签名材料。用新机签出的测试 APK 复核完整指纹并覆盖旧测试存档后，才记录交接成功。聊天中只交换公开证书及核验结果，私钥和口令留在构建机。

## iPad 首次试装

1. 在可运行匹配 Xcode 的 Mac 上克隆源码仓库，检出要与 Android 对照的同一构建提交。0.19.0+17 家庭候选版为 `c55dbd1`。使用 Flutter 3.50.0，revision `ab2912035e160d9cad6306df307576da6128ebdb`。检查 `flutter doctor -v`、`xcodebuild -version` 和 `xcrun --sdk iphoneos --show-sdk-version`。
2. 在 `apps/mobile` 运行 `flutter pub get --enforce-lockfile`。先用 `flutter build ios --simulator` 验证 iPad 模拟器，再用 `flutter build ios --release --no-codesign` 验证设备编译。Flutter 生成 SwiftPM 项目依赖，Mac 完成解析后保存实际生成的锁文件。
3. 用 Xcode 打开 `apps/mobile/ios/Runner.xcworkspace`。连接 iPad，在设备上处理系统信任和开发者模式提示。家长在 Xcode 登录 Apple 账号并选可用 Team，为 Runner 使用可签名的唯一 Bundle Identifier。以后更新沿用相同标识及签名身份。
4. 家庭试装可用 Xcode Personal Team 直接 Run 到这台 iPad。描述文件有效期通常为 7 天。若已有合适的付费会员和注册设备，可按已选分发方式构建，例如 `flutter build ipa --release --export-method ad-hoc`。以实际签名、安装结果和描述文件期限为准。
5. 安装后离开调试器，从 iPad 主屏幕在飞行模式启动。按备份迁移说明用测试家庭分别跑 iPad 到 Android、Android 到 iPad，逐项检查记录、积分、搭配、布置和心愿。

家长可在最终确认后决定长期使用方式。签名凭据、真实家庭存档和口令留在家庭设备或签名机。
