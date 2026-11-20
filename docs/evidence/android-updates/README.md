# 0.18 安卓应用更新

应用版本 `0.18.0+16`，Android release 构建提交 `4a54fb6cfb0337dcf57331a37b8a2e184037e98a`。APK 沿用原家庭版证书。首次从 GitHub 覆盖安装后，可在「家长入口 → 应用更新」检查下一版。[安卓 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.18.0-android.apk?raw=true) · [安装与授权](../../DELIVERY.md#app-内更新)

公开 GitHub 仓库可匿名检查。当前 APK 在原私有分支发布。版本请求优先使用设备已配置的只读令牌，未配置时直接匿名查询。遇到仓库访问拒绝时提示本机录入。令牌仅发送给 GitHub API 同源请求，保存在设备安全存储中。文件下载完毕后才进入 SHA-256、包名、签名和递增版本校验。

Flutter 静态分析与 75 项正常回归通过，其中 7 项覆盖新更新流程。HTTP 测试使用回环服务器，验证公开匿名请求、私有凭据请求、拒绝越界重定向、保存前散列校验和取消。Widget 验证下载准备期间取消、私库授权提示、安卓授权返回后缓存不在时重试。Dart 运行代码与构建提交一致。Android 9、10 的原生兼容修复使用旧标志触发证书采集，后续继续比较当前签名集合。[分析日志](analyze.log) · [全部测试](flutter-tests.log) · [Android 9 归档读证书实现](https://github.com/aosp-mirror/platform_frameworks_base/blob/android-9.0.0_r1/core/java/android/content/pm/PackageManager.java#L4400-L4421)

真实家庭 GitHub 账号的只读令牌由家长在本机配置。测试使用模拟 GitHub 响应与实际 GitHub 构建文件校验，不需要家庭凭据。iPad 更新沿用 Apple 签名方式。[私库设置](../../DELIVERY.md#app-内更新) · [离线补测](../family-offline/README.md)

Android 9 API 28 模拟器使用同签的测试入口，保留原 0.17 合成家庭。入口通过正式原生通道读取候选包，拒绝版本号相同的 APK 和同包名的另一个证书签名 APK。原证书的 `0.18.0+16` 打开安卓授权设置，在系统中允许安装并点击确认。安装完成后冷启动，从家园读出原有桃桃。新旧数据代和 28 张表的摘要完全一致，全程保留飞行模式。此环节从测试缓存提供正式 APK；HTTP 下载及取消由前述接口测试覆盖。[原生测试入口](installer_probe.dart) · [拒绝同版本](native-old-version-rejected.png) · [拒绝异签](native-wrong-signature-rejected.png) · [安装来源授权](native-install-permission.png) · [系统确认](native-system-installer.png) · [覆盖后家园](native-updated-home.png) · [数据摘要](native-handoff-result.json)

安装包与 `latest.json` 同批提交到 `android-downloads` 的 `7002b80`。独立 Git 副本重新取回两份文件，版本记录逐字一致，APK 长度和 SHA-256 与构建结果一致。[GitHub 下载核对](github-018-receipt.json) · [构建包回执](package.json)

覆盖后的正式包在飞行模式下通过家长 PIN 打开「应用更新」，正确显示当前版本和检查按钮。[正式包更新入口](native-update-page.png)
