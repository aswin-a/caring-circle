import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants.dart';

enum DurationRange { day, week, month }

Stream<QuerySnapshot> getCurrentActivityStream([userId]) {
  return Firestore.instance
      .collection(Constants().firestoreUsersCollection)
      .document(userId != null ? userId : Constants().currentUserId)
      .collection(Constants().firestoreUserActivitiesCollection)
      .where(Constants().firestoreUserActivitiesEntryField, isNull: true)
      .snapshots();
}

Future<QuerySnapshot> getCurrentActivityFuture([String userId]) {
  return Firestore.instance
      .collection(Constants().firestoreUsersCollection)
      .document(userId != null ? userId : Constants().currentUserId)
      .collection(Constants().firestoreUserActivitiesCollection)
      .where(Constants().firestoreUserActivitiesEntryField, isNull: true)
      .getDocuments();
}

Stream<QuerySnapshot> getThisMonthActivitiesStream([userId]) {
  final currentDate = DateTime.now().toUtc();
  return Firestore.instance
      .collection(Constants().firestoreUsersCollection)
      .document(userId != null ? userId : Constants().currentUserId)
      .collection(Constants().firestoreUserActivitiesCollection)
      .where(
        Constants().firestoreUserActivitiesEntryField,
        isGreaterThan: Timestamp.fromDate(
          DateTime.utc(currentDate.year, currentDate.month),
        ),
      )
      .orderBy(Constants().firestoreUserActivitiesEntryField, descending: true)
      .snapshots();
}

List<List<double>> getDurationDataFromOrderedActivities(
    List<Map<String, dynamic>> data) {
  DateTime exitTime;
  DateTime entryTime;
  DateTime durationStart;
  DateTime durationEnd;

  final currentDate = DateTime.now();

  void setExitEntryTime(index) {
    exitTime = (data[index]['exit'] as Timestamp).toDate();
    entryTime = (data[index]['entry'] as Timestamp).toDate();
  }

  void setDurationStartEndTime(index, DurationRange durationRange) {
    switch (durationRange) {
      case DurationRange.day:
        durationStart = DateTime(
            currentDate.year, currentDate.month, currentDate.day, index);
        durationEnd = DateTime(
                currentDate.year, currentDate.month, currentDate.day, index + 1)
            .subtract(Duration(milliseconds: 1));
        break;
      case DurationRange.week:
        durationStart = DateTime(currentDate.year, currentDate.month,
            currentDate.day - (currentDate.weekday % 7) + index);
        durationEnd = DateTime(currentDate.year, currentDate.month,
                currentDate.day - (currentDate.weekday % 7) + index + 1)
            .subtract(Duration(milliseconds: 1));
        break;
      case DurationRange.month:
        durationStart =
            DateTime(currentDate.year, currentDate.month, index + 1);
        durationEnd = DateTime(currentDate.year, currentDate.month, index + 2)
            .subtract(Duration(milliseconds: 1));
        break;
      default:
    }
  }

  List<double> splitActivitiesIntoDurationFrames(DurationRange durationRange) {
    int durationRangeLength;
    DateTime cutoffTime;
    List<double> result;
    switch (durationRange) {
      case DurationRange.day:
        durationRangeLength = 24;
        cutoffTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );
        result = List.filled(currentDate.hour + 1, 10e-5, growable: true);
        result.addAll(List.filled(durationRangeLength - result.length, 0));
        break;
      case DurationRange.week:
        durationRangeLength = 7;
        cutoffTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day - (currentDate.weekday % 7),
        );
        result =
            List.filled((currentDate.weekday % 7) + 1, 10e-5, growable: true);
        result.addAll(List.filled(durationRangeLength - result.length, 0));
        break;
      case DurationRange.month:
        durationRangeLength =
            DateTime(currentDate.year, currentDate.month + 1, 0).day;
        cutoffTime = DateTime(currentDate.year, currentDate.month);
        result = List.filled(currentDate.day, 10e-5, growable: true);
        result.addAll(List.filled(durationRangeLength - result.length, 0));
        break;
      default:
    }
    int durationIndex = durationRangeLength - 1;
    int dataIndex = 0;
    while ((durationIndex >= 0) && (dataIndex < data.length)) {
      setDurationStartEndTime(durationIndex, durationRange);
      setExitEntryTime(dataIndex);
      if (!entryTime.isBefore(cutoffTime)) {
        if (!entryTime.isAfter(durationEnd) &&
            !exitTime.isBefore(durationStart)) {
          result[durationIndex] += entryTime.difference(exitTime).inMinutes;
          dataIndex += 1;
        } else if (!entryTime.isBefore(durationEnd) &&
            !exitTime.isAfter(durationStart)) {
          result[durationIndex] += durationEnd.difference(durationStart).inMinutes;
          durationIndex -= 1;
        } else if (!entryTime.isBefore(durationEnd) &&
            !exitTime.isBefore(durationStart) &&
            !exitTime.isAfter(durationEnd)) {
          result[durationIndex] += durationEnd.difference(exitTime).inMinutes;
          dataIndex += 1;
        } else if (!entryTime.isAfter(durationEnd) &&
            !entryTime.isBefore(durationStart) &&
            !exitTime.isAfter(durationStart)) {
          result[durationIndex] +=
              entryTime.difference(durationStart).inMinutes;
          durationIndex -= 1;
        } else {
          durationIndex -= 1;
        }
      } else {
        break;
      }
    }
    return result;
  }

  final dayData = splitActivitiesIntoDurationFrames(DurationRange.day);
  final weekData = splitActivitiesIntoDurationFrames(DurationRange.week);
  final monthData = splitActivitiesIntoDurationFrames(DurationRange.month);

  return [dayData, weekData, monthData];
}
