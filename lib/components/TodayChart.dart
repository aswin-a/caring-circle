import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TodayChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fill,
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            leftTitles: SideTitles(
              showTitles: false,
            ),
            bottomTitles: SideTitles(
              showTitles: false,
            ),
          ),
          backgroundColor: Colors.white,
          borderData: FlBorderData(show: false),
          alignment: BarChartAlignment.spaceEvenly,
          barGroups: List.generate(12, (idx) {
            return BarChartGroupData(
              x: idx,
              barRods: <BarChartRodData>[
                BarChartRodData(y: 1, color: (idx+1)%3 == 0 ? Colors.red : Colors.green, width: 8,),
              ],
            );
          }),
        ),
      ),
    );
  }
}
