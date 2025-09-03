import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/account_category.dart';

class CategoryManageScreen extends StatefulWidget {
  const CategoryManageScreen({Key? key}) : super(key: key);

  @override
  State<CategoryManageScreen> createState() => _CategoryManageScreenState();
}

class _CategoryManageScreenState extends State<CategoryManageScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _iconController = TextEditingController();
  bool _isExpense = true;
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
      await provider.loadCategories();
    } catch (e) {
      print('分类管理页加载错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addCategory() {
    if (_nameController.text.isEmpty || _iconController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名称和图标不能为空')),
      );
      return;
    }

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    provider.addCategory(
      AccountCategory(
        name: _nameController.text,
        icon: _iconController.text,
        isExpense: _isExpense,
      ),
    );

    _nameController.clear();
    _iconController.clear();
    FocusScope.of(context).unfocus();
  }

  void _deleteCategory(int categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除分类后，该分类下的账单将显示为“未知分类”，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<ExpenseProvider>(context, listen: false);
              provider.deleteCategory(categoryId);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('分类管理')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: '分类名称'),
                            autofocus: true,
                          ),
                          TextField(
                            controller: _iconController,
                            decoration: const InputDecoration(
                              labelText: '图标名称（参考 Material Icons）',
                              hintText: '如：restaurant、directions_car',
                            ),
                          ),
                          SwitchListTile(
                            title: const Text('是否为支出分类'),
                            value: _isExpense,
                            onChanged: (value) => setState(() => _isExpense = value),
                          ),
                          ElevatedButton(
                            onPressed: _addCategory,
                            child: const Text('添加分类'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('当前分类', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ListTile(
                          leading: Icon(
                            _getCategoryIcon(category.icon),
                            color: category.isExpense ? Colors.red : Colors.green,
                          ),
                          title: Text(category.name),
                          subtitle: Text(category.isExpense ? '支出分类' : '收入分类'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCategory(category.id!),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
