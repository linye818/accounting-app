import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
// 关键：引用新的分类模型，删除旧的 category.dart 引用
import '../models/account_category.dart' as cat;

class DetailScreen extends StatefulWidget {
  final Expense expense;

  const DetailScreen({Key? key, required this.expense}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isLoading = true;
  late cat.AccountCategory _category; // 类型改为 AccountCategory

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategory());
  }

  Future<void> _loadCategory() async {
    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      await provider.initDatabase();
      await provider.loadCategories();
      
      // 查找分类，找不到时返回“未知分类”（类名已改）
      final foundCategory = provider.categories.firstWhere(
        (c) => c.id == widget.expense.categoryId,
        orElse: () => cat.AccountCategory(
          id: -1, 
          name: '未知', 
          icon: 'help', 
          isExpense: true
        ),
      );
      setState(() {
        _category = foundCategory;
        _isLoading = false;
      });
    } catch (e) {
      print('明细页加载错误: $e');
      setState(() => _isLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('账单明细')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(
                      _getCategoryIcon(_category.icon),
                      color: widget.expense.isExpense ? Colors.redAccent : Colors.greenAccent,
                      size: 32,
                    ),
                    title: Text(_category.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text(widget.expense.isExpense ? '支出账单' : '收入账单'),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('金额'),
                    trailing: Text(
                      '¥${widget.expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.expense.isExpense ? Colors.redAccent : Colors.greenAccent,
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('描述'),
                    trailing: Text(widget.expense.description, style: const TextStyle(fontSize: 16)),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('日期'),
                    trailing: Text(
                      DateFormat('yyyy-MM-dd').format(widget.expense.date),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
