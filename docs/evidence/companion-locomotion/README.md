# 小家里的伙伴移动

同一庭院、同一机位，从小家点左侧同一块草地。Flutter 实渲逻辑视口 480×374，取帧为 960×748，25 fps。旧版使用本批配饰接入后的 `575e732`。原速对照左侧为旧版，右侧为本分支。

[团团与奶油前后对比](cat-and-fox-before-after.mp4) · [完整走到并坐稳](cat-and-fox-arrival.mp4) · [背向走动](back-turn.webp) · [桃桃前后对比](rabbit-before-after.mp4) · [团团四阶段展翼](fold-and-fly.mp4)

| 录制对象 | 实渲结果 |
| --- | --- |
| 团团、奶油第一阶段 | 全身画一次成形。用不同姿态表现前爪迈出、后爪跟上、正向和背向转身。原装和穿搭都到相同的草地点，镜头继续录到坐稳。团团 f115、奶油 f117 起结束走动。 |
| 桃桃第一阶段 | 旧版坐姿连续滑行。新版分两次低跳，每次先压身再移动，前爪在收坐前后保持同一片草地。接地后放下耳朵时仍能看到一处快切。 |
| 团团第三、四阶段 | 三阶段转向时前爪保持完整轮廓，侧向换面仍可见。四阶段原装有收翼、舒展、起跳和前爪承接，蓝眼全程一致。旧身体服饰的专用同色展翼姿态待补。 |

独立复看在团团 f070→071 和奶油 f084→085 找到支撑爪沿草纹滑动。调整爪区装配后，用同一局部的轮廓和毛色匹配复查，上述两组的偏移约从 5 降到 1 个 2× 录制像素。团团 f080→081 约从 6 降到 3 个像素。两只幼年伙伴从偏正向切到侧向时，尾巴换边仍有可见的切画。另在同一庭院先点左侧地面，坐定后再点树屋方向，验证背向原画进入连续镜头并在远处坐稳。

第一阶段团团的五张侧向姿态来自 MO-01 的透明源板，奶油侧向姿态和两只伙伴的正、背向由 Codex 内置 ImageGen 按游戏原画生成。四阶段蓝眼短飞使用同法补了半展翼、飞姿和前爪承接。文件来源、裁切坐标、运行尺寸及摘要由[素材清单](../../../design/asset_manifest.json)记录。桃桃收腿与前爪承接来自 MO-02 透明源板。

全部 93 项 Flutter 测试通过。复核覆盖三只伙伴六个阶段的点地到达。另验证呼唤、减弱动态效果、技能打断后先落地再移动、花店架脚边界和衣饰保存后进入小家。Android 和 iPad 实体设备仍待验收。穿搭与全部朝向的原速表演也要继续逐项复看。

在 `apps/mobile` 复录同机位，`OUTPUT` 和 `FONT` 为绝对路径。使用 `COURTYARD_COMPANION=fox`、`rabbit` 或 `COURTYARD_STAGE=4` 可切换测试伙伴与形态。

```sh
flutter test --no-pub tool/capture_courtyard_walk_test.dart \
  --dart-define=COURTYARD_FRAMES=OUTPUT --dart-define=ALICE_CJK_FONT=FONT \
  --dart-define=COURTYARD_SHORT_APPROACH=true --dart-define=COURTYARD_RECORD_CONTACTS=true \
  --dart-define=COURTYARD_COMPANION=cat
```
