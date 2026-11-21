# 0.21.2 安卓更新复测

从 `0.21.1+20` 更新到 `0.21.2+21`。新版构建自 `ae09472`。测试清单和 APK 取自私有下载分支的同一提交 `d4b29d6`。APK 为 83,250,720 字节，SHA-256 为 `a91fda73a0f1c65995f2dd9ac314f61c1fd2ebc290eb274474ee376941c0e017`，新旧包均为原家庭证书签名。[APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.21.2-android.apk?raw=true) · [发布回执](../backup-export-performance/github-download.json)

使用旧版更新页、回环服务器和测试令牌，验证首次检查提示私库授权、发现新版、下载、SHA-256 校验、安卓授权返回后家长重新解锁。模拟的安装通道收到两次交接，文件摘要相同，只下载一次。已是 `0.21.2+21` 时检查无更新。[测试源码](published_update_0212_probe_test.dart) · [测试日志](download-test.log)

在 Android 9 x86_64 模拟器启用飞行模式，用 `0.21.1+20` 恢复同一份迁移测试合成档。把刚下载并校验过的 APK 复制到安卓 Downloads，再核对文件摘要。通过系统文件管理器打开 APK，在安卓安装器确认覆盖。冷启动后，应用 UID、首次安装时间、活动存储代与 30 张表的行数和内容摘要一致。家园仍有 5 分、一件待确认小事、团团 1 级 0 经验、奶油 3 级 16 经验，剧情和衣饰保持原样。[合成档核对](../roundtrip-0212/verification.json) · [系统安装提示](system-source-warning.png) · [安卓安装确认](system-update-confirmation.png) · [冷启动家园](cold-after-system-install.png) · [数据核对](system-update-result.json)

同一台模拟器在覆盖前后从正常家长入口打开「应用更新」，分别显示 `0.21.1` 和 `0.21.2`。设备侧的真实 GitHub 私库认证和双端真机仍待验收。[覆盖前](update-page-0.21.1.png) · [覆盖后](update-page-0.21.2.png) · [设备验收](../device-acceptance/README.md)

## 复测下载

从源码仓库执行。Git 需要读取私有下载分支的权限。测试通过后，`cache-handoff.apk` 为应用下载并校验过的文件。

```bash
alice_repo=$(git rev-parse --show-toplevel)
alice_probe=$(mktemp -d)
git fetch origin android-downloads
git show d4b29d6960052cc555174ee83a612cee74797fcd:downloads/latest.json > "$alice_probe/github-latest.json"
git show d4b29d6960052cc555174ee83a612cee74797fcd:downloads/alice-0.21.2-android.apk > "$alice_probe/github-0212.apk"
git worktree add --detach "$alice_probe/source" 772db06b8df394332a8aee1297ec05658ed5e66a
cp "$alice_repo/docs/evidence/android-update-0212/published_update_0212_probe_test.dart" "$alice_probe/source/apps/mobile/test/"
cd "$alice_probe/source/apps/mobile"
flutter pub get --enforce-lockfile
ALICE_UPDATE_FIXTURE_DIR="$alice_probe" \
  flutter test --no-pub --concurrency=1 --reporter expanded test/published_update_0212_probe_test.dart
cmp "$alice_probe/cache-handoff.apk" "$alice_probe/github-0212.apk"
```
