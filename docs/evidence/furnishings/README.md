# 家具与衣橱 · Android 家庭版 0.12.0+9

原家庭应用包名为 `local.family.alice_companions`，源码标签为 `alice-family-furnishings-v0.12.0`。打开已安装家庭版上的新 APK，选择「更新」即可沿用家庭数据。iPad 安装和实体机验证仍需签名设备。[Android 安装包](https://github.com/tonymd323/alice-little-companions/blob/android-downloads/downloads/alice-0.12.0-android.apk?raw=true) · [签名、文件大小和 SHA-256](installation.json) · [备份与换机](../../BACKUP_MIGRATION.md)

## 在自己的小家里查看

| 入口 | 可以看到什么 |
|---|---|
| 小家 → 家具 → 木质扶手椅 | 用「原样」和「看摆好效果」对照暖廊内的同一个位置。确认兑换后，回小家即可见。小花瓶在窗台，靠垫在窗座，叶子挂饰在梁下。 |
| 小家 → 衣橱 → 试穿衣服和配饰 | 杏色外套和花边围裙有各自的整身角色插画。选定伙伴后可直接试穿，两件衣服各需 25 分。确认兑换会给选定伙伴穿上，已有衣饰可在衣橱换下或重新穿上。 |
| 小家 → 空间 | 兑换花园、树屋、甜品店或花店后，进入即可看到画入该空间的陈设。原木小床会替换暖廊自带的午休小床；退款后免费小床重新出现。 |
| 已升级的旧家庭 | 已购家具自动呈现。曾摆在其他房间的单购家具留在原房间。退款该房间时，另购家具回到暖廊。已经给不同伙伴保存的搭配继续分别生效。 |

[暖廊实拍](home.png) · [扶手椅原样](armchair-before.png) · [摆好后的同一处](armchair-preview.png) · [桃桃原样](coat-before.png) · [桃桃穿杏色外套](coat-preview.png)

## 美术与测试依据

两件衣服分别绘入三位伙伴的六个阶段，并另绘云翼猫第四阶段的收翼与展翼姿态，共 38 张透明穿衣角色图。下列两张资料图按银杏狐、月牙耳兔和云翼猫排列，从左到右为一至六阶段。帽子、蝴蝶结、眼镜和围巾在角色纹理合成时贴合头、眼、颈部，随伙伴的呼吸、走动和招手反应一起运动。[杏色外套](coat-poses.jpg) · [花边围裙](apron-poses.jpg) · [素材摘要与尺寸](../../../design/asset_manifest.json)

自动化覆盖固定陈设、旧版跨房间家具归属、试穿及原样对照、同一命令重试、已购免重复收费、按伙伴保存搭配、退款和冷启动。37 分家庭夹具同时覆盖加密备份、迁移和恢复后继续记账。[测试输出](full-tests.log) · [静态分析](analyze.log) · [发行构建](android-build.log)

Android 11 云模拟器在飞行模式验证。应用升级使用与 0.11.0 相同的签名。最终安装包的文件摘要以安装信息为准。[升级与操作记录](android-upgrade.log) · [安装信息](installation.json)

本次完整 Flutter 测试 32 项通过，静态分析通过。从 GitHub 私有仓库新建浅克隆，读出的 APK 与装机包逐字节一致，共 72,353,716 字节。[GitHub 回读校验](github-download.json)
