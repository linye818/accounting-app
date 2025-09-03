import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/category.dart' as cat;
import 'add_edit_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '¥');
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // 加载数据（修复：确保数据库初始化完成）
  Future<void> _loadData() async {
    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      await provider.initDatabase(); // 关键：先初始化数据库
      await provider.loadCategories();
      await provider.loadExpenses();
    } catch (e) {
      print('加载数据错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final expenses = provider.expenses;
    final categories = provider.categories;

    // 计算统计数据
    double totalIncome = 0;
    double totalExpense = 0;
    for (final expense in expenses) {
      if (expense.isExpense) {
        totalExpense += expense.amount;
      } else {
        totalIncome += expense.amount;
      }
    }
    double balance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(title: const Text('记账应用')),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 统计卡片
                    _buildStatCards(totalIncome, totalExpense, balance),
                    
                    const SizedBox(height: 20),
                    
                    // 常用分类
                    const Text('常用分类', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildCategoryGrid(categories),
                    
                    const SizedBox(height: 20),
                    
                    // 最近账单列表（关键：添加账单展示）
                    const Text('最近账单', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    expenses.isEmpty
                        ? const Center(child: Text('暂无账单记录'))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: expenses.length,
                            itemBuilder: (context, index) {
                              final expense = expenses[index];
                              // 查找对应的分类
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
                                subtitle: Text(_dateFormat.format(expense.date)),
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
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditExpenseScreen()),
        ),
        child: const Icon(Icons.add),
        tooltip: '添加账单',
      ),
    );
  }

  // 构建统计卡片
  Widget _buildStatCards(double income, double expense, double balance) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Text('本月收入', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    _currencyFormat.format(income),
                    style: const TextStyle(color: Colors.green, fontSize: 18),
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
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Text('本月支出', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    _currencyFormat.format(expense),
                    style: const TextStyle(color: Colors.red, fontSize: 18),
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
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Text('账户余额', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    _currencyFormat.format(balance),
                    style: const TextStyle(color: Colors.blue, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 构建分类网格
  Widget _buildCategoryGrid(List<cat.Category> categories) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 0.8,
      children: categories.map((category) {
        return GestureDetector(
          onTap: () => _navigateToAddExpense(category.id, category.isExpense),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: category.isExpense ? Colors.red[100] : Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(category.icon),
                  color: category.isExpense ? Colors.red : Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                category.name,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 根据图标名称获取图标
  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'attach_money': return Icons.attach_money;
      default: return Icons.category;
    }
  }

  // 跳转到添加账单页面（预填分类）
  void _navigateToAddExpense(int categoryId, bool isExpense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditExpenseScreen(
          preselectedCategoryId: categoryId,
          preselectedIsExpense: isExpense,
        ),
      ),
    );
  }
}
