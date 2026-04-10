import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              minX: 1,
              maxX: 5,
              minY: 0,
              maxY: 6000,

              // GRID
              gridData: const FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1000,
              ),

              // BORDER
              borderData: FlBorderData(
                show: false,
              ),

              // TITLES (ONLY ONCE - FIXED)
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1000,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];

                      if (value.toInt() < 1 || value.toInt() > 5) {
                        return const SizedBox();
                      }

                      return Text(
                        months[value.toInt() - 1],
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),

                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),

              // LINE DATA
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.blue,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.15),
                  ),
                  spots: const [
                    FlSpot(1, 1000),
                    FlSpot(2, 3000),
                    FlSpot(3, 2000),
                    FlSpot(4, 5000),
                    FlSpot(5, 4000),
                  ],
                ),
              ],

              // TOUCH INTERACTION
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}