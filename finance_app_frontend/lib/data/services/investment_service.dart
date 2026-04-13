import 'package:hive/hive.dart';
import '../models/investment_model.dart';
import '../database/hive_boxes.dart';

class InvestmentService {
  final Box _box = Hive.box(HiveBoxes.investments);

  // Add investment
  Future<void> addInvestment(Investment investment) async {
    await _box.put(investment.id, investment.toMap());
  }

  // Get all investments
  List<Investment> getInvestments() {
    return _box.values
        .map((e) => Investment.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }
}