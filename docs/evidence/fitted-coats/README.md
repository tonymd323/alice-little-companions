# 苔绿地图背心与双开衩短披肩

奶油一阶段与团团四阶段用同一件已拥有的外套试穿、保存、关开 App，再到小家「过来」。团团也走了成长页的「回看进化」。无新兑换、积分流水或成长经验变动。衣橱和成长页截自 390×844 逻辑视口，庭院为 480×374 的 Flutter 组件实渲，每 40 ms 一帧。视频用原速 25 fps。

| 伙伴 | 衣橱和成长 | 庭院 |
| --- | --- | --- |
| 奶油 | [原样加围巾、背心加围巾](fox-wardrobe.webp) | [点地行走及换向](fox-walk-and-turn.mp4) · [银杏技能](fox-skill.mp4) · [左胁地图袋](fox-left-side.webp) |
| 团团 | [原样、收翼和回看进化展翼](cat-wardrobe-and-evolution.webp) | [点地朝庭院深处短飞](cat-wing-cape.mp4) · [背侧展翼](cat-rear-flight.webp) |

独立审阅复查了奶油正面有结、侧行贴住颈根、背向只露后领和左袋。技能中围巾后缘与马甲肩片仍较接近。团团背向可辨两翼各出一衩及一枚背扣，侧背切换与承接时仍能看到姿态切画。两次点地间的转向、服装持久化和积分检查通过。移动端 95 项 Flutter 测试通过。真机、家长验收和签名发布待测。

在 `apps/mobile` 复录。用实际存在的绝对输出路径替换 `OUTPUT`，用支持简体中文的字体文件替换 `FONT`。

```sh
flutter test --no-pub test/fitted_coats_test.dart \
  --dart-define=ALICE_COAT_FRAMES=OUTPUT

flutter test --no-pub tool/capture_courtyard_walk_test.dart \
  --dart-define=COURTYARD_FRAMES=OUTPUT --dart-define=ALICE_CJK_FONT=FONT \
  --dart-define=COURTYARD_COMPANION=fox --dart-define=COURTYARD_OUTFIT=coat-with-scarf \
  --dart-define=COURTYARD_TURN_BACK=true

flutter test --no-pub tool/capture_courtyard_walk_test.dart \
  --dart-define=COURTYARD_FRAMES=OUTPUT --dart-define=ALICE_CJK_FONT=FONT \
  --dart-define=COURTYARD_STAGE=4 --dart-define=COURTYARD_OUTFIT=coat \
  --dart-define=COURTYARD_DEEP_APPROACH=true
```

奶油录技能时使用 `COURTYARD_RECORD_SKILL=true` 替换 `COURTYARD_TURN_BACK=true`。从生产目录重导运行资源和母稿时，使用 `python3 tools/import_fitted_coats.py ../returns --rear ../returns/CL-02/r02-openai/app-fitted/rear-cloud-hop.png --masters ../returns`。清单中的 SHA-256 与尺寸已复核，25 份 ORA 逐层重组与合并图像素一致。
