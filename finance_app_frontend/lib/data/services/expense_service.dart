import 'package:hive/hive.dart';
import '../models/expense_model.dart';
import '../database/hive_boxes.dart';

class ExpenseService {
  final Box _box = Hive.box(HiveBoxes.expenses);

  // Add expense
  Future<void> addExpense(Expense expense) async {
    await _box.put(expense.id, expense.toMap());
  }

  // Get all expenses
  List<Expense> getExpenses() {
    return _box.values
        .map((e) => Expense.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }
}