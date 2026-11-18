# 银杏家园家庭日用版 0.13.0+10

在手机浏览器登录有权访问私有仓库的 GitHub 账号，打开 APK 并选择「更新」。0.12.0 的安装文件继续保留。[下载日用版 APK](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.13.0-android.apk?raw=true) · [签名与 SHA-256](installation.json) · [备份、覆盖与换机](../../BACKUP_MIGRATION.md)

## 在自己的小家里玩

| 从哪里进 | 可以做什么 |
|---|---|
| 小家 | 点「过来」、点地面、摸摸、抚过或长按伙伴。奶油的银杏叶舞卷起金叶，桃桃的月牙连跳有两次腾跃，团团踏云追风。伙伴自己会环顾、伸展和短距离走动。 |
| 家长入口、小事 | 家长自定义标准，孩子申报，家长确认后依投入类型发积分，并增加 1 共享经验。同日分别计数，3、10、20、35、55 经验触发五次进化。纠错重算有效经验，已经得到的外形保留。 |
| 成长 | 查看当前经验、下个门槛与确认手记。可回看已获得的进化。打开《银杏家园手记》读石桥的故事，以及三只伙伴的来历、愿望和当前外形。 |
| 主线 · 暖廊的彩窗 | 从石桥赴约，数清三扇窗的用途与金叶总数，补上缺少的叶片。家中出现三扇叶花与地上金影。章后可拼十九片的进阶图案。重玩、换宠、读书和使用技能均不产生积分或经验。 |
| 家具、衣橱 | 逐件看入景效果、试穿，再决定兑换。旧家庭留在其他空间的摆件随各屋落点呈现。戴帽或系蝴蝶结时，可以同时戴眼镜、围巾并穿原有衣服。 |

## 美术对照

8 项可兑换装饰、家具及套装分别与两件免费陈设一起检查。另对暖廊、花园、树屋、甜品店和花店检查完整房间与组合陈设。Flutter 场景渲染覆盖 360 和 768 逻辑像素宽度，含旧家庭把可移动陈设留在其他房间的情况。[八项逐件对照](room-catalogue.jpg) · [五处组合陈设](five-rooms.jpg)

三宠六阶段有 54 幅原样、外套与围裙的腾跃画稿。帽子、蝴蝶结和围巾另有 18 幅物种与动作专用图。圆框眼镜按眼位绘制近远镜片和镜腿。将两种头饰分别与围巾和眼镜组合，覆盖 19 种日常或展翼姿态与 18 种腾跃姿态，共 74 次合成；检查瞳孔处的图像差异。[日常配饰对照](accessories-rest.jpg) · [腾跃配饰对照](accessories-flight.jpg) · [APK 内素材校验](packaged-art.json)

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
