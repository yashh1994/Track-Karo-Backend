import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class CustomClickablePieChart extends StatelessWidget {
  final Map<String, double> dataMap;
  final List<Color> colorList;
  final Map<String, String> routeMap;
  final Function(String) onSegmentTap;

  CustomClickablePieChart({
    required this.dataMap,
    required this.colorList,
    required this.routeMap,
    required this.onSegmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return PieChart(
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
      chartValueStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      onTap: (value) {
        onSegmentTap(value);
      },
    );
  }
}
