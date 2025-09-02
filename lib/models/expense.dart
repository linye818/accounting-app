class Expense {
  final int id;
  final double amount;
  final int categoryId;
  final DateTime date;
  final String description;
  final bool isExpense;

  Expense({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.description,
    required this.isExpense,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category_id': categoryId,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'is_expense': isExpense ? 1 : 0,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      categoryId: map['category_id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
      isExpense: map['is_expense'] == 1,
    );
  }
}
