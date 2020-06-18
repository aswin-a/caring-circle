import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TodayChart extends StatelessWidget {
  final List<double> data;
  final String duration;

  TodayChart(this.data, this.duration);

  @override
  Widget build(BuildContext context) {
    if (this.data == null) {
      return Container();
    }
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
                  getTitles: (value) => '${value.toStringAsFixed(0)} mins',
                  textStyle: TextStyle(color: Colors.white70, fontSize: 11),
                  reservedSize: 45,
                  interval: 10,
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTitles: (value) => (value % 3 == 0)
                      ? (value % 12 == 0
                          ? '12'
                          : (value % 12).toStringAsFixed(0))
                      : '',
                  textStyle: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
              backgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(enabled: false),
              alignment: BarChartAlignment.spaceAround,
              maxY: 65,
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
