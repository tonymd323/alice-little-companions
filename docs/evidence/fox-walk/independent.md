# 奶油第一阶段独立试玩

2026-11-19，运行源码 `e014029e0d19b34c3e68d666a1d7ed022ed1d67e`。在云端 Linux 的隔离副本使用 Flutter 3.50.0（`ab2912035e`）和 Dart 3.14.0。庭院取证 25 fps，原画预演 30 fps。先按原速观看，再查相邻帧。

| 正常入口用例 | 操作和结果 |
|---|---|
| 点草地、「过来」、自主走动、重新进小家 | 在 390 × 844 逻辑像素的 `CompanionsApp` 从暖廊切庭院。奶油横坐标从 186.26 到 41.86，再到 240.41，自主走动后停在 132.11。三次都坐回。关闭 SQLite 再重载后，余额 2、共享经验 2、一件物品、三条流水均一致，流水全行、衣橱、兑换记录和存档修订号也相同。 |
| 近纵向点地 | 点庭院深处 `(.422, .748)`，起点 `(.47, .937)`。逻辑像素位移为 (-28.88, -75.81)。到达两轴坐标后坐回，余额和经验均为 0。 |

两项在 `6da7c54`、`cb78609` 和 `e014029` 各自通过。[独立用例](test/fox_home_playtest.dart) · [最终日志](independent.log) · [主要源码 SHA-256](independent-source-sha256.txt)

## 画面观察

- 三种走动均能辨认臀部撑起、前后爪交替和收腿坐回。点地转向第 45–51 帧能看到前爪分开、正面支撑和下一侧落脚，尾尖在后胯后方回摆。帧号均来自原始庭院时钟，第 45 帧为 1.80 秒。[原速对照](three-walks.mp4)
- 外套加帽子、眼镜、围巾，帽檐贴额、镜框贴眼、袖口跟前肢。围裙加蝴蝶结、眼镜、围巾，裙沿和背结跟随躯干。初版在点地转向第 49→50 帧把蝴蝶结镜像到另一只耳朵。复修后，左向侧脸用较小的远耳结，仍在同一只右耳，第 126–128 帧坐回也保持在远耳。[穿戴原速片](wardrobe.mp4) · [左转连续帧](bow-turn.png)
- 近纵深夹具捕获 34 帧背向镜头的走动。背头右耳和转回侧脸的远耳佩戴同一个结。第 47→48 及 87→88 帧还能看出头部整张换面，耳饰随耳朵移到画面另一侧。[近纵深帧](bow-away.png) · [夹具](test/fox_bow_fixture_test.dart) · [夹具日志](independent-bow.log)
- 独立裁取原装第 234–358 帧的相同样块，木梯三个踏板和平台栏杆各 125 帧均与首帧完全一致。树冠和梯上悬叶各有 124 帧与首帧不同。[裁片结果](independent-environment.txt) · [庭院环境片](stairs-and-leaves.mp4)

## 复跑

`REPO` 设为仓库绝对路径。命令将同一提交的应用与锁文件导至临时目录，再放入独立用例。Flutter 测试运行器使用本机回环端口。离线复跑使用已经下载并校验的 `sqlite3` 3.9.1 原生缓存。

```sh
WORK=$(mktemp -d)
git -C "$REPO" archive e014029 apps/mobile/lib apps/mobile/assets \
  apps/mobile/pubspec.yaml apps/mobile/pubspec.lock apps/mobile/test/support/families.dart \
  | tar -x -C "$WORK" --strip-components=2
cp "$REPO"/docs/evidence/fox-walk/test/*.dart "$WORK/test/"
cd "$WORK"
sha256sum --check "$REPO/docs/evidence/fox-walk/independent-source-sha256.txt"
flutter pub get --enforce-lockfile
flutter test --no-pub --reporter expanded test/fox_home_playtest.dart test/fox_bow_fixture_test.dart
```
