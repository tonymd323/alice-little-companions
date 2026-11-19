# 第一阶段桃桃 · 庭院基线

0.16.0+14，运行源码 `e014029`。在 480 × 374 逻辑像素的同一庭院机位录原装桃桃，原始画面为 960 × 748，25 fps。现有三种移动都由常态画网格形变与地面位移组成。后续原画先区分后腿蓄力、腾空折腿、前爪接地及后爪收跟，耳尖在身体落稳后回位。[原速基线](before.mp4) · [逐帧坐标](positions.csv)

| 触发 | 原始运动帧 | 逻辑坐标起点 → 终点 |
|---|---:|---|
| 点左侧草地 | 30–68 | (225.60, 299.84) → (110.40, 265.60) |
| 过来 | 145–188 | (110.40, 265.60) → (268.80, 276.48) |
| 自主走动 | 497–527 | (268.80, 276.48) → (182.40, 278.40) |

三个动作在原速片中依次出现，每段包含前后各八帧。原画取第一阶段 C 版常态和技能腾跃，暖廊的分层稿供研究长耳惯性及围巾落位。[第一阶段常态](../../../apps/mobile/assets/art/rabbit-1.webp) · [第一阶段技能](../../../apps/mobile/assets/art/leap-rabbit-1.webp) · [暖廊桃桃分层](../../../design/production/wind/actors/rabbit-poses.ora)

在 `apps/mobile` 重录，`OUTPUT` 与 `FONT` 为本机绝对路径。

```sh
flutter test --no-pub --dart-define=COURTYARD_FRAMES=OUTPUT \
  --dart-define=ALICE_CJK_FONT=FONT --dart-define=COURTYARD_COMPARE_GAIT=true \
  --dart-define=COURTYARD_COMPANION=rabbit tool/capture_courtyard_walk_test.dart
```
