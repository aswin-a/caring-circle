import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeekChart extends StatelessWidget {
  final List<double> data;
  final String duration;
  static const weekLabel = {
    0: 'S',
    1: 'M',
    2: 'T',
    3: 'W',
    4: 'T',
    5: 'F',
    6: 'S',
  };

  WeekChart(this.data, this.duration);

  @override
  Widget build(BuildContext context) {
    if (this.data == null) {
      return Container();
    }
    final maxValue = this.data.reduce(max);
    final unitInHours = maxValue > 60;
    final interval = ((maxValue / 6).floorToDouble() / 60).ceilToDouble() * 60;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Outdoor Time: $duration',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyText2
              .copyWith(color: Colors.white70),
        ),
        Container(
          height: 154,
          child: BarChart(
            BarChartData(
              titlesData: FlTitlesData(
                leftTitles: SideTitles(
                  showTitles: true,
                  getTitles: (value) => unitInHours
                      ? '${(value / 60).floor()} hrs'
                      : '${value.toStringAsFixed(0)} mins',
                  textStyle: TextStyle(color: Colors.white70, fontSize: 11),
                  reservedSize: 45,
                  interval: unitInHours ? interval : 10,
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTitles: (value) => WeekChart.weekLabel[value],
                  textStyle: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
              backgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(enabled: false),
              alignment: BarChartAlignment.spaceAround,
              maxY: unitInHours
                  ? ((maxValue / interval).ceil() + 0.2) * interval
                  : 65,
              barGroups: List.generate(data.length, (idx) {
                return BarChartGroupData(
                  x: idx,
                  barRods: <BarChartRodData>[
                    BarChartRodData(
                        y: this.data[idx], color: Colors.white, width: 10),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
