import '../utils/FormattingUtils.dart';

class ActivitiesDuration {
  List<double> _todayData;
  List<double> _weekData;
  List<double> _monthData;

  ActivitiesDuration(this._todayData, this._weekData, this._monthData);

  List<double> get todayData => this._todayData;
  List<double> get weekData => this._weekData;
  List<double> get monthData => this._monthData;

  String get todayOutdoorTime => this._todayData == null
      ? ''
      : formatOutdoorTime(this._todayData.fold<double>(
          0, (previousValue, element) => previousValue + element));

  String get weekOutdoorTime => this._todayData == null
      ? ''
      : formatOutdoorTime(this._todayData.fold<double>(
          0, (previousValue, element) => previousValue + element));

  String get monthOutdoorTime => this._todayData == null
      ? ''
      : formatOutdoorTime(this._todayData.fold<double>(
          0, (previousValue, element) => previousValue + element));
}
