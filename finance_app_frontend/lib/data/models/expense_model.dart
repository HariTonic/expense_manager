class Expense {
  String id;
  double amount;
  String category;
  String? note;
  DateTime date;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    this.note,
    required this.date,
  });

  // Convert to Map (for Hive storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  // Convert from Map (read from Hive)
  factory Expense.fromMap(Map<dynamic, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      note: map['note'],
      date: DateTime.parse(map['date']),
    );
  }
}