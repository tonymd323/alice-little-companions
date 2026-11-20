class RainMapProgress {
  const RainMapProgress({
    this.run = 0,
    this.stones = 0,
    this.stamps = 0,
    this.cleared = false,
    this.challengeSolved = false,
  });

  static const groupSize = 3;
  static const groupCount = 4;
  static const challengeStamps = 3;
  static const challengeAnswer = challengeStamps * groupSize;

  final int run, stones, stamps;
  final bool cleared, challengeSolved;

  bool get started => run > 0;
  bool get complete => stamps == groupCount;
  bool get canStamp => !complete && stones == groupSize;
  int get totalStones => stamps * groupSize + stones;
}
const rainMapTitle = '奶油的雨天地图';

abstract interface class RainMapCommands {
  Future<RainMapProgress> beginRainMap();
  Future<RainMapProgress> stepRainMapStone({
    required int run,
    required int group,
    required int stone,
  });
  Future<RainMapProgress> stampRainMap({required int run, required int group});
  Future<RainMapProgress> restartRainMap({required int run});
  Future<RainMapProgress> solveRainMapChallenge(int stones);
}
