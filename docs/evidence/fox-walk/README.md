# 第一阶段奶油 · 0.16.0+14

候选包由 `e014029e0d19b34c3e68d666a1d7ed022ed1d67e` 构建，固定机位基线为 `fc19afe` 的 0.15.0+13。奶油使用 C 版原脸、栗红毛和浅色尾尖。站姿、腿段、正背两面和衣饰有独立画层。站起和坐回时尾尖稍晚跟上。急转经过中间站姿，四爪踩稳后再转向，两宠的步相都随实际路程推进。[四拍八姿与分层原稿](../../../design/production/fox-walk/README.md) · [无特效预演](../../../design/production/fox-walk/acting-rehearsal.mp4)

## 固定机位

同一庭院、点位、触发帧与无声原速采样，画面宽 960 像素，每 40 毫秒一帧。先对比静止背景，再用爪掌图层的实画像素在全景的 ±4 像素范围匹配。只统计能辨认的可见掌缘。被另一条腿盖住或达不到纹理匹配精度的画面没有测值。各段记录运行时落点和从同一足印量到的画面位移。[三种走动](three-walks.mp4) · [木梯与银杏叶](stairs-and-leaves.mp4) · [外套、围裙和配饰](wardrobe.mp4) · [逐段实测](measurements.json)

| 走动 | 候选帧 | 运行时承重段 | 可见承重段 / 帧对 | 最大二维偏移，运行 / 画面 |
|---|---|---:|---:|---:|
| 点草地 | 30–127 | 38 | 32 / 158 | 0 / 0 px |
| 过来 | 145–256 | 41 | 37 / 193 | 0 / 0 px |
| 自主走动 | 497–581 | 32 | 26 / 119 | 0 / 0 px |

木梯三段踏板及平台栏杆的样块连续 125 帧逐像素相同，梯上叶簇和树冠持续摆动。奶油转身时蝴蝶结跟随右耳。正脸轮廓在换面处短暂收窄，近纵向走动的侧脸与背头仍可看出分面切换。[独立试玩](independent.md)

## 自测与试玩

- 57 项 Flutter 回归通过，覆盖长短路线、近纵向点地、中途改向、抚摸收步、减少动态效果、旧存档、加密备份和前后成长账本。奶油与团团分别核对 36 种衣饰映射。候选录像目视复看奶油原装、外套搭帽子眼镜围巾、围裙搭蝴蝶结眼镜围巾。[静态分析](analyze.log) · [完整测试](flutter-tests.log)
- 独立试玩从 390 × 844 的正常小家入口进入庭院。点地、呼唤、自主走动和纵向点地都到达目标。将已购一件物品和含扣分流水的测试家庭关闭再重开，前后完整业务快照相同。[独立日志](independent.log) · [复核源码摘要](independent-source-sha256.txt)
- 团团固定机位从最终源码复录，核对完整画面、透明角色帧、落点和坐标表。[团团回归](cat-repeat.json)

## 安卓

0.16.0+14 云端试装包使用测试证书，核对 247 个日常资源 ID、58 个暖廊文件及 16 KiB APK 对齐。Android 9 x86_64 在飞行模式从 0.15.0+13 更新到首个 0.16.0 候选，再以最终包原位更新。两次均保留包 UID 和首次安装时间。最终安装的 APK 与交付文件字节一致。点草地、呼唤并结束进程再打开，测试家庭仍是奶油第一阶段、0 分、0 经验。[包及签名](installation.json) · [构建](build.log) · [日常素材](packaged-art.json) · [暖廊素材](packaged-wind.json) · [庭院](android-courtyard.png) · [点地与呼唤](android-move.jpg) · [重开后](android-reopened.png)

原家庭 APK 入口提供同签的 0.15.0，从 0.14.1 覆盖的记录已归档。0.16.0 家庭覆盖发布需要可用的原签名。iPad 安装需匹配的 Mac/Xcode、Apple Team 和 iPad，双向迁移还需安卓真机。[家庭覆盖实测](../cat-walk/family-upgrade.json) · [安装交接](../../DELIVERY.md)

## 复录

从基线和候选分别取代码。基线使用候选源码的同一取帧脚本。`OUTPUT` 与 `FONT` 为本机绝对路径。在两套源码的 `apps/mobile` 内执行。

```sh
flutter test --no-pub --dart-define=COURTYARD_FRAMES=OUTPUT \
  --dart-define=ALICE_CJK_FONT=FONT --dart-define=COURTYARD_COMPARE_GAIT=true \
  --dart-define=COURTYARD_COMPANION=fox tool/capture_courtyard_walk_test.dart
```

候选版额外加 `--dart-define=COURTYARD_RECORD_CONTACTS=true`，复录衣饰时分别加 `--dart-define=COURTYARD_OUTFIT=coat` 和 `--dart-define=COURTYARD_OUTFIT=apron`。在仓库根目录剪辑并测量。

```sh
python3 tools/review_companion_gait.py BEFORE AFTER OUTPUT FONT \
  --companion fox --coat COAT --apron APRON
```
