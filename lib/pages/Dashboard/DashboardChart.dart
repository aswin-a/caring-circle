import 'package:flutter/material.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../components/DayChart.dart';
import '../../utils/ActivityUtils.dart';

class DashboardChart extends StatefulWidget {
  @override
  _DashboardChartState createState() => _DashboardChartState();
}

class _DashboardChartState extends State<DashboardChart> {
  final activitiesStream = thisMonthActivitiesStream;
  List<double> dayData = List.filled(24, 0);
  List<double> weekData;
  List<double> monthData;
  // TODO: Include current activity if available
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: activitiesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final durationData = getDurationDataFromOrderedActivities(
              snapshot.data.documents.map((e) => e.data).toList());
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
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: TabBarView(
                      children: [
                        DayChart(this.dayData),
                        DayChart(this.weekData),
                        DayChart(this.monthData),
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
  }
}
