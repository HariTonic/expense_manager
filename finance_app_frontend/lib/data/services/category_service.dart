import 'package:uuid/uuid.dart';
import '../models/category_model.dart';

class CategoryService {
  static final _uuid = const Uuid();

  List<CategoryModel> getExpenseCategories() {
    return [
      'Food',
      'Transport',
      'Shopping',
      'Bills',
      'Entertainment',
      'Health',
      'Other',
    ].map((name) {
      return CategoryModel(id: _uuid.v4(), name: name, type: 'expense');
    }).toList();
  }

  List<CategoryModel> getIncomeSources() {
    return [
      'Salary',
      'Freelance',
      'Business',
      'Investment',
      'Gift',
      'Other',
    ].map((name) {
      return CategoryModel(id: _uuid.v4(), name: name, type: 'income');
    }).toList();
  }
}
