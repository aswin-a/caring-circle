import 'package:caring_circle/Models/Activities\.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

import '../../Models/Circle.dart';
import '../../components/SummaryCard.dart';
import '../../constants.dart';
import '../../utils/ActivityUtils.dart' as ActivityUtils;

class DashboardCirclesListItem extends StatelessWidget {
  final Circle circle;
  Stream combinedStream;

  DashboardCirclesListItem(this.circle) {
    final userIds = circle.users.map((e) => e.id);
    final List<Stream<QuerySnapshot>> streamList = userIds
        .fold(<Stream<QuerySnapshot>>[], (List<Stream> previousValue, element) {
      previousValue.add(ActivityUtils.getThisMonthActivitiesStream(element));
      previousValue.add(ActivityUtils.getCurrentActivityStream(element));
      return previousValue;
    });
    this.combinedStream = CombineLatestStream.list(streamList);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: this.combinedStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final snapshotList = snapshot.data as List<QuerySnapshot>;
          List<double> todayData, weekData, monthData;
          for (var idx = 0; idx < snapshotList.length; idx += 2) {
            final activitiesData =
                snapshotList[idx].documents.map((e) => e.data).toList();
            if (snapshotList[idx + 1].documents.length == 1) {
              final currentActivityData =
                  snapshotList[idx + 1].documents.first.data;
              currentActivityData[
                      Constants().firestoreUserActivitiesEntryField] =
                  Timestamp.fromDate(DateTime.now().toUtc());
              activitiesData.insert(0, currentActivityData);
            }
            final durationData =
                ActivityUtils.getDurationDataFromOrderedActivities(
                    activitiesData);
            todayData = todayData == null
                ? durationData[0]
                : IterableZip([todayData, durationData[0]])
                    .map((e) => e[0] + e[1])
                    .toList();
            weekData = weekData == null
                ? durationData[1]
                : IterableZip([weekData, durationData[1]])
                    .map((e) => e[0] + e[1])
                    .toList();
            monthData = monthData == null
                ? durationData[2]
                : IterableZip([monthData, durationData[2]])
                    .map((e) => e[0] + e[1])
                    .toList();
          }
          this.circle.activitiesDuration =
              ActivitiesDuration(todayData, weekData, monthData);

          return SummaryCard(circle: this.circle, forCircle: true);
        } else
          return Container();
      },
    );
  }
}
