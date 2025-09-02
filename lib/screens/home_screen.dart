import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../providers/expense_provider.dart';
import 'add_edit_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 初始化时加载数据
    _loadData();
  }

  // 从数据库加载数据
  Future<void> _loadData() async {
    try {
      await Provider.of<ExpenseProvider>(context, listen: false).loadData();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据失败: $e')),
        );
      }
    }
  }

  // 切换显示的日期
  void _changeDate(bool isNextMonth) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + (isNextMonth ? 1 : -1),
      );
    });
  }

  // 获取当月的记录
  List<Expense> _getMonthlyExpenses(ExpenseProvider provider) {
    final year = _selectedDate.year;
    final month = _selectedDate.month;
    
    return provider.expenses.where((exp) {
      return exp.date.year == year && exp.date.month == month;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记账本'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ExpenseProvider>(
              builder: (ctx, provider, _) {
                final monthlyExpenses = _getMonthlyExpenses(provider);
                final totalExpense = provider.getTotalExpense(
                  startDate: DateTime(_selectedDate.year, _selectedDate.month, 1),
                  endDate: DateTime(_selectedDate.year, _selectedDate.month + 1, 0),
                );
                final totalIncome = provider.getTotalIncome(
                  startDate: DateTime(_selectedDate.year, _selectedDate.month, 1),
                  endDate: DateTime(_selectedDate.year, _selectedDate.month + 1, 0),
                );

                return Column(
                  children: [
                    // 月份选择和收支统计
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // 月份选择器
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: () => _changeDate(false),
                              ),
                              Text(
                                DateFormat('yyyy年MM月').format(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: () => _changeDate(true),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 收支统计卡片
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      children: [
                                        const Text(
                                          '总支出',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '¥${totalExpense.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      children: [
                                        const Text(
                                          '总收入',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '¥${totalIncome.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // 记录列表
                    Expanded(
                      child: monthlyExpenses.isEmpty
                          ? const Center(
                              child: Text(
                                '本月暂无记录',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: monthlyExpenses.length,
                              itemBuilder: (ctx, index) {
                                final expense = monthlyExpenses[index];
                                return Slidable(
                                  key: Key(expense.id.toString()),
                                  actionPane: const SlidableDrawerActionPane(),
                                  actions: [
                                    IconSlideAction(
                                      caption: '编辑',
                                      color: Colors.blue,
                                      icon: Icons.edit,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (ctx) => AddEditExpenseScreen(
                                            existingExpense: expense,
                                          ),
                                        ),
                                      ).then((_) => _loadData()),
                                    ),
                                  ],
                                  secondaryActions: [
                                    IconSlideAction(
                                      caption: '删除',
                                      color: Colors.red,
                                      icon: Icons.delete,
                                      onTap: () async {
                                        await provider.deleteExpense(expense.id!);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('记录已删除')),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Icon(
                                        expense.isExpense
                                            ? MdiIcons.fromString(provider.getCategoryIcon(expense.categoryId)) ??
                                                MdiIcons.cash
                                            : MdiIcons.fromString(provider.getCategoryIcon(expense.categoryId)) ??
                                                MdiIcons.arrowRightCircle,
                                      ),
                                    ),
                                    title: Text(expense.title),
                                    subtitle: Text(
                                      '${provider.getCategoryName(expense.categoryId)} • ${expense.formattedDate}',
                                    ),
                                    trailing: Text(
                                      expense.isExpense
                                          ? '-${expense.formattedAmount}'
                                          : '+${expense.formattedAmount}',
                                      style: TextStyle(
                                        color: expense.isExpense ? Colors.red : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
      // 添加新记录的按钮
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => const AddEditExpenseScreen(),
          ),
        ).then((_) => _loadData()),
      ),
    );
  }
}
