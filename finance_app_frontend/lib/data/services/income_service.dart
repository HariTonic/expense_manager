import 'package:hive/hive.dart';
import '../models/income_model.dart';
import '../database/hive_boxes.dart';

class IncomeService {
  final Box _box = Hive.box(HiveBoxes.income);

  Future<void> addIncome(Income income) async {
    await _box.put(income.id, income.toMap());
  }

  Future<void> updateIncome(Income income) async {
    await _box.put(income.id, income.toMap());
  }

  Future<void> deleteIncome(String id) async {
    await _box.delete(id);
  }

  List<Income> getIncomes() {
    return _box.values
        .map((item) => Income.fromMap(Map<String, dynamic>.from(item)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
