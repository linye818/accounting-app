import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'detail_screen.dart';

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
      appBar: AppBar(title: const Text('账单列表')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : expenses.isEmpty
              ? const Center(child: Text('暂无账单记录'))
              : ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ListTile(
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
                    );
                  },
                ),
    );
  }
}
