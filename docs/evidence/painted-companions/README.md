# 奶油的二维庭院动作

在小家穿地图背心、围巾、右耳蝴蝶结和眼镜。先点左侧草地，再点树屋边，最后走回近处。技能另录压身、腾跃、前爪接地和收坐。两段均取自 Flutter 庭院在 480 × 374 逻辑视口的原速 25 fps 实渲。 [庭院往返](fox-courtyard.mp4) · [银杏叶舞](fox-leap.mp4)

同机位独立复看，近前掌在 f082→083 与 f087→088 位移均为 0 px，前一轮分别滑动 5 px 和 6 px。第二次点地和远处收步时，尾巴留在同侧转过肩背。转身可见侧后画，正背方向均有交替步态。背向金色布结贴住耳侧，背心的左胁袋随身体转向。

转身走过约四分之一圈时仍能看见画面切换。远处回坐时耳尖在一帧内抬起约 15 个录制像素。技能落地比前一轮多出收掌过渡，最后抬胸仍有轻微跳变。本轮也复录了穿搭的团团一阶侧走和桃桃一阶低跳。Android 与 iPad 真机和正式发行待验。

Flutter 全量复跑通过 98 项。默认并发首跑有一次成长用例未等到待审任务，随后以 `--concurrency=3` 完整通过，原测试断言保留。衣橱保存、重开、小家「过来」及积分和经验检查均通过。

在 `apps/mobile` 复录。将 `OUTPUT` 和 `FONT` 分别替换为绝对输出路径和简体中文字体文件。技能用 `COURTYARD_RECORD_SKILL=true` 取代两个换向选项。

```sh
flutter test --no-pub tool/capture_courtyard_walk_test.dart \
  --dart-define=COURTYARD_FRAMES=OUTPUT --dart-define=ALICE_CJK_FONT=FONT \
  --dart-define=COURTYARD_COMPANION=fox --dart-define=COURTYARD_OUTFIT=coat-with-bow \
  --dart-define=COURTYARD_TURN_BACK=true --dart-define=COURTYARD_RETURN_FORWARD=true \
  --dart-define=COURTYARD_RECORD_CONTACTS=true
```
