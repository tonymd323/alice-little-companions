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

独立试玩者先观看成片，再选取另外三处踏板样块，每隔两帧与首帧比较。修复后的 62 次比较中，三处踏板和平台栏杆均静止，两处树叶均有变化。另以草地作参照检查前爪，在第 53→55、116→118、469→471 帧分别看到了向左约 11、向右约 21、向左约 18 像素的掌缘移动。这里每对画面相隔 80 毫秒。手机或 iPad 的实际帧率仍需真机测量。

49 项常规 Flutter 测试和 1 项固定镜头取帧检查全部通过，静态分析通过。独立重跑最终取帧程序，372 张完整场景、372 张透明角色及全部坐标与交付录像使用的原始序列逐字节一致。测试日志保留了与基线相同的 Drift 多实例调试提示。[完整测试](flutter-tests.log) · [静态分析](analyze.log) · [重复取帧校验](repeat.json)

Android 9 云端模拟器在飞行模式下从 0.14.0+11 覆盖至 0.14.1+12，签名、应用 UID 和首次安装时间一致。冷启动时系统的同步等待曾超时，随后实际画面与界面树都能确认进入小家，并在庭院选到第一阶段团团。APK 和两段 MP4 已从 GitHub 新检出并逐字节核对。[下载安卓补丁](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.14.1-android.apk?raw=true) · [安装版庭院实拍](android-courtyard.png) · [覆盖记录](android-smoke.json) · [签名与摘要](installation.json) · [GitHub 取回校验](github-download.json)

发布构建另核对了 APK 内的 193 项日常素材标识，以及暖廊剧情所用的 58 个文件。[构建日志](build.log) · [日常素材](packaged-art.json) · [剧情素材](packaged-wind.json)

分别在基线和补丁的 `apps/mobile` 中运行下列命令。基线使用补丁中的同一份取帧程序。把 `OUTPUT` 换成本次帧目录的绝对路径，`FONT` 换成本机中文字体文件。两次完成后，在补丁仓库根目录执行最后一条命令。

```sh
flutter test --no-pub --dart-define=COURTYARD_FRAMES=OUTPUT --dart-define=ALICE_CJK_FONT=FONT tool/capture_courtyard_walk_test.dart
python3 tools/review_courtyard_motion.py BEFORE AFTER OUTPUT_VIDEO_DIR FONT
```
