class ActivitiesDuration {
  List<double> _todayData;
  List<double> _weekData;
  List<double> _monthData;

  ActivitiesDuration(this._todayData, this._weekData, this._monthData);

  String get todayOutdoorTime =>
      (this._todayData.fold(
              0, (previousValue, element) => previousValue + element) as double)
          .toStringAsFixed(0) +
      ' mins';

  String get weekOutdoorTime =>
      (this._weekData.fold(
              0, (previousValue, element) => previousValue + element) as double)
          .toStringAsFixed(0) +
      ' mins';

  String get monthOutdoorTime =>
      (this._monthData.fold(
              0, (previousValue, element) => previousValue + element) as double)
          .toStringAsFixed(0) +
      ' mins';
}
