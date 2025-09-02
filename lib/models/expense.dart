import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class Expense {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final int categoryId;
  final bool isExpense; // true表示支出，false表示收入

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.isExpense = true,
  });

  // 转换为数据库可存储的格式
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'categoryId': categoryId,
      'isExpense': isExpense ? 1 : 0,
    };
  }

  // 从数据库读取并转换为Expense对象
  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'].toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      categoryId: map['categoryId'],
      isExpense: map['isExpense'] == 1,
    );
  }

  // 格式化日期显示（如2024-09-02）
  String get formattedDate => DateFormat('yyyy-MM-dd').format(date);
  
  // 格式化金额显示（如¥100.00）
  String get formattedAmount => NumberFormat.currency(symbol: '¥').format(amount);
}
