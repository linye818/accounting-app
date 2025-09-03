class Expense {
  final int id;
  final String description;
  final double amount;
  final int categoryId;
  final DateTime date;
  final bool isExpense;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.isExpense,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category_id': categoryId,
      'date': date.millisecondsSinceEpoch,
      'is_expense': isExpense ? 1 : 0,
    };
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      categoryId: map['category_id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      isExpense: map['is_expense'] == 1,
    );
  }
}
