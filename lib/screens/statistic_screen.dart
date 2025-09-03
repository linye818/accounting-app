import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../models/account_category.dart';

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
  double _totalExpense = 0.0;
  double _totalIncome = 0.0;
  Map<String, double> _categoryExpense = {};

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
      await provider.loadCategories();
      
      _calculateStats(provider.expenses, provider.categories);
    } catch (e) {
      print('统计页加载错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateStats(List<Expense> expenses, List<AccountCategory> categories) {
    double expenseSum = 0.0;
    double incomeSum = 0.0;
    Map<String, double> categoryMap = {};

    for (final expense in expenses) {
      if (expense.date.isAfter(_dateRange.start) && expense.date.isBefore(_dateRange.end)) {
        if (expense.isExpense) {
          expenseSum += expense.amount;
          final category = categories.firstWhere(
            (c) => c.id == expense.categoryId,
            orElse: () => AccountCategory(id: -1, name: '未知', icon: 'help', isExpense: true),
          );
          categoryMap[category.name] = (categoryMap[category.name] ?? 0) + expense.amount;
        } else {
          incomeSum += expense.amount;
        }
      }
    }

    setState(() {
      _totalExpense = expenseSum;
      _totalIncome = incomeSum;
      _categoryExpense = categoryMap;
    });
  }

  Future<void> _selectDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (pickedRange != null) {
      setState(() {
        _dateRange = pickedRange;
        _loadData(); // 重新计算统计数据
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('收支统计'),
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        '统计周期: ${DateFormat('yyyy-MM-dd').format(_dateRange.start)} 至 ${DateFormat('yyyy-MM-dd').format(_dateRange.end)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                                  '¥${_totalIncome.toStringAsFixed(2)}',
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
                                  '¥${_totalExpense.toStringAsFixed(2)}',
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
                                  '¥${(_totalIncome - _totalExpense).toStringAsFixed(2)}',
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
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('消费分类占比', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 250,
                            child: _categoryExpense.isEmpty
                                ? const Center(child: Text('暂无支出数据'))
                                : charts.PieChart(
                                    [
                                      charts.Series<MapEntry<String, double>, String>(
                                        id: 'Expense',
                                        domainFn: (entry, _) => entry.key,
                                        measureFn: (entry, _) => entry.value.toInt(),
                                        data: _categoryExpense.entries.toList(),
                                        labelAccessorFn: (entry, _) =>
                                            '${entry.key}: ¥${entry.value.toStringAsFixed(2)}',
                                      ),
                                    ],
                                    defaultRenderer: charts.ArcRendererConfig(
                                      arcWidth: 60,
                                      arcRendererDecorators: [
                                        charts.ArcLabelDecorator(
                                          labelPosition: charts.ArcLabelPosition.outside,
                                        ),
                                      ],
                                    ),
                                  ),
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
}
