# 《风过暖廊》交互与声音

[完整试玩，带声音](wind-veranda.mp4) · [两种补窗顺序的画面对照](wind-contact-sheet.jpg)

从起风、桃桃护围巾和推篮开始，先拿四片叶依次补远窗。桥的尽头亮起时，奶油在中段的缺口前等候。第五片补上中窗，光路接通，演出一直录到奶油到门口团聚。对照路线在正式页面点「静音」，先补中窗，奶油提前走到下一段桥。两条路线各使用一个新建的本地 SQLite 测试家庭。团圆时两家都亮起窗光，余额与经验均为 0，积分账本为空。[远窗先补的操作、声音与终值](far-first.json) · [静音中窗先补的操作与终值](middle-first.json)

| 查看位置 | 对应原帧 |
| --- | --- |
| 桃桃护围巾、推篮 | [护围巾](stills/scarf-contact.png) · [推叶篮](stills/basket.png) |
| 两种先后顺序 | [远窗亮起，中段有缺口](stills/far-light-gap.png) · [中窗先亮，奶油可以再走一段](stills/middle-path.png) |
| 奶油归家 | [过桥](stills/crossing.png) · [到门口](stills/homecoming.png) · [团圆](stills/reunion.png) |

## 画面与音轨的来源

两条路线都让 Flutter 运行应用内的 WindChapter 页面，沿用正式主题、字幕、绘图与家庭服务。通过页面上的叶篮和窗格接连点击十次。软件渲染器以每秒 15 帧的固定时钟推进动画，视口为 390 × 844 逻辑像素，以双倍像素采集。字形用本机 Noto CJK 字体，画面从应用标题栏开始。完整录像由 840 张无损原帧编码，时长 56 秒。画面对照裁取各原帧中的同一块插画区域，保留整页原图供比对。

开场第 8 帧与前爪刚触到围巾的第 41 帧可逐像素对照。以完整 PNG 左上为原点，屋顶横梁区域 x=78～701、y=130～249 的 74,880 个像素 RGB 完全相同。桃桃和脚下区域 x=31～457、y=715～1059 的 147,315 个像素里有 38,849 个像素至少一个 RGB 通道变化达到 8。连续原画中可同时看见机位、垂耳、前爪和围巾轮廓。[起风前](stills/opening.png) · [前爪接触围巾](stills/scarf-contact.png) · [低位推篮](stills/basket.png)

音轨取自正式页面送往原生音频通道的播放事件。将每次事件按游戏帧的时间映射到对应的七种原始双声道 WAV，同种声音重触时从头播放。静音路线从界面打开静音，全程播放请求数为零。手机麦克风收音、设备扬声器听感、原生回放延迟与设备帧率需对照设备实测。[声音混合参数](mix.json) · [关键源码、素材及证据的 SHA-256](capture-sha256.json)

## 源码对应关系

录制使用正式游戏版本 0.14.0+11。清单的 62 项源文件中，60 项运行时源码与素材逐字节匹配 `8ff42e4` 和交接提交 `c07f33b`。另外两项分别保留取帧时的 Dart 工具 `17db32c` 和成片编码时的 Python 工具 `3904f6c` 的真实文件散列。在 Git 中用 `git show 提交:路径` 取文件内容，即可对照清单所列 SHA-256。面向源码标签 `alice-wind-veranda-v0.14.0` 核验时，运行时文件对照该标签，两份历史工具分别对照清单中的独立提交。

本次远窗路线在首个测试进程完整记录 840 帧并通过本路线断言。同一个固定时钟测试引擎随后载入中窗路线时超时，保留了原始日志。中窗路线改为独立进程后从开场走到团圆，完整通过。交接提交 `c07f33b` 更新了 Dart 文件头的命令说明，并由 Python 自动分别启动两条路线。画面、手势时刻、声音混合与编码参数一致。[首个取帧进程的记录](capture-test.log) · [中窗独立进程的通过记录](middle-test.log) · [编码媒体探测](media-probe.json)

## 复现

需要仓库所用的 Flutter SDK、本机中文字体，以及含 Pillow、NumPy 和 FFmpeg 的环境。在仓库根目录运行。默认字体为 Linux 上的 Noto Sans CJK 和 Noto Serif CJK，可用 --font 和 --serif 指定本机文件。命令分别按测试名启动两个独立的 Flutter 测试引擎，避免上一条固定测试时钟影响下一次载入。

```sh
export ALICE_CAPTURE_DIR=/tmp/alice-wind-capture
cd apps/mobile
flutter pub get --enforce-lockfile
cd ../..
python3 tools/capture_wind_video.py --capture "$ALICE_CAPTURE_DIR"
```
