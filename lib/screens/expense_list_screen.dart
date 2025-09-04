import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'detail_screen.dart';
import 'add_edit_expense_screen.dart';
import '../models/account_category.dart'; // 新增导入

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExpenses());
  }

  Future<void> _loadExpenses() async {
    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      await provider.initDatabase();
      await provider.loadExpenses();
    } catch (e) {
      print('账单列表加载错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final expenses = provider.expenses;

    return Scaffold(
      appBar: AppBar(title: const Text('账单明细')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditExpenseScreen()),
        ),
        child: const Icon(Icons.add),
        tooltip: '添加账单',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : expenses.isEmpty
              ? const Center(child: Text('暂无账单记录，点击右下角“+”添加'))
              : ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    final category = provider.categories.firstWhere(
                      (c) => c.id == expense.categoryId,
                      // 修复：使用导入的 AccountCategory 类
                      orElse: () => AccountCategory(
                        id: -1,
                        name: '未知',
                        icon: 'help',
                        isExpense: true,
                      ),
                    );
                    return ListTile(
                      leading: Icon(
                        _getCategoryIcon(category.icon),
                        color: expense.isExpense ? Colors.redAccent : Colors.greenAccent,
                      ),
                      title: Text(expense.description),
                      subtitle: Text(DateFormat('yyyy-MM-dd').format(expense.date)),
                      trailing: Text(
                        '¥${expense.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: expense.isExpense ? Colors.redAccent : Colors.greenAccent,
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(expense: expense),
                        ),
                      ),
                      onLongPress: () => _showDeleteDialog(expense.id),
                    );
                  },
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

  void _showDeleteDialog(int expenseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后账单将不可恢复，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<ExpenseProvider>(context, listen: false);
              provider.deleteExpense(expenseId);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
