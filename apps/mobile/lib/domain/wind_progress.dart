/// The five open leaf sockets in 风过暖廊. The middle pane is missing its
/// bottom-right leaf (slot 0); the far pane uses slots 1–4 in reading order.
class WindProgress {
  const WindProgress({this.run = 0, this.mask = 0});

  static const slots = 5;
  static const fullMask = (1 << slots) - 1;

  final int run;
  final int mask;

  bool get started => run > 0;
  bool get complete => mask == fullMask;
  bool get middleLit => hasLeaf(0);
  bool get farLit => (mask & 0x1e) == 0x1e;
  bool hasLeaf(int slot) => (mask & (1 << slot)) != 0;
  int get remaining =>
      slots - Iterable<int>.generate(slots).where(hasLeaf).length;
}
