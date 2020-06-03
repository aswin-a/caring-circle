import 'package:timeago/timeago.dart' as timeago;

import '../constants.dart';

String getCurrentStatus(
    LocationStatus locationStatus, DateTime currentActivityExitTime) {
  String result = 'error';
  switch (locationStatus) {
    case LocationStatus.home:
      result = 'In Home';
      break;
    case LocationStatus.office:
      result = 'In Office';
      break;
    case LocationStatus.outside:
      if (currentActivityExitTime != null) {
        final durationText = timeago.format(currentActivityExitTime);
        result =
            'Been outdoors for ${durationText.substring(0, durationText.length - 4)}';
      }
      break;
    default:
      result = 'error';
  }
  return result;
}

String formatOutdoorTime(double minutes) {
  String result = '';
  Duration duration = Duration(minutes: minutes.toInt());
  if (duration.inDays != 0) {
    result += '${duration.inDays} days ';
    result += '${duration.inHours.remainder(Duration.hoursPerDay)} hrs';
  } else if (duration.inHours != 0) {
    result += '${duration.inHours.remainder(Duration.hoursPerDay)} hrs ';
    result += '${duration.inMinutes.remainder(Duration.minutesPerHour)} mins';
  } else {
    result += '${duration.inMinutes.remainder(Duration.minutesPerHour)} mins';
  }
  return result;
}
