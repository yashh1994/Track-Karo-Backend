import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'dart:math';

class CustomClickablePieChart extends StatelessWidget {
  final Map<String, double> dataMap;
  final List<Color> colorList;
  final Function(String) onSegmentTap;

  CustomClickablePieChart({
    required this.dataMap,
    required this.colorList,
    required this.onSegmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onTapDown: (details) {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                var localPosition = renderBox.globalToLocal(details.globalPosition);
                var center = Offset(renderBox.size.width / 2, renderBox.size.height / 2);
                var dx = localPosition.dx - center.dx;
                var dy = localPosition.dy - center.dy;
                var angle = (180 / pi * atan2(dy, dx) + 360) % 360;

                double startAngle = 0;
                double total = dataMap.values.reduce((a, b) => a + b);
                dataMap.forEach((key, value) {
                  var sweepAngle = (value / total) * 360;
                  if (angle >= startAngle && angle < startAngle + sweepAngle) {
                    onSegmentTap(key);
                  }
                  startAngle += sweepAngle;
                });
              },
              child: PieChart(
                dataMap: dataMap,
                colorList: colorList,
                chartType: ChartType.ring,
                ringStrokeWidth: 50,
                legendOptions: LegendOptions(
                  showLegends: false,
                ),
                chartValuesOptions: ChartValuesOptions(
                  showChartValuesInPercentage: true,
                ),
                chartRadius: constraints.maxWidth / 2.2,
              ),
            );
          },
        ),
        Column(
          children: dataMap.keys.map((key) {
            return GestureDetector(
              onTap: () {
                onSegmentTap(key);
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      color: colorList[dataMap.keys.toList().indexOf(key)],
                    ),
                    SizedBox(width: 10),
                    Text(
                      key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
