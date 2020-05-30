import 'package:flutter/material.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:provider/provider.dart';

import '../../components/TodayChart.dart';
import '../../components/WeekChart.dart';
import '../../components/MonthChart.dart';
import '../../providers/UserProvider.dart';

class DashboardChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ClipRRect(
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
                  child: Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      return TabBarView(
                        children: [
                          TodayChart(userProvider
                              ?.user?.activitiesDuration?.todayData),
                          WeekChart(userProvider
                              ?.user?.activitiesDuration?.weekData),
                          MonthChart(userProvider
                              ?.user?.activitiesDuration?.monthData),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
