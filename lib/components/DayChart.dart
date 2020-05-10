import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DayChart extends StatelessWidget {
  final List<double> data;
  
  DayChart(this.data);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          leftTitles: SideTitles(
            showTitles: false,
          ),
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (value) => (value % 3 == 0) ? value.toStringAsFixed(0) : '',
            textStyle: TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ),
        backgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        alignment: BarChartAlignment.spaceAround,
        barGroups: List.generate(data.length, (idx) {
          return BarChartGroupData(
            x: idx,
            barRods: <BarChartRodData>[
              BarChartRodData(y: this.data[idx], color: Colors.white, width: 10),
            ],
          );
        }),
      ),
    );
  }
}
