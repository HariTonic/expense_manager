class Income {
  String id;
  String source;
  double amount;
  DateTime date;
  String? note;

  Income({
    required this.id,
    required this.source,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source': source,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Income.fromMap(Map<dynamic, dynamic> map) {
    return Income(
      id: map['id'],
      source: map['source'] ?? 'Income',
      amount: (map['amount'] is int)
          ? (map['amount'] as int).toDouble()
          : map['amount'] as double,
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }
}
