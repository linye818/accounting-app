import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/account_category.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({Key? key}) : super(key: key);

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  bool _isLoading = true;
  double _totalExpense = 0.0;
  double _totalIncome = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  // 加载账单数据并计算收支总和
  Future<void> _loadData() async {
    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      await provider.initDatabase();
      await provider.loadExpenses(); // 现在该方法已能正常识别

      // 计算总支出和总收入
      double expenseSum = 0.0;
      double incomeSum = 0.0;
      for (var expense in provider.expenses) {
        if (expense.isExpense) {
          expenseSum += expense.amount;
        } else {
          incomeSum += expense.amount;
        }
      }

      setState(() {
        _totalExpense = expenseSum;
        _totalIncome = incomeSum;
        _isLoading = false;
      });
    } catch (e) {
      print('统计页加载错误: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('收支统计')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 收支概览卡片
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // 总支出
                          Column(
                            children: [
                              const Text('总支出', style: TextStyle(fontSize: 16)),
                              const SizedBox(height: 8),
                              Text(
                                '¥${_totalExpense.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                          // 总收入
                          Column(
                            children: [
                              const Text('总收入', style: TextStyle(fontSize: 16)),
                              const SizedBox(height: 8),
                              Text(
                                '¥${_totalIncome.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.greenAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 提示文本（可后续添加分类统计图表）
                  const Center(
                    child: Text(
                      '分类统计图表（待实现）',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
