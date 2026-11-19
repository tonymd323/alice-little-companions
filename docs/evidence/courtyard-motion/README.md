# 小家 · 木梯和第一阶段团团

左屏是家庭版 0.14.0+11（`f5afeeb`），右屏是 0.14.1+12。两次都用 Flutter 的小家组件加载正式庭院、前景、第一阶段团团和同一套操作。图像由 Flutter 渲染器按每秒 25 帧离屏取样。两侧的镜头、时钟和触发帧一致。下排放大的是同一块固定地面。[木梯与树叶 · 5 秒](courtyard-stairs.mp4) · [点地、过来、自主走动 · 7.8 秒](cat-three-walks.mp4)

## 木梯

原先第二块风区包住树屋楼梯。补丁把这块风区收进梯子上方的一簇银杏叶，最后一排受风的网格顶点与最高踏板之间留有固定顶点。树冠继续沿用原来的风区。[庭院原画](../../../apps/mobile/assets/art/garden.webp) · [庭院风区](../../../apps/mobile/lib/illustration/animated_backdrop.dart)

在 960 像素宽的原始小家画面上连续跟踪 125 帧。表中是同一细节水平位置的最大值与最小值之差。

| 跟踪位置 | 修改前 | 修改后 |
|---|---:|---:|
| 上段踏板 | 9 px | 0 px |
| 中段踏板 | 13 px | 0 px |
| 下段踏板 | 3 px | 0 px |
| 梯子上方的叶簇 | 4 px | 4 px |
| 上方树冠 | 18 px | 18 px |
| 平台栏杆 | 0 px | 0 px |

修复后三处踏板的灰度样块在全部 125 帧中与各自首帧完全相同。另在单独渲染的 768 × 512 庭院底画上，覆盖木梯的 123 × 117 像素矩形在 0.63、1.57、2.98 和 4.37 秒相对起始帧均有 0 个 RGBA 像素变化。相同测试在旧版的第一个时刻检测出 11,783 个像素变化。

## 团团的脚步

取帧依次点左侧草地、点「过来」，随后让小家自行运行。在最后一次触屏约 14 秒后，团团自行往左走。三段都采到了实际的坐标变化。普通走动继续使用整张坐姿画和局部网格形变。[触发与位移](../../../apps/mobile/lib/illustration/living_scene.dart) · [爪部绘制](../../../apps/mobile/lib/illustration/puppet.dart)

三种走动都能看到爪子贴近草地时身体继续前移。逐帧测量中，朝前白爪的掌缘在相邻两个低位画面间的最大横移分别为 6.9、13.8 和 10.0 个原始画面像素，每对画面相隔 40 毫秒。修改前后的 372 幅透明角色取帧和完整位置记录分别一致。这三项保留为待补画的日常步态。

一阶段有日常、腾跃两种姿势，各有原装、外套和围裙，六张 WebP 均为单帧。角色设定板和原 Demo 提供同一坐姿。已查阅可见 Git 历史、未打包的美术稿及五份 OpenRaster 分层源稿。暖廊的 `fox_run1` 至 `fox_run4` 画的是银杏狐。[坐姿](../../../apps/mobile/assets/art/cat-1.webp) · [腾跃](../../../apps/mobile/assets/art/leap-cat-1.webp) · [角色设定板](../../../design/references/pet-stages.png) · [暖廊角色源稿](../../../design/production/wind/actors/README.md)

| 需补画的姿态 | 画面要交代的动作 |
|---|---|
| 起步 | 从已有坐姿撑起前身，后爪收至胯下，进入四足站姿，再移重心抬第一只爪。 |
| 慢走循环 | 按近后爪、近前爪、远后爪、远前爪的四拍顺序绘制。每拍各画一张新爪落地承重和一张另一只爪抬起经过，共八张。 |
| 停步 | 最后一步减速，后爪跟上，四爪站稳，重心后移坐回。 |

各张沿用幼猫的比例、视角、透明画布与同一地面线。标出四个爪垫的触地点、各自承重的起止帧、身体基准点及一周期走过的距离。接入后用实际移动距离推进步相，逐帧核对承重爪的庭院坐标。

## 复核

取帧程序同时保存完整小家画面、透明角色和位置记录。对比工具从原始无损帧跟踪踏板、叶簇和平台上的绘画细节。它另在透明角色上取朝前白爪的掌缘，按实际朝向和位置换算成庭院像素。连续两帧都在静止参考轮廓的 4 像素以内时，才计入低位样本。当前素材没有定义承重区间，所以这里只能测可见掌缘的横移。[逐项测量](measurements.json) · [木梯回归测试](../../../apps/mobile/test/courtyard_wind_test.dart) · [取帧程序](../../../apps/mobile/tool/capture_courtyard_walk_test.dart) · [取样与剪辑程序](../../../tools/review_courtyard_motion.py)

分别在基线和补丁的 `apps/mobile` 中运行下列命令。基线使用补丁中的同一份取帧程序。把 `OUTPUT` 换成本次帧目录的绝对路径，`FONT` 换成本机中文字体文件。两次完成后，在补丁仓库根目录执行最后一条命令。

```sh
flutter test --no-pub --dart-define=COURTYARD_FRAMES=OUTPUT --dart-define=ALICE_CJK_FONT=FONT tool/capture_courtyard_walk_test.dart
python3 tools/review_courtyard_motion.py BEFORE AFTER OUTPUT_VIDEO_DIR FONT
```
