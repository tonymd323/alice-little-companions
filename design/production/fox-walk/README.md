# 第一阶段奶油 · 庭院步态

奶油保留 C 版的暖橙毛、栗红后掌、奶油尾尖和金圈额纹。侧脸与尾尖取原画纹理，补画了站起、四足慢走、正背转面和坐回时的体态。外套的琥珀色布料和圆扣、围裙的花袋和背结随姿态遮挡。[原画对照](reference.jpg) · [暖廊分层原稿](../wind/actors/fox-poses.ora) · [慢走分层稿](naiyou-walk.ora)

奶油先朝落点探身，四足撑起后沿地面慢走。两轮步态按近后、近前、远后、远前着地，尾尖在肩背之后回摆。收步时身体先停，爪子跟上，再换向坐回。样片使用固定地线、30 fps 和无特效原速播放，时长 4.7 秒。接触表实心点为着地爪，空圈为正在抬过的爪。[原速预演](acting-rehearsal.mp4) · [站姿、衣饰与四拍八姿](contact-sheet.jpg)

躯干、胸毛、尾巴、头与衣饰使用 512 × 464 画布，地线基准点为 (256, 440)。横向周期为 144 画布像素，纵深周期为 96 像素。八段腿图中的两个接点为 (64, 32) 与 (64, 128)，四爪中心 (64, 84) 经导出后对应实际可见掌缘。头部、服装及原坐姿的量测值保存在接触清单。[姿态与接点清单](poses.json)

改画时可在 Inkscape 编辑 SVG，或在 Krita、GIMP 查看十五组 OpenRaster 姿态。以下命令分别重导出图层、核对 27 张移动端 WebP、重录原速片。

```sh
python3 design/production/fox-walk/export_art.py
python3 design/production/fox-walk/export_art.py --check
python3 design/production/fox-walk/rehearse_art.py
```
