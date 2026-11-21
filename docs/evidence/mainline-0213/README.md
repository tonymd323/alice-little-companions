# 0.21.3 数学主线与伙伴回忆

在 Linux x86_64 上用 Flutter 3.50.0 运行候选版构建源码 `27c38ac41461720defcca73d848ca81cf1f18b32`，调试视口为 390 × 844。测试直接操作小家、主线及成长页，使用独立的合成家庭和 SQLite 存档。起始余额为 3 分，团团为 1 级、1 经验，桃桃为 2 级、6 经验，账本有 8 笔流水。[构建与安装包](../backup-ui-0213/README.md) · [静态分析](analyze.log)

从「主线 · 风过暖廊」取叶补好五格，看到团聚结局并返回小家，再打开《奶油的雨天地图》。少踩石板就盖印和先点第三块均出现提示。第一段踩过两块后退出，重开后显示第三块是下一步。四段各用三块石板盖一枚爪印，走过十二块后看到桃桃回家的结局。近路铺 8 块和 10 块均出现纠错提示，调整为 9 块后通关。[中途续玩](rain-resumed.png) · [操作记录](tests.log)

摸摸团团和呼唤的两件回忆在「成长 → 伙伴回忆」与两章故事、四枚爪印一起保留。团团为默契，桃桃为初见。重玩第二轮踩第一块后再次重开，可以继续第二块，原结局与近路成绩保留。全过程余额为 3 分，两只伙伴的等级与经验、8 笔流水和流水摘要均一致。[伙伴回忆](companion-memories.png) · [重玩续接](rain-replay.png) · [逐步核对](verification.json)

用这次试玩的实际存档生成普通加密备份，回读后在独立测试目录恢复。解密预览与恢复后的业务摘要一致，两章进度、近路、重玩书签、亲密度与两只伙伴各自的经验一并读回。实体设备的系统文件和双向迁移按设备验收记录执行。[恢复摘要](verification.json) · [设备验收](../device-acceptance/README.md)

## 复测

在仓库根执行。当前云端的测试字体位于 `/workspace/scratch/alice-rain-qa-evidence`。测试使用该目录的 `qa-Regular.otf` 和 `qa-Bold.otf`，以及系统 Noto CJK 字体，生成截图与业务核对记录。[测试源码](mainline_0213_probe_test.dart)

```bash
alice_repo=$(git rev-parse --show-toplevel)
alice_run=$(mktemp -d)
git worktree add --detach "$alice_run/source" 27c38ac41461720defcca73d848ca81cf1f18b32
cp "$alice_repo/docs/evidence/mainline-0213/mainline_0213_probe_test.dart" "$alice_run/source/apps/mobile/test/"
cd "$alice_run/source/apps/mobile"
flutter pub get --enforce-lockfile
ALICE_STORY_EVIDENCE="$alice_run" \
  ALICE_STORY_FONTS=/workspace/scratch/alice-rain-qa-evidence \
  flutter test --no-pub --concurrency=1 --reporter expanded test/mainline_0213_probe_test.dart
```
