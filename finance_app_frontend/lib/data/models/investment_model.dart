class Investment {
  String id;
  String investmentName;
  double stockPrice;
  int numberOfStocks;
  double totalInvestment;
  String type;
  String currency;
  String? note;
  DateTime date;

  Investment({
    required this.id,
    required this.investmentName,
    required this.stockPrice,
    required this.numberOfStocks,
    required this.totalInvestment,
    required this.type,
    required this.currency,
    this.note,
    required this.date,
  });

  // Convert to Map (for Hive storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'investmentName': investmentName,
      'stockPrice': stockPrice,
      'numberOfStocks': numberOfStocks,
      'totalInvestment': totalInvestment,
      'type': type,
      'currency': currency,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  // Convert from Map (read from Hive)
  factory Investment.fromMap(Map<dynamic, dynamic> map) {
    return Investment(
      id: map['id'],
      investmentName: map['investmentName'],
      stockPrice: map['stockPrice'],
      numberOfStocks: map['numberOfStocks'],
      totalInvestment: map['totalInvestment'],
      type: map['type'],
      currency: map['currency'],
      note: map['note'],
      date: DateTime.parse(map['date']),
    );
  }
}