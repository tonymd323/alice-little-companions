import 'package:material_ui/material_ui.dart';

import '../application/controller.dart';
import '../application/family.dart';
import '../domain/companion_food.dart';
import '../domain/companions.dart';
import '../domain/layout_rules.dart';
import '../domain/rules.dart';
import '../illustration/accessory_poses.dart';
import '../illustration/tailoring.dart';
import 'common.dart';
import 'food_card.dart';
import 'garden.dart';
import 'parent_access.dart';
import 'spaces.dart';

const _tiers = {
  'small': '小装饰',
  'accessory': '配饰',
  'single': '家具与衣服',
  'bundle': '主题套装',
  'zone': '功能区',
  'shop': '店铺',
};

enum CatalogSection {
  all('成果兑换'),
  food('食物'),
  furniture('家具图册'),
  clothes('衣服与配饰');

  const CatalogSection(this.title);
  final String title;
}

class CatalogPage extends StatefulWidget {
  const CatalogPage({
    super.key,
    required this.controller,
    this.section = CatalogSection.all,
    this.model,
    this.modelStage,
  });
  final CatalogSection section;
  final Companion? model;
  final int? modelStage;
  final FamilyController controller;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late Future<List<Json>> history = loadHistory();

  Future<List<Json>> loadHistory() => widget.section == CatalogSection.food
      ? Future.value(const [])
      : widget.controller.service!.purchases();

  void reloadHistory() {
    if (!mounted) return;
    final purchases = loadHistory();
    setState(() {
      history = purchases;
    });
  }

  int get _modelStage {
    final family = widget.controller.family!;
    return widget.modelStage ??
        (widget.model == null || widget.model == family.companion
            ? family.stage
            : 0);
  }

  Companion get _model => widget.model ?? widget.controller.family!.companion;

  FittedCoat? _coat(Json product) =>
      fittedCoat(_model, _modelStage, product['asset_id'] as String);

  String _thumbnail(Json product) {
    final asset = product['asset_id'] as String;
    return _coat(product)?.thumbnail ??
        fittedAccessoryThumbnail(asset, _model, _modelStage) ??
        artworkPath(asset);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: Text(widget.section.title),
        actions: [
          Center(child: PointsPill(widget.controller.family!.balance)),
          const SizedBox(width: 12),
        ],
      ),
      body: PageBody(
        maxWidth: widget.section == CatalogSection.food ? 520 : 1050,
        child: FutureBuilder(
          future: history,
          builder: (context, snapshot) {
            final owned = (snapshot.data ?? <Json>[])
                .where((p) => p['refunded_at'] == null)
                .map((p) => p['item_id'])
                .toSet();
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final groups = switch (widget.section) {
              CatalogSection.all => _tiers,
              CatalogSection.food => const <String, String>{},
              CatalogSection.clothes => const {
                'single': '衣服',
                'accessory': '配饰',
              },
              CatalogSection.furniture => const {
                'single': '家具',
                'small': '窗边小物',
                'bundle': '主题套装',
                'zone': '功能区',
                'shop': '店铺',
              },
            };
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    await openPage(
                      context,
                      PurchaseHistoryPage(controller: widget.controller),
                    );
                    if (widget.section != CatalogSection.food) reloadHistory();
                  },
                  label: const Text('我的兑换'),
                  icon: const Icon(Icons.inventory_2_outlined),
                ),
                if (widget.section == CatalogSection.all ||
                    widget.section == CatalogSection.food) ...[
                  if (widget.section == CatalogSection.all) ...[
                    const SizedBox(height: 18),
                    Text('食物', style: Theme.of(context).textTheme.titleLarge),
                  ],
                  const SizedBox(height: 10),
                  _FoodShelf(controller: widget.controller),
                ],
                for (final tier in groups.entries) ...[
                  const SizedBox(height: 18),
                  Text(
                    tier.value,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, box) {
                      final columns = box.maxWidth >= 790
                          ? 4
                          : box.maxWidth >= 520
                          ? 3
                          : 2;
                      final width =
                          (box.maxWidth - 10 * (columns - 1)) / columns;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final product
                              in widget.controller.rules.catalog.values.where(
                                (item) =>
                                    item['tier'] == tier.key &&
                                    (widget.section == CatalogSection.all ||
                                        (item['slot'] != null) ==
                                            (widget.section ==
                                                CatalogSection.clothes)),
                              ))
                            SizedBox(
                              width: width,
                              child: _RewardTile(
                                name:
                                    _coat(product)?.nameInWardrobe ??
                                    product['name'] as String,
                                price: product['price'] as int,
                                imagePath: _thumbnail(product),
                                owned: owned.contains(product['id']),
                                onTap: () async {
                                  await openPage(
                                    context,
                                    RewardPage(
                                      controller: widget.controller,
                                      product: product,
                                      model: widget.model,
                                      modelStage: widget.modelStage,
                                    ),
                                  );
                                  reloadHistory();
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _FoodShelf extends StatelessWidget {
  const _FoodShelf({required this.controller});

  final FamilyController controller;

  Future<void> redeem(
    BuildContext context,
    CompanionFood food,
    FoodOffer offer,
  ) async {
    final remaining = controller.family!.balance - offer.price;
    final confirmed = await confirmChoice(
      context,
      '兑换${food.label}？',
      '花费 ${offer.price} 分，兑换后剩余 $remaining 分。喂食后亲密度 +${offer.affinity}。',
      '确认兑换',
    );
    if (!confirmed || !context.mounted) return;
    await controller.service!.redeemFood(food);
    await controller.refresh();
    if (context.mounted) showNotice(context, '已兑换${food.label}');
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final MapEntry(key: food, value: offer)
          in controller.rules.foodOffers.entries)
        Padding(
          key: ValueKey(food),
          padding: const EdgeInsets.only(bottom: 8),
          child: FoodCard(
            food: food,
            affinity: offer.affinity,
            action: ActionButton(
              label: '用 ${offer.price} 分兑换',
              enabled:
                  !controller.service!.frozen &&
                  controller.family!.balance >= offer.price,
              action: () => redeem(context, food, offer),
            ),
          ),
        ),
    ],
  );
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.owned,
    required this.onTap,
  });
  final String name, imagePath;
  final int price;
  final bool owned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: cream,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: outline),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 95,
              width: double.infinity,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
            const SizedBox(height: 9),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(
              owned ? '已拥有' : '$price 分',
              style: const TextStyle(color: terracotta),
            ),
          ],
        ),
      ),
    ),
  );
}

class RewardPage extends StatefulWidget {
  const RewardPage({
    super.key,
    required this.controller,
    required this.product,
    this.model,
    this.modelStage,
  });
  final Companion? model;
  final int? modelStage;
  final FamilyController controller;
  final Json product;

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  FamilyService get service => widget.controller.service!;
  String get id => widget.product['id'] as String;
  Companion get pet => widget.model ?? widget.controller.family!.companion;
  String _name(int stage) =>
      fittedCoat(
        pet,
        stage,
        widget.product['asset_id'] as String,
      )?.nameInWardrobe ??
      widget.product['name'] as String;
  late var state = load();
  bool preview = true;

  Future<
    ({
      Json? purchase,
      Json? wish,
      Json? room,
      int stage,
      List<ScenePiece> pieces,
      Map<String, String> outfit,
    })
  >
  load() async {
    final purchase = (await service.purchases())
        .where((row) => row['item_id'] == id && row['refunded_at'] == null)
        .singleOrNull;
    final spaces = await service.spaces();
    Json? room;
    final spaceType = widget.product['space_id'];
    if (spaceType != null) {
      room = spaces
          .where((space) => space['scene_id'] == spaceType)
          .firstOrNull;
    } else if (purchase != null && widget.product['slot'] == null) {
      room = await service.displayRoom(purchase['id'] as String);
    } else {
      room = widget.controller.baseSpace;
    }
    final family = widget.controller.family!;
    final stage = pet == family.companion
        ? family.stage
        : (await service.companionProgress())[pet]?.stage ?? 1;
    return (
      purchase: purchase,
      wish: await service.wish(),
      room: room,
      stage: stage,
      pieces: room == null
          ? <ScenePiece>[]
          : (await service.furnishings(room['id'] as String))
                .map(ScenePiece.fromRow)
                .toList(),
      outfit: outfitFiles(await service.wardrobe(pet)),
    );
  }

  Future<void> reload() async {
    await widget.controller.refresh();
    if (!mounted) return;
    final updated = load();
    setState(() {
      state = updated;
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final product = widget.product;
      final family = widget.controller.family!;
      final balance = family.balance;
      final slot = product['slot'] as String?;
      final parts = (product['included_items'] as List?)?.cast<Json>();
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _name(
              pet == family.companion ? family.stage : widget.modelStage ?? 0,
            ),
          ),
        ),
        body: PageBody(
          maxWidth: 560,
          child: FutureBuilder(
            future: state,
            builder: (context, snapshot) {
              final loaded = snapshot.data;
              if (loaded == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final purchase = loaded.purchase;
              final wished = loaded.wish?['item_id'] == id;
              final fixed = product['price'] as int;
              final wishPrice = wished
                  ? loaded.wish!['selected_price'] as int
                  : fixed;
              final price = fixed < wishPrice ? fixed : wishPrice;
              final asset = product['asset_id'] as String;
              final name = _name(loaded.stage);
              final sceneId =
                  (loaded.room?['scene_id'] ??
                          product['space_id'] ??
                          'base_room')
                      as String;
              final roomName =
                  (loaded.room?['name'] ??
                          (product['space_id'] == null
                              ? '银杏家园'
                              : product['name']))
                      as String;
              final candidates = ScenePiece.preview(product);
              final withPreview = {
                for (final p in loaded.pieces) p.asset: p,
                if (purchase == null)
                  for (final p in candidates) p.asset: p,
              }.values.toList();
              final installed = slot == null
                  ? purchase != null
                  : loaded.outfit[slot] == asset;
              final showNew = preview && !installed;
              final frame = slot == null
                  ? RoomPainting(sceneId, withPreview).frameFor(candidates)
                  : null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GardenScene(
                    companion: pet,
                    stage: loaded.stage,
                    rules: service.rules,
                    scene: SceneDefinition(service.rules, sceneId),
                    view: HomeView.veranda,
                    pieces: showNew ? withPreview : loaded.pieces,
                    outfit: {
                      ...loaded.outfit,
                      if (slot != null && showNew) slot: asset,
                    },
                    label: slot != null ? pet.nickname : roomName,
                    focus: slot != null,
                    detailFrame: frame,
                  ),
                  if (!installed)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('原样'),
                          selected: !preview,
                          onSelected: (_) => setState(() => preview = false),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(slot == null ? '看摆好效果' : '试穿效果'),
                          selected: preview,
                          onSelected: (_) => setState(() => preview = true),
                        ),
                      ],
                    ),
                  const SizedBox(height: 14),
                  GardenCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('当前 $balance 分 · 兑换 $price 分'),
                        if (purchase == null)
                          Text(
                            balance >= price
                                ? '兑换后剩余 ${balance - price} 分'
                                : '还差 ${price - balance} 分',
                          )
                        else
                          Text(
                            slot == null
                                ? '已在$roomName中展出。'
                                : installed
                                ? '${pet.nickname}正穿着这件衣饰。'
                                : '已收藏，可在衣橱中换上。',
                          ),
                        if (parts != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            '包含 ${parts.map((part) => part['name']).join('、')}',
                          ),
                        ],
                        if (purchase == null)
                          Text(
                            slot != null
                                ? '确认兑换后，${pet.nickname}会穿上它。'
                                : '确认兑换后，家具会在${product['space_id'] == null ? '暖廊' : roomName}中就位。',
                          )
                        else if (slot == null && loaded.room != null)
                          OutlinedButton(
                            onPressed: () => openPage(
                              context,
                              SpacePage(
                                controller: widget.controller,
                                id: loaded.room!['id'] as String,
                              ),
                            ),
                            child: Text('去$roomName看看'),
                          ),
                        const SizedBox(height: 12),
                        if (purchase == null) ...[
                          ActionButton(
                            label: '兑换',
                            enabled: balance >= price && !service.frozen,
                            action: () async {
                              final ok = await confirmChoice(
                                context,
                                '兑换$name？',
                                '使用 $price 分，兑换后剩余 ${balance - price} 分。',
                                '确认兑换',
                              );
                              if (!ok) return;
                              await service.purchase(
                                id,
                                wearOn: slot == null ? null : widget.model,
                              );
                              await reload();
                              if (context.mounted) {
                                showNotice(
                                  context,
                                  slot == null
                                      ? '家具已就位。'
                                      : '${pet.nickname}穿上了$name。',
                                );
                              }
                            },
                          ),
                          ActionButton(
                            label: wished ? '移除心愿' : '设为心愿',
                            outlined: true,
                            enabled: !service.frozen,
                            action: () async {
                              await service.setWish(wished ? null : id);
                              await reload();
                            },
                          ),
                        ],
                        if (purchase != null &&
                            service.canChildUndo(purchase['id'] as String))
                          ActionButton(
                            label: '撤销这次兑换',
                            outlined: true,
                            enabled: !service.frozen,
                            action: () async {
                              final ok = await confirmChoice(
                                context,
                                '撤销这次兑换？',
                                '将返还原付的 ${purchase['price_paid']} 分。',
                                '确认撤销',
                              );
                              if (!ok) return;
                              await service.refund(purchase['id'] as String);
                              await reload();
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

String _purchaseStatus(Json row) {
  if (row['refunded_at'] != null) return '已退回';
  final pet = row['fed_pet_id'] as String?;
  return pet == null ? '已兑换' : '已喂给${Companion.values.byName(pet).nickname}';
}

class PurchaseHistoryPage extends StatefulWidget {
  const PurchaseHistoryPage({
    super.key,
    required this.controller,
    this.parent = false,
  });
  final FamilyController controller;
  final bool parent;

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  late Future<List<Json>> snapshot = service.purchases();
  FamilyService get service => widget.controller.service!;

  @override
  Widget build(BuildContext context) {
    final body = FutureBuilder(
      future: snapshot,
      builder: (context, result) {
        final history = result.data;
        return PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (history == null)
                const Center(child: CircularProgressIndicator()),
              if (history?.isEmpty ?? false)
                const GardenCard(child: Text('还没有兑换记录。')),
              for (final row in history ?? <Json>[])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GardenCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CompanionFood.forItem(row['item_id'])?.label ??
                              row['name'] as String,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${row['price_paid']} 分 · ${_purchaseStatus(row)}',
                        ),
                        if (row['refundable'] == 1 &&
                            row['refunded_at'] == null &&
                            !service.frozen)
                          if (widget.parent ||
                              service.canChildUndo(row['id'] as String))
                            ActionButton(
                              label: widget.parent ? '退回误购' : '撤销兑换',
                              outlined: true,
                              action: () async {
                                final food = CompanionFood.forItem(
                                  row['item_id'],
                                );
                                final ok = await confirmChoice(
                                  context,
                                  '退回${food?.label ?? row['name']}？',
                                  food != null
                                      ? '收回一份${food.label}，返还原付积分。'
                                      : '返还原付积分。此成果附带的物品将收回，另购物品保留。',
                                  '确认退回',
                                );
                                if (!ok) return;
                                await service.refund(
                                  row['id'] as String,
                                  session: widget.parent
                                      ? widget.controller.session
                                      : null,
                                );
                                await widget.controller.refresh();
                                if (mounted) {
                                  final updated = service.purchases();
                                  setState(() {
                                    snapshot = updated;
                                  });
                                }
                              },
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                '误购可请家长帮助处理。',
                                style: TextStyle(color: mutedInk),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
    return widget.parent
        ? ParentFrame(
            controller: widget.controller,
            title: '兑换与退款',
            child: body,
          )
        : Scaffold(
            appBar: AppBar(title: const Text('我的兑换')),
            body: body,
          );
  }
}
