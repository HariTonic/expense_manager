class Income {
  String id;
  double amount;
  String category;
  String? note;
  DateTime date;

  Income({
    required this.id,
    required this.amount,
    required this.category,
    this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  factory Income.fromMap(Map<dynamic, dynamic> map) {
    return Income(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      note: map['note'],
      date: DateTime.parse(map['date']),
    );
  }
}
