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
