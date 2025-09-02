import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import 'add_edit_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 初始化时加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Provider.of<ExpenseProvider>(context, listen: false)
        .loadExpenses();
    await Provider.of<ExpenseProvider>(context, listen: false)
        .loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.expenses;

    double totalExpense = 0;
    double totalIncome = 0;

    for (final expense in expenses) {
      if (expense.isExpense) {
        totalExpense += expense.amount;
      } else {
        totalIncome += expense.amount;
      }
    }

    return Scaffold
