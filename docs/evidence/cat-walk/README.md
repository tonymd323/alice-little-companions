# 0.15.0+13 · 第一阶段团团步态

源码为 `9f9b51bc07af962b90600f09eda7fbd241679012`，对照基线为 `1dc9af6` 的家庭版 0.14.1+12。原装团团起身后交替迈步，依据实际走过的距离推进四拍，结束前收拢脚爪再坐下。转向有正面和背面画稿。衣饰随肩颈、头和眼位运动。[原装无特效预演](../../../design/production/cat-walk/acting-rehearsal.mp4) · [四拍八姿与分层源件](../../../design/production/cat-walk/README.md)

## 同机位原速录像

两版使用同一套庭院、衣饰状态、镜头、点地位置、按键时刻和等待顺序。Flutter 渲染器每 40 毫秒取一帧。960 像素宽的无损全景上保留小家控件，下排是同一块草地的放大画面。三种走动原速对比共 320 帧，木梯连续观察 125 帧。[点地、过来、自主走动](three-walks.mp4) · [木梯与树叶](stairs-and-leaves.mp4) · [外套、围裙和四款配饰](wardrobe.mp4)

| 操作 | 候选版无损帧 | 运行时承重段 | 可匹配的可见承重段 / 帧对 | 最大二维偏移，运行 / 画面 |
|---|---|---:|---:|---:|
| 点草地 | 30–119 | 35 | 33 / 170 | 0 / 0 px |
| 过来 | 145–249 | 38 | 36 / 197 | 0 / 0 px |
| 自主走动 | 497–573 | 29 | 26 / 132 | 0 / 0 px |

运行依据庭院原画坐标保留每只着地爪的位置。画面复核从每段可见爪底取带纹理的区域，在原始全景中做二维匹配。被其它腿遮挡或纹理不足的帧没有可测值。表内的画面位移覆盖成功匹配的帧对。木梯上、中、下三处踏板和栏杆的灰度样块连续 125 帧逐像素相同。梯上叶簇和树冠的样块均有可见移动。[逐段测量和样块坐标](measurements.json) · [独立复核](independent.md)

## 自测与试玩

| 范围 | 实测结论 |
|---|---|
| 四拍、锁足和操作 | PASS。长、短、斜和纵向路线按距离推进步相，改向与被摸停从当前爪位收步。点团团耳侧露出的草地可以向画面深处走。开启减少动态效果后，「过来」直接到达并给出文字回应。 |
| 衣橱 | PASS。检查 36 种合法搭配的资源。目视复看原装、外套搭帽子眼镜围巾、围裙搭蝴蝶结眼镜围巾。在转向与行进中检查镜片、耳根、颈毛及两套衣边。穿戴录像使用合成夹具。 |
| 独立试玩和重启 | PASS。使用 390 × 844 视口，从正式家庭入口切进庭院。无声原速复看并修复起坐重影和草地误触。三种走动及重开临时 SQLite 后，余额、共享经验、账本和物品一致。 |
| 双端真机 | BLOCKED。Android 家庭签名已核验。设备接入后在可签名安装的 iPad 与 Android 实体机上核对覆盖安装、帧耗时、加密文件回读及 Android ↔ iPad 双向迁移。 |

已知的表演细节是转向中偶尔会看到近前腿跨过另一条前腿。独立试玩确认能读出承重方向和收势。家长最终体验待验。[独立复核](independent.md) · [逐项验收](../acceptance.csv) · [备份换机](../../BACKUP_MIGRATION.md)

最终源码重录得到 517 张完整画面、517 张透明角色和两份坐标表，均与剪辑使用的原始素材逐字节相同。静态分析、53 项常规 Flutter 回归和 2 项独立正常入口回归均通过。完整回归曾发现抚摸回应延后，修复后团团会边收脚边转头回应。旧档升级、加密容器错误口令及 37 分夹具整套恢复均有测试结果。[重复录制](repeat.json) · [静态分析](analyze.log) · [Flutter 回归](flutter-tests.log) · [独立入口](independent.log)

## 安卓试装与家庭发布

0.15.0+13 由 Flutter 3.50.0、Dart 3.14.0、JDK 21.0.13 及 Android SDK 36 构建。APK 已验签，核对 220 个日常素材 ID 及 58 份暖廊剧情素材。此试装包使用本云电脑证书，SHA-256 以 `66c137a4` 开头。[构建结果](build.log) · [包与证书摘要](installation.json) · [已打包素材](packaged-art.json) · [暖廊素材](packaged-wind.json)

首次在另一台云电脑用测试证书覆盖，Android 9 返回 `INSTALL_FAILED_UPDATE_INCOMPATIBLE`，原安装仍是 0.14.1+12。该次探针的摘要保留在试装记录中。[旧家庭 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.14.1-android.apk?raw=true)

随后在发布 0.14.1 的原云端签名机构建同一份 `9f9b51b` 源码。两个家庭 APK 的包名和签名指纹逐字一致，版本号从 12 升至 13。新包 SHA-256 为 `734fb4bceba326777d5af503c9fa73a33a57d2c3bf7e21cb8a397bda2307c5d5`，核验了 220 个日常素材标识、58 份暖廊文件和 16 KiB 对齐。[家庭 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.15.0-android.apk?raw=true) · [包与证书摘要](family-package.json) · [新会话接续签名](../../DELIVERY.md#新会话接续安卓签名)

Android 9 模拟器在飞行模式下执行 `adb install -r` 成功。旧家庭的应用 UID 和首次安装时间相同。更新前、覆盖后进入小家、强制停止再次启动后，对测试家庭 SQLite 的 26 张业务表逐行计算摘要，三次结果一致。该家庭原有第一阶段桃桃、0 分、0 经验，暖廊的五处叶格与通关记录均保留。[覆盖与存档实测](family-upgrade.json) · [升级前的小家](family-before.png) · [冷启动后的小家](family-reopened.png)

下载分支提交为 `368e3c3`。从独立空 Git 仓库取回 81,323,760 字节的家庭 APK，SHA-256 和签名指纹与覆盖测试使用的文件一致。[GitHub 下载校验](family-github.json)

候选包在专用 Android 9 模拟器中全新安装成功。使用飞行模式从首次启动设置测试家庭，选第一阶段团团并从小家打开庭院。点地后团团到左侧草地，「过来」后走到右侧。强制停止并重开，暖廊仍显示第一阶段团团、0 分、0 经验与空小事列表。[安卓首次启动](android-first-run.png) · [安装版小家](android-courtyard.png) · [点地和过来](android-move.jpg) · [重开](android-reopened.png) · [包管理器证据](android-install.log)

## 复录

在 `1dc9af6` 和本轮源码各准备一份 Flutter 检出。基线使用本轮相同的取帧程序。`OUTPUT` 与 `FONT` 为取帧目录和本机中文字体的绝对路径。在两套源码的 `apps/mobile` 内执行。

```sh
flutter test --no-pub --dart-define=COURTYARD_FRAMES=OUTPUT \
  --dart-define=ALICE_CJK_FONT=FONT --dart-define=COURTYARD_COMPARE_GAIT=true \
  tool/capture_courtyard_walk_test.dart
```

候选版增加 `--dart-define=COURTYARD_RECORD_CONTACTS=true`，复录衣饰时分别增加 `--dart-define=COURTYARD_OUTFIT=coat` 和 `--dart-define=COURTYARD_OUTFIT=apron`。完成后在仓库根目录运行剪辑和测量。

```sh
python3 tools/review_cat_gait.py BEFORE AFTER OUTPUT FONT --coat COAT --apron APRON
```
