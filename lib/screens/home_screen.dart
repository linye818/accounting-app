import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../models/category.dart';
import 'add_edit_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');

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
    final loc = AppLocalizations.of(context)!;
    final provider = Provider.of<ExpenseProvider>(context);
    final expenses = provider.expenses;

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
      appBar: AppBar(
        title: Text(loc.appTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 本月总收入卡片
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.totalIncomeThisMonth, style: const TextStyle(color: Colors.grey)),
                          Text(_currencyFormat.format(totalIncome), style: const TextStyle(fontSize: 20, color: Colors.green)),
                          Text('本月', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.accountBalance, style: const TextStyle(color: Colors.grey)),
                          Text(_currencyFormat.format(balance), style: const TextStyle(fontSize: 20, color: Colors.blue)),
                          Text(loc.currentBalance, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const Icon(Icons.description_outlined, color: Colors.blue),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 消费趋势卡片
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(loc.consumptionTrend, style: const TextStyle(fontSize: 16)),
                          Text(loc.recent7Days, style: const TextStyle(color: Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 这里可以后续接入图表库（如 charts_flutter）实现趋势图
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
                  Text(loc.frequentCategories, style: const TextStyle(fontSize: 16)),
                  Text(loc.usageFrequency, style: const TextStyle(color: Colors.blue, fontSize: 12)),
                ],
              ),

              const SizedBox(height: 12),

              // 常用分类按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCategoryButton(loc.diningFood, Icons.restaurant, Colors.green),
                  _buildCategoryButton(loc.transportation, Icons.directions_car, Colors.red),
                  _buildCategoryButton(loc.shoppingList, Icons.shopping_cart, Colors.orange),
                  _buildCategoryButton(loc.housingUtilities, Icons.home, Colors.purple),
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
