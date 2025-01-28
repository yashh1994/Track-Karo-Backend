import 'package:flutter/foundation.dart';

class PieChartDataModel with ChangeNotifier {
  final Map<String, double> _dataMap = {
    'On Route': 30,
    'Standby': 20,
    'Out of Service': 10,
  };

  Map<String, double> get dataMap => Map.unmodifiable(_dataMap);

  void updateData(String key, double value) {
    if (_dataMap.containsKey(key)) {
      _dataMap[key] = (_dataMap[key] ?? 0) + value;
    } else {
      _dataMap[key] = value;
    }
    notifyListeners();
  }

  void resetData(String key) {
    _dataMap[key] = 0;
    notifyListeners();
  }
}
