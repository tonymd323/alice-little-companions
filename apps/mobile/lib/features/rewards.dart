import 'package:material_ui/material_ui.dart';

import '../application/controller.dart';
import '../application/family.dart';
import '../domain/layout_rules.dart';
import '../domain/rules.dart';
import 'common.dart';
import 'garden.dart';
import 'parent_access.dart';

const _tiers = {
  'small': '小装饰',
  'accessory': '配饰',
  'single': '家具与衣服',
  'bundle': '主题套装',
  'zone': '功能区',
  'shop': '店铺',
};

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, required this.controller});
  final FamilyController controller;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late Future<List<Json>> history = widget.controller.service!.purchases();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text('成果兑换'),
        actions: [
          Center(child: PointsPill(widget.controller.family!.balance)),
          const SizedBox(width: 12),
        ],
      ),
      body: PageBody(
        maxWidth: 1050,
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    await openPage(
                      context,
                      PurchaseHistoryPage(controller: widget.controller),
                    );
                    if (mounted) {
                      setState(
                        () => history = widget.controller.service!.purchases(),
                      );
                    }
                  },
                  label: const Text('我的兑换'),
                  icon: const Icon(Icons.inventory_2_outlined),
                ),
                for (final tier in _tiers.entries) ...[
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
                                (item) => item['tier'] == tier.key,
                              ))
                            SizedBox(
                              width: width,
                              child: _RewardTile(
                                item: product,
                                owned: owned.contains(product['id']),
                                onTap: () async {
                                  await openPage(
                                    context,
                                    RewardPage(
                                      controller: widget.controller,
                                      product: product,
                                    ),
                                  );
                                  if (mounted) {
                                    setState(
                                      () => history = widget.controller.service!
                                          .purchases(),
                                    );
                                  }
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

class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.item,
    required this.owned,
    required this.onTap,
  });
  final Json item;
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
                artworkPath(item['asset_id'] as String),
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              item['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              owned ? '已拥有' : '${item['price']} 分',
              style: const TextStyle(color: foliage),
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
  });
  final FamilyController controller;
  final Json product;

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  FamilyService get service => widget.controller.service!;
  String get id => widget.product['id'] as String;
  late Future<(Json?, Json?)> state = load();
  bool trying = false;

  Future<(Json?, Json?)> load() async => (
    (await service.purchases())
        .where((row) => row['item_id'] == id && row['refunded_at'] == null)
        .singleOrNull,
    await service.wish(),
  );

  Future<void> reload() async {
    await widget.controller.refresh();
    if (mounted) setState(() => state = load());
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final product = widget.product;
      final balance = widget.controller.family!.balance;
      final slot = product['slot'] as String?;
      final parts = (product['included_items'] as List?)?.cast<Json>();
      return Scaffold(
        appBar: AppBar(title: Text(product['name'] as String)),
        body: PageBody(
          maxWidth: 560,
          child: FutureBuilder(
            future: state,
            builder: (context, snapshot) {
              final loaded = snapshot.data;
              if (loaded == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final purchase = loaded.$1;
              final wished = loaded.$2?['item_id'] == id;
              final fixed = product['price'] as int;
              final wishPrice = wished
                  ? loaded.$2!['selected_price'] as int
                  : fixed;
              final price = fixed < wishPrice ? fixed : wishPrice;
              final family = widget.controller.family!;
              final asset = product['asset_id'] as String;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (trying && slot != null)
                    GardenScene(
                      companion: family.companion,
                      stage: family.stage,
                      rules: service.rules,
                      outfit: {slot: asset},
                      label: '衣饰试穿',
                    )
                  else
                    GardenCard(
                      child: Image.asset(
                        artworkPath(asset),
                        height: 165,
                        fit: BoxFit.contain,
                        semanticLabel: product['name'] as String,
                      ),
                    ),
                  const SizedBox(height: 14),
                  GardenCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          product['name'] as String,
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
                          const Text('已拥有，可在换装或布置中使用。'),
                        if (parts != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            '包含 ${parts.map((part) => part['name']).join('、')}',
                          ),
                        ],
                        if (slot != null)
                          OutlinedButton(
                            onPressed: () => setState(() => trying = !trying),
                            child: Text(trying ? '查看物品' : '试穿'),
                          ),
                        const SizedBox(height: 12),
                        if (purchase == null) ...[
                          ActionButton(
                            label: '兑换',
                            enabled: balance >= price && !service.frozen,
                            action: () async {
                              final ok = await confirmChoice(
                                context,
                                '兑换${product['name']}？',
                                '使用 $price 分，兑换后剩余 ${balance - price} 分。',
                                '确认兑换',
                              );
                              if (!ok) return;
                              await service.purchase(id);
                              await reload();
                              if (context.mounted) {
                                showNotice(context, '这件成果已放入物品栏。');
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
                          row['name'] as String,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${row['price_paid']} 分 · ${row['refunded_at'] == null ? '已兑换' : '已退回'}',
                        ),
                        if (row['refunded_at'] == null && !service.frozen)
                          if (widget.parent ||
                              service.canChildUndo(row['id'] as String))
                            ActionButton(
                              label: widget.parent ? '退回误购' : '撤销兑换',
                              outlined: true,
                              action: () async {
                                final ok = await confirmChoice(
                                  context,
                                  '退回${row['name']}？',
                                  '返还原付积分。此成果附带的物品将收回，另购物品保留。',
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
                                  setState(
                                    () => snapshot = service.purchases(),
                                  );
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
