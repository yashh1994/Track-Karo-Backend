import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class CustomClickablePieChart extends StatelessWidget {
  final Map<String, double> dataMap;
  final List<Color> colorList;
  final Map<String, String> routeMap; // Route mapping for segments
  final Function(String) onSegmentTap; // Callback function for tap events

  CustomClickablePieChart({
    required this.dataMap,
    required this.colorList,
    required this.routeMap,
    required this.onSegmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // PieChart widget
        PieChart(
          dataMap: dataMap,
          colorList: colorList,
          chartType: ChartType.ring,
          chartRadius: MediaQuery.of(context).size.width / 2.5,
          ringStrokeWidth: 32,
          centerText: "Status",
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: true,
            showChartValuesOutside: false,
            decimalPlaces: 1,
          ),
          animationDuration: Duration(milliseconds: 800),
        ),

        // GestureDetector overlay for tap detection
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double radius =
                  constraints.maxWidth / 2.5; // Matches `chartRadius`
              final centerOffset = Offset(
                constraints.maxWidth / 2,
                constraints.maxHeight / 2,
              );

              return GestureDetector(
                onTapUp: (details) {
                  final tapPosition = details.localPosition - centerOffset;
                  final tappedSegment = _getTappedSegment(
                    tapPosition,
                    radius,
                    dataMap,
                  );

                  if (tappedSegment != null) {
                    onSegmentTap(tappedSegment);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Helper function to detect tapped segment
  String? _getTappedSegment(
    Offset position,
    double radius,
    Map<String, double> dataMap,
  ) {
    // Detect if the tap is within the chart radius
    if (position.distance <= radius) {
      double total = dataMap.values.reduce((a, b) => a + b);
      double angle =
          position.direction + (position.direction < 0 ? 2 * 3.14159 : 0);
      double cumulativeAngle = 0;

      for (var entry in dataMap.entries) {
        double sweepAngle = (entry.value / total) * 2 * 3.14159;

        if (angle >= cumulativeAngle && angle < cumulativeAngle + sweepAngle) {
          return entry.key;
        }
        cumulativeAngle += sweepAngle;
      }
    }
    return null; // No segment tapped
  }
}
