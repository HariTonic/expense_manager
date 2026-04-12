import 'package:hive/hive.dart';
import '../models/income_model.dart';
import '../database/hive_boxes.dart';

class IncomeService {
  final Box _box = Hive.box(HiveBoxes.income);

  Future<void> addIncome(Income income) async {
    await _box.put(income.id, income.toMap());
  }

  List<Income> getIncomes() {
    return _box.values
        .map((item) => Income.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }
}
