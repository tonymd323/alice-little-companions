enum CompanionMoment { touch, call }

class CompanionBond {
  const CompanionBond({this.touched = false, this.called = false});

  final bool touched, called;

  bool has(CompanionMoment moment) => switch (moment) {
    CompanionMoment.touch => touched,
    CompanionMoment.call => called,
  };

  String get label => touched && called
      ? '默契'
      : touched || called
      ? '熟悉'
      : '初见';
}
