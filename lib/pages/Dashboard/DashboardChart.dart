import 'package:caring_circle/constants.dart';
import 'package:flutter/material.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../components/TodayChart.dart';
import '../../components/WeekChart.dart';
import '../../components/MonthChart.dart';
import '../../utils/ActivityUtils.dart' as ActivityUtils;

class DashboardChart extends StatefulWidget {
  @override
  _DashboardChartState createState() => _DashboardChartState();
}

class _DashboardChartState extends State<DashboardChart> {
  final activitiesStream = ActivityUtils.getThisMonthActivitiesStream();
  final currentActivityStream = ActivityUtils.getCurrentActivityStream();
  List<double> dayData;
  List<double> weekData;
  List<double> monthData;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: this.currentActivityStream,
      builder: (context, currentActivitySnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: this.activitiesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active &&
                currentActivitySnapshot.connectionState ==
                    ConnectionState.active) {
              final activitiesData =
                  snapshot.data.documents.map((e) => e.data).toList();
              if (currentActivitySnapshot.data.documents.length == 1) {
                final currentActivityData =
                    currentActivitySnapshot.data.documents.first.data;
                currentActivityData[
                        Constants().firestoreUserActivitiesEntryField] =
                    Timestamp.fromDate(DateTime.now().toUtc());
                activitiesData.insert(0, currentActivityData);
              }
              final durationData =
                  ActivityUtils.getDurationDataFromOrderedActivities(
                      activitiesData);
              this.dayData = durationData[0];
              this.weekData = durationData[1];
              this.monthData = durationData[2];
            }
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                color: Colors.white24,
                height: 220,
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: <Widget>[
                      TabBar(
                        tabs: [
                          Tab(text: 'Day'),
                          Tab(text: 'Week'),
                          Tab(text: 'Month'),
                        ],
                        labelColor: Theme.of(context).scaffoldBackgroundColor,
                        unselectedLabelColor: Colors.white60,
                        indicator: BubbleTabIndicator(
                          indicatorColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: TabBarView(
                          children: [
                            TodayChart(this.dayData),
                            WeekChart(this.weekData),
                            MonthChart(this.monthData),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
