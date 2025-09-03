import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart'; // 新增导入 Expense 类

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({Key? key}) : super(key: key);

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );
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
      await provider.loadExpenses();
    } catch (e) {
      print('统计页加载错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 计算指定周期内的收支
  Map<String, double> _calculateStats(List<Expense> allExpenses) {
    double income = 0;
    double expense = 0;
    for (final exp in allExpenses) {
      if (exp.date.isAfter(_dateRange.start) && exp.date.isBefore(_dateRange.end)) {
        if (exp.isExpense) expense += exp.amount;
        else income += exp.amount;
      }
    }
    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }

  // 选择日期范围
  Future<void> _selectDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (pickedRange != null) {
      setState(() => _dateRange = pickedRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final stats = _calculateStats(provider.expenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('统计'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDateRange,
            tooltip: '选择日期范围',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 日期范围显示
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        '统计周期: ${_dateFormat.format(_dateRange.start)} 至 ${_dateFormat.format(_dateRange.end)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 收支统计卡片
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 2,
                          color: Colors.green[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text('总收入', style: TextStyle(color: Colors.green)),
                                const SizedBox(height: 8),
                                Text(
                                  '¥${stats['income']?.toStringAsFixed(2) ?? '0.00'}',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Card(
                          elevation: 2,
                          color: Colors.red[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text('总支出', style: TextStyle(color: Colors.red)),
                                const SizedBox(height: 8),
                                Text(
                                  '¥${stats['expense']?.toStringAsFixed(2) ?? '0.00'}',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Card(
                          elevation: 2,
                          color: Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text('账户结余', style: TextStyle(color: Colors.blue)),
                                const SizedBox(height: 8),
                                Text(
                                  '¥${stats['balance']?.toStringAsFixed(2) ?? '0.00'}',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 趋势图（临时占位，后续可扩展）
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('消费趋势', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Container(
                            height: 200,
                            color: Colors.grey[100],
                            alignment: Alignment.center,
                            child: const Text('消费趋势图表（后续扩展）'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
}
