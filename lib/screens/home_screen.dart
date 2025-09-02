import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    await provider.loadExpenses();
    await provider.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final expenses = provider.expenses;

    double totalIncome = 0;
    double totalExpense = 0;
    for (final expense in expenses) {
      if (expense.isExpense) totalExpense += expense.amount;
      else totalIncome += expense.amount;
    }
    double balance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(title: const Text('记账应用')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 本月总收入卡片
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('本月总收入', style: TextStyle(color: Colors.grey)),
                          Text('¥$totalIncome', style: const TextStyle(fontSize: 20, color: Colors.green)),
                          const Text('本月', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const Icon(Icons.download, color: Colors.green),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 账户结余卡片
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('账户结余', style: TextStyle(color: Colors.grey)),
                          Text('¥$balance', style: const TextStyle(fontSize: 20, color: Colors.blue)),
                          const Text('当前余额', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const Icon(Icons.description_outlined, color: Colors.blue),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 消费趋势（临时占位）
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('消费趋势', style: TextStyle(fontSize: 16)),
                          const Text('最近7天', style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 150,
                        color: Colors.grey[100],
                        alignment: Alignment.center,
                        child: const Text('消费趋势图表（后续扩展）'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 常用分类标题
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('常用分类', style: TextStyle(fontSize: 16)),
                  const Text('使用频率高', style: TextStyle(color: Colors.blue, fontSize: 12)),
                ],
              ),

              const SizedBox(height: 12),

              // 常用分类按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCategoryButton('餐饮美食', Icons.restaurant, Colors.green),
                  _buildCategoryButton('交通出行', Icons.directions_car, Colors.red),
                  _buildCategoryButton('购物消费', Icons.shopping_cart, Colors.orange),
                  _buildCategoryButton('住房租金', Icons.home, Colors.purple),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryButton(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
