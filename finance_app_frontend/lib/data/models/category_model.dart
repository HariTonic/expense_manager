class CategoryModel {
  final String id;
  final String name;
  final String type; // 'income' or 'expense'

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
  });
}
