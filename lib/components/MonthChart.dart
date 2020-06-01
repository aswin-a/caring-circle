import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthChart extends StatelessWidget {
  final List<double> data;

  MonthChart(this.data);

  @override
  Widget build(BuildContext context) {
    if (this.data == null) {
      return Container();
    }
    final maxValue = this.data.reduce(max);
    final unitInHours = maxValue > 60;
    final interval = ((maxValue / 6).floorToDouble() / 60).ceilToDouble() * 60;
    final nonZeroLength = this
        .data
        .fold(0, (value, element) => element > 0 ? value + 1 : value)
        .toInt();
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          leftTitles: SideTitles(
            showTitles: true,
            getTitles: (value) => unitInHours
                ? '${(value / 60).floor()} hrs'
                : '${value.toStringAsFixed(0)} mins',
            textStyle: TextStyle(color: Colors.white54, fontSize: 10),
            reservedSize: 40,
            interval: unitInHours ? interval : 10,
            margin: 10,
          ),
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (value) =>
                ((value + 1) % 3) == 0 ? (value + 1).toStringAsFixed(0) : '',
            textStyle: TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ),
        backgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: false),
        minX: 0,
        maxX: this.data.length.toDouble(),
        minY: 0,
        maxY:
            unitInHours ? ((maxValue / interval).ceil() + 0.2) * interval : 65,
        gridData: FlGridData(show: false),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            barWidth: 5,
            colors: [Colors.white],
            dotData: FlDotData(show: nonZeroLength == 1),
            spots: List.generate(
              nonZeroLength,
              (idx) {
                return FlSpot(idx.toDouble(), this.data[idx]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
