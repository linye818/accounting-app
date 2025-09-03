import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/category.dart' as cat;
import 'add_edit_expense_screen.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      await provider.initDatabase();
      await provider.loadCategories();
      await provider.loadExpenses();
    } catch (e) {
      print('明细页加载错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final expenses = provider.expenses;
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('记账本')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : expenses.isEmpty
              ? const Center(child: Text('暂无账单记录'))
              : ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    final category = categories.firstWhere(
                      (c) => c.id == expense.categoryId,
                      orElse: () => cat.Category(id: -1, name: '未知', icon: 'help', isExpense: true),
                    );
                    return ListTile(
                      leading: Icon(
                        _getCategoryIcon(category.icon),
                        color: expense.isExpense ? Colors.red : Colors.green,
                      ),
                      title: Text(expense.description),
                      subtitle: Text('${_dateFormat.format(expense.date)} | ${category.name}'),
                      trailing: Text(
                        '${expense.isExpense ? '-' : '+'}${_currencyFormat.format(expense.amount)}',
                        style: TextStyle(
                          color: expense.isExpense ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditExpenseScreen()),
        ),
        child: const Icon(Icons.add),
        tooltip: '记一笔',
      ),
    );
  }

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '¥');

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'attach_money': return Icons.attach_money;
      default: return Icons.category;
    }
  }
}
