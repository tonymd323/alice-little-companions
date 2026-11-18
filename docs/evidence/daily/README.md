# 银杏家园家庭日用版 0.13.0+10

在手机浏览器登录有权访问私有仓库的 GitHub 账号，打开 APK 并选择「更新」。0.12.0 的安装文件继续保留。[下载日用版 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.13.0-android.apk?raw=true) · [签名与 SHA-256](installation.json) · [备份、覆盖与换机](../../BACKUP_MIGRATION.md)

## 在自己的小家里玩

| 从哪里进 | 可以做什么 |
|---|---|
| 小家 | 点「过来」、点地面、摸摸、抚过或长按伙伴。奶油的银杏叶舞卷起金叶，桃桃的月牙连跳有两次腾跃，团团踏云追风。伙伴自己会环顾、伸展和短距离走动。 |
| 家长入口、小事 | 家长自定义标准，孩子申报，家长确认后依投入类型发积分，并增加 1 共享经验。同日分别计数，3、10、20、35、55 经验触发五次进化。纠错重算有效经验，已经得到的外形保留。 |
| 成长 | 查看当前经验、下个门槛与确认手记。可回看已获得的进化。打开《银杏家园手记》读石桥的故事，以及三只伙伴的来历、愿望和当前外形。 |
| 主线 · 暖廊的彩窗 | 从石桥赴约，数出三扇窗需要多少叶片，再补齐缺少的金叶。回到暖廊可看到三扇窗上的叶花和地上金影。章后可拼十九片的进阶图案。重玩、换宠、读书和使用技能均不产生积分或经验。 |
| 家具、衣橱 | 逐件看入景效果、试穿，再决定兑换。旧家庭留在其他空间的摆件随各屋落点呈现。戴帽或系蝴蝶结时，可以同时戴眼镜、围巾并穿原有衣服。 |

## 美术对照

8 项可兑换装饰、家具及套装分别与两件免费陈设一起检查。另对暖廊、花园、树屋、甜品店和花店检查完整房间与组合陈设。Flutter 场景渲染覆盖 360 和 768 逻辑像素宽度，含旧家庭把可移动陈设留在其他房间的情况。[八项逐件对照](room-catalogue.jpg) · [五处组合陈设](five-rooms.jpg)

三宠六阶段有 54 幅原样、外套与围裙的腾跃画稿。帽子、蝴蝶结和围巾另有 18 幅物种与动作专用图。圆框眼镜按眼位绘制近远镜片和镜腿。将两种头饰分别与围巾和眼镜组合，覆盖 19 种日常或展翼姿态与 18 种腾跃姿态，共 74 次合成；检查瞳孔处的图像差异。[日常配饰对照](accessories-rest.jpg) · [腾跃配饰对照](accessories-flight.jpg) · [APK 内素材校验](packaged-art.json)

13 秒的动作对照使用应用内同一个庭院、暖廊与技能按钮。在 Flutter 渲染器中每 67 毫秒取一帧，以 15 帧/秒编成视频。依次看奶油追叶腾跃、戴围巾的桃桃连跳和系蝴蝶结的团团踏云。设备运行记录见下表。[观看三宠技能](three-skills.mp4) · [复现取帧的 Flutter 工具](../../../apps/mobile/tool/capture_companion_motion_test.dart)

## 安装包实测

这组操作在云端 Android 11 模拟器里用发布的签名 APK 完成。旧家庭与隔离测试家庭各用自己的存档。截图均来自 Android 合成画面。

| 操作 | 观察结果 |
|---|---|
| 飞行模式覆盖 0.12 | 安装包名、签名、Android UID 与首次安装时间一致。旧家庭仍是桃桃，余额 3 分、经验 1，免费家具在家。操作呼唤、摸摸、技能及外观预演，再杀进程打开，仍是 3 分与 1 经验。[升级后的家](upgraded-home.png) |
| 从主线修复彩窗 | 隔离家庭在 0 分、5 经验时从石桥赴约，答出 12 片和 5 片，走完三位伙伴相聚的结局。冷启动后窗花、地上金影及以前兑换的扶手椅还在，仍是 0 分、5 经验。[开篇](chapter-opening.png) · [结局](chapter-ending.png) · [窗户前后对照](window-before-after.jpg) · [重启后的暖廊](windows-lit.png) |
| 成长与进化 | 在同一隔离家庭，家长补录并确认五件同日轻量成果，获得 10 分和 5 经验。桃桃达到累计 10 经验时，从第二阶段变为第三阶段。重新打开后仍是 10 分、10 经验，扶手椅仍在。[达到门槛](earned-evolution.png) · [进化后冷启动](after-evolution.png) |
| 四项配饰与实际兑换 | 第三阶段桃桃在衣橱逐件试戴，重启后仍是 10 分、10 经验。随后家长确认一件轻量小事，余额升到 12 分、经验到 11。孩子用 12 分兑换圆框眼镜，当场戴上；冷启动回到暖廊仍戴着，余额为 0、经验 11。[四项试戴实拍](phone-accessories.jpg) · [确认兑换后](worn-glasses.png) · [戴回小家](home-glasses.png) |
| 阅读家园故事 | 在成长页进入《银杏家园手记》，读到世界观和奶油、桃桃、团团的来历、愿望及当前阶段。[开篇](world.png) · [团团的小传](companion-story.png) |

Android 系统录屏也保存了暖廊中的呼唤、抚摸、腾跃和家长确认后的进化。暖廊录屏在 21 秒内采到 25 帧，动作细节可结合上方逐帧对照观看。实体手机和 iPad 的帧率、启动耗时留给同版本真机测量。[暖廊交互录屏](android-warm-interactions.mp4) · [暖廊腾跃截图](android-leap.png) · [家长确认与进化录屏](earned-evolution.mp4)

全套 Flutter 自动化 40 项通过，静态分析通过。另用安装包校验程序逐项比对了 193 个素材标识。独立从 GitHub 取回 APK 的 76,202,122 个字节，与装机文件完全一致。[Flutter 测试](flutter-tests.log) · [静态分析](analyze.log) · [构建环境](preflight.json) · [构建日志](android-build.log) · [Android 操作记录](android-checks.log) · [GitHub 下载核对](github-download.json) · [对应源码标签](https://github.com/tonymd323/alice-little-companions/tree/alice-family-daily-v0.13.0)

## 复核

在源码根目录运行开发包校验，再从 Flutter 工程运行自动化测试。APK 验证工具按源码清单逐项核对发行包内的图片摘要、动作图尺寸与透明边缘。

```sh
python3 tools/validate_devpack.py
python3 tools/check_daily_release.py /path/to/alice-0.13.0-android.apk
cd apps/mobile
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub --reporter expanded
```

iPad 构建签名与安装、Android/iPad 两台真机互迁和真机性能需要提供 Mac、可用 Apple Team 和两台设备。亲密度与伙伴回忆、下一章数学剧情、其他学科及正式 Live2D 模型排在后续版本。[开发任务和验收计划](../../PLAN.md)
