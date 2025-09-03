import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../models/account_category.dart' as cat;
import 'add_edit_expense_screen.dart';

class DetailScreen extends StatelessWidget {
  final Expense expense;

  const DetailScreen({Key? key, required this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final category = provider.categories.firstWhere(
      (c) => c.id == expense.categoryId,
      orElse: () => cat.AccountCategory(
        id: -1,
        name: '未知',
        icon: 'help',
        isExpense: true,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('账单详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditExpenseScreen(expense: expense),
              ),
            ),
            tooltip: '编辑账单',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(
                _getCategoryIcon(category.icon),
                color: expense.isExpense ? Colors.redAccent : Colors.greenAccent,
                size: 32,
              ),
              title: Text(
                category.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(expense.isExpense ? '支出账单' : '收入账单'),
            ),
            const Divider(),
            ListTile(
              title: const Text('金额'),
              trailing: Text(
                '¥${expense.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: expense.isExpense ? Colors.redAccent : Colors.greenAccent,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('描述'),
              trailing: Text(expense.description),
            ),
            const Divider(),
            ListTile(
              title: const Text('日期'),
              trailing: Text(DateFormat('yyyy-MM-dd').format(expense.date)),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'home': return Icons.home;
      case 'movie': return Icons.movie;
      case 'local_hospital': return Icons.local_hospital;
      case 'school': return Icons.school;
      case 'more_horiz': return Icons.more_horiz;
      case 'work': return Icons.work;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'trending_up': return Icons.trending_up;
      case 'help': return Icons.help;
      default: return Icons.category;
    }
  }
}
