import 'package:hive_flutter/hive_flutter.dart';

class HiveInit {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Open boxes
    await Hive.openBox('expenses_box');
    await Hive.openBox('income_box');
    await Hive.openBox('investments_box');
  }
}