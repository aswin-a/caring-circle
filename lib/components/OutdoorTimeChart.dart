import 'package:flutter/material.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:provider/provider.dart';

import './TodayChart.dart';
import './WeekChart.dart';
import './MonthChart.dart';
import '../providers/BaseActivitiesProvider.dart';

class OutdoorTimeChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          color: Colors.white24,
          height: 232,
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: <Widget>[
                TabBar(
                  tabs: [
                    Tab(text: 'Today'),
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
                  child: Consumer<BaseActivitiesProvider>(
                    builder: (context, baseActivitiesProvider, _) {
                      return TabBarView(
                        children: [
                          TodayChart(
                            baseActivitiesProvider
                                .activitiesDuration?.todayData,
                            baseActivitiesProvider
                                .activitiesDuration?.todayOutdoorTime,
                          ),
                          WeekChart(
                            baseActivitiesProvider.activitiesDuration?.weekData,
                            baseActivitiesProvider
                                .activitiesDuration?.weekOutdoorTime,
                          ),
                          MonthChart(
                              baseActivitiesProvider
                                  .activitiesDuration?.monthData,
                              baseActivitiesProvider
                                  .activitiesDuration?.monthOutdoorTime),
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
