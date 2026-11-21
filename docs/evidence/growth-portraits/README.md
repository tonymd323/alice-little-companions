# 三只伙伴的成长画

从小家进入「成长」可以打开已取得的任一阶段。亲子确认成果达到门槛时会播放对应的进化。图画按相同画布与轮廓底边摆放。团团四阶段先收翼再展开，蓝眼、额纹和卷尾位置一致。已穿衣饰时使用该阶段的穿戴成画。

- 团团由 19 经验升到第 4 阶段。左图收翼，右图展翼。[成果入账后的游戏实渲](cat-fold-and-open.webp)
- 奶油到第 5 阶段，图上保留前四阶并新增金叶领。[成长记录](fox-earned-stages.webp)
- 桃桃到第 6 阶段，可以回看最初的垂耳和后来的飘带耳。[成长记录](rabbit-earned-stages.webp)

Flutter 测试在 390 和 360 逻辑像素宽视口上操作家长确认、成长记录与回看。三例均实际写入 5 分和 1 经验，随后重播无新增流水。独立审阅先盲排同尺寸颜色图和剪影，三组结果都正确。桃桃相邻耳形与团团二、三阶段的剪影仍需实体设备复看。

在 `apps/mobile` 复录。输出路径和字体文件使用绝对路径。

```sh
flutter test --no-pub test/growth_portraits_test.dart \
  --dart-define=ALICE_GROWTH_FRAMES=OUTPUT --dart-define=ALICE_CJK_FONT=FONT
```

从工作树根目录执行 `python3 tools/import_growth_portraits.py ../returns --cat-four ../returns/EV-01/app-growth/stage-four-wing-pair.png`。已核对 19 张运行图的画布、绘制范围、源图与输出 SHA-256。[素材清单](../../../design/asset_manifest.json)
