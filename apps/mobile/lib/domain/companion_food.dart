enum CompanionFood {
  candy('affinity_candy', '糖果'),
  cookie('affinity_cookie', '饼干'),
  pudding('affinity_pudding', '布丁');

  const CompanionFood(this.itemId, this.label);

  final String itemId;
  final String label;

  static CompanionFood? forItem(Object? id) =>
      values.where((food) => food.itemId == id).firstOrNull;
}
