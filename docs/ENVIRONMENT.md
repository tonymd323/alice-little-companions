# 开发环境与首次构建

开工基线建议，核查日期为 2026-11-18。正式 App 使用 Flutter/Dart，Drift 管理设备上的 SQLite，所有画面、文字和规则随安装包交付。开发机联网下载工具与依赖，安装到设备后用飞行模式验证实际运行。

## 两台环境用同一个私有 Git 仓库交接

| 环境 | 具体用途 | 首次验证 |
|---|---|---|
| 日常云电脑，Linux + Git + Codex + Flutter | 写代码，检查资源，跑领域、Widget、真实临时 SQLite 与备份格式测试。配好 Android SDK 后构建 APK | 初次建立依赖锁并跑通测试，后续按同一提交重复构建 |
| 可连接家庭设备的 Mac，优先复用现有 Apple Silicon 机器 | 使用相同 Flutter 版本，Xcode 编译、签名和安装 iPad 版。也可在这里直接安装 Android Studio，一台机器完成双端设备调试 | 取同一 Git 提交，验证 iPad 编译、真机安装和系统文件选择器。选用云 Mac 可完成编译签名，家庭 iPad 仍需实际安装并验证 |
| Alice 的 iPad 与一台安卓真机 | 使用同一批模拟家庭数据，先在 iPad 验收，再双向迁移、覆盖升级 | 飞行模式下从主屏幕冷启动。文件可通过本地电脑或两台设备都能读取的外置存储中转，分别验证两个方向 |

其中只有安装包、源码和测试用假数据需要跨环境交接。正式家庭数据库、备份口令和签名私钥在家庭设备或指定的签名机保管。编辑器可选 VS Code；Codex 直接在仓库运行即可。产品端无需单独部署数据库或后端。

**当前实测**　云执行环境为 Debian 13 x86_64，可调用 Git 2.52.0、OpenJDK 21.0.13。本次在 PATH 中未找到 flutter、dart、adb、sdkmanager、xcodebuild。Mac 配置、iPad 型号及系统、安卓型号及系统和 Apple 签名资格待连接时读取。此处未安装 SDK、创建证书或运行原生应用。

## 工具版本与兼容性

| 项 | 初始选择 | 固定方式 |
|---|---|---|
| Flutter / Dart | 首轮可复现候选为 Flutter 3.50.0 stable，使用其中自带的 Dart 3.14 系列 | 开工时按官方 SDK 归档选择匹配主机架构的包。两台主机使用同一 Flutter tag 和 revision，记录 `flutter --version --machine`。确需调整补丁时在两个平台重跑下方探针 |
| iPad / iOS | 产品部署目标暂定 16.0。按实际 Mac 系统和 Alice 的 iPadOS 版本，在 Apple 的 Xcode 对照表选择同时列入 macOS、Deployment Targets 与 Device Support 的稳定组合；先用一台 iPad 模拟器和真实 iPad 验证。 | 分别核对宿主系统、部署目标和真机调试支持，记录 Xcode build、iOS SDK 和 iPad 真机系统。实际无法连接旧系统时保留旧版签名包安装验证，标出未测系统 |
| Apple 原生依赖 | 新工程沿用 Flutter 默认 Swift Package Manager；插件仅提供 CocoaPods 支持时启用相应兼容路径 | 提交实际生成并适用于项目的 Package.resolved / Podfile.lock；后一种路径同时记录 CocoaPods 版本 |
| Android | 产品 minSdk 初始设 API 26（Android 8.0）。Android Studio 选 stable，官方设置页列出 SDK Platform 36；若新工程模板或依赖需要更高 compileSdk，补装对应平台、Build-Tools、platform-tools、cmdline-tools 以及所需 NDK/CMake | 取模板兼容的 Gradle wrapper、Android Gradle Plugin、Kotlin 和 Gradle JDK 组合。云端和 Mac 用同一 JDK 主版本，优先验证 Android Studio 所带 JBR。记录实际 compileSdk、targetSdk、minSdk、JDK、Gradle 和 NDK |
| Dart 包 | Drift、sqlite3、drift_dev、build_runner、path_provider，并按技术规格接入加密、文件选择与安全存储 | 首次解析后提交 pubspec.lock；CI 用锁文件复现。用双方真机确认系统保存、取消和重选文件，以及新设备上重新设置 PIN |

Flutter 对移动版本的支持范围涵盖上述产品下限。原生插件仍须在最低版本验证。建议先用已有硬件，M0 记录剩余磁盘和运行模拟器的实际表现。[Flutter 发布说明](https://flutter.dev/blog/whats-new-in-flutter-3-50) · [3.50.0 官方标签](https://github.com/flutter/flutter/releases/tag/3.50.0) · [部署平台](https://docs.flutter.dev/reference/supported-platforms) · [Xcode 对照表](https://developer.apple.com/xcode/system-requirements) · [Android Studio 主机要求](https://developer.android.com/studio/install)

## Codex 开工顺序

1. 安装选定版本的 Flutter 并加入 PATH。Android 端安装 Android Studio 与 SDK；在可运行模拟器的主机建一个安卓手机镜像。Mac 另安装匹配的 Xcode，选中 Command Line Tools，下载一个 iPad 模拟器运行时。若涉及许可，使用机器管理者认可的配置。初次 iPad 调试优先 USB，按设备提示信任和启用开发者模式；支持时可在相同局域网无线调试。
2. 在仓库根执行项目自检。首次建原生工程遵循当前目录约定 `apps/mobile`，只创建 iOS 与 Android 两个平台。沿用已有工程时跳过创建。开发包名可以先用测试标识，首次家庭分发前确定可签名的唯一 bundle ID、Android applicationId 和持久签名密钥。
3. 先引入本地库与文件依赖做探针。用假数据写一笔账、退出进程后重开、导出到系统文件、从另一台设备读取并解密。记录插件、SDK 和真实设备组合，再锁定依赖并展开功能开发。

```bash
# 云端与 Mac；在选定 Flutter 已安装的环境执行
flutter --version --machine
flutter doctor -v
flutter devices

# Android 开发机
adb version
sdkmanager --list_installed

# macOS 构建机
sw_vers
xcodebuild -version
xcrun --sdk iphoneos --show-sdk-version
xcrun simctl list devices available
```

```bash
# 在仓库根执行；APP_ORG 用于区分应用，local.family 是可更改的开发默认
python3 tools/validate_devpack.py
if [ ! -f apps/mobile/pubspec.yaml ]; then
  : "${APP_ORG:=local.family}"
  flutter create --platforms=ios,android --org "$APP_ORG" --project-name alice_companions apps/mobile
fi
cd apps/mobile

# 首次按技术规格写入 pubspec.yaml 后执行；首次成功解析后提交锁文件
flutter pub get
dart run build_runner build
flutter analyze
flutter test

# 设备 ID 来自 flutter devices；integration_test 用例就绪后执行
flutter test integration_test -d "$DEVICE_ID"
# Android 已配置家庭 release 密钥后执行
flutter build apk --release
# Mac 已配置注册设备及分发签名，并选定 Ad Hoc 后执行
flutter build ipa --release --export-method ad-hoc
```

M0 的环境记录放在 `docs/evidence/M0/`，包含工具版本、代码提交、命令及退出结果、Android 首次启动截图、iPad 模拟器或真机实际运行结果、两端插件探针结果。设备以型号和系统版本记录，公开可见的日志隐去序列号、账号和签名信息。只装了 SDK 或只生成模板时，对应测试保留为待运行。

[Flutter SDK 归档](https://docs.flutter.dev/install/archive) · [Android 环境步骤](https://docs.flutter.dev/platform-integration/android/setup) · [Android 构建使用的 JDK](https://developer.android.com/build/jdks) · [iOS 环境步骤](https://docs.flutter.dev/platform-integration/ios/setup) · [Flutter 的 SwiftPM 兼容策略](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers) · [Drift 配置](https://drift.simonbinder.eu/setup/) · [Flutter iOS 构建与导出](https://docs.flutter.dev/deployment/ios)

## 家庭设备安装

| 使用阶段 | iPad | Android |
|---|---|---|
| 第一次原生验收 | 免费 Apple 账户 Personal Team 可在 Xcode 安装到个人设备；描述文件签发后 7 天到期，需要重新构建安装。家庭使用的持续时长在交付前单独确认 | 可用开发 APK 在测试机联调；准备 release 时保存独立的家庭签名密钥 |
| 长期家庭使用 | 若已有付费会员或另行决定加入，推荐评估 Ad Hoc，在会员下登记 Alice 的 iPad，记录实际描述文件到期日、重签与覆盖安装步骤。Apple Developer Program 标价每会员年 99 美元，按地区显示当地金额 | 在家庭设备上安装签名 release APK。后续用相同 applicationId 和签名证书、递增 versionCode 覆盖升级，并验证原生数据保留 |
| 一段时间的远程试用 | 选择 TestFlight 时使用 Apple 的测试分发，每个构建最多可测 90 天，提前提供接续构建 | 通过家庭选定的文件通道传递同签名 APK |

长期日常使用由签名安装条件和 App 运行时离线能力共同决定。先在开发期用测试账号完成签名与安装，再在正式包上断开网络、USB 和调试器，从桌面重新打开，独立核验家长确认、积分落账、换装、备份与恢复。签名资格及实际设备可在第一次真机验收前集中落实，云端其他开发可先推进。

[Apple 个人账户签名期限](https://developer.apple.com/help/account/basics/about-your-developer-account/) · [Apple 会员费用](https://developer.apple.com/programs/whats-included/) · [注册设备与 Ad Hoc](https://developer.apple.com/help/account/provisioning-profiles/create-an-ad-hoc-provisioning-profile/) · [TestFlight 构建期限](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/) · [Android 应用签名](https://developer.android.com/studio/publish/app-signing)
