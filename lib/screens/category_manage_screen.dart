import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/account_category.dart'; // 引用重命名后的分类模型

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
    // 加载分类数据
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  // 加载分类数据
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

  // 添加分类
  void _addCategory() {
    if (_nameController.text.isEmpty || _iconController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名称和图标不能为空')),
      );
      return;
    }

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    provider.addCategory(
      AccountCategory( // 类名更新为 AccountCategory
        name: _nameController.text,
        icon: _iconController.text,
        isExpense: _isExpense,
      ),
    );

    // 清空输入框
    _nameController.clear();
    _iconController.clear();
    FocusScope.of(context).unfocus();
  }

  // 删除分类（修复语法：闭合所有括号）
  void _deleteCategory(int categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除分类后，该分类下的账单将显示为“未知分类”，是否继续？'),
        actions: [
          // 取消按钮
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          // 确认删除按钮
          TextButton(
            onPressed: () {
              final provider = Provider.of<ExpenseProvider>(context, listen: false);
              provider.deleteCategory(categoryId);
              Navigator.pop(context);
            },
            child: const Text('删除'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  // 获取分类图标（修复语法）
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

  // 修复 build 方法（完整实现，闭合所有括号）
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('分类管理'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 加载中
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 添加分类卡片
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('添加新分类', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          // 分类名称
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: '分类名称',
                              border: OutlineInputBorder(),
                              hintText: '如：奶茶、打车',
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 图标名称（参考 Material Icons）
                          TextField(
                            controller: _iconController,
                            decoration: const InputDecoration(
                              labelText: '图标名称',
                              border: OutlineInputBorder(),
                              hintText: '如：coffee、taxi（参考 Material Icons）',
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 支出/收入切换
                          SwitchListTile(
                            title: const Text('分类类型'),
                            subtitle: Text(_isExpense ? '支出分类' : '收入分类'),
                            value: _isExpense,
                            onChanged: (value) => setState(() => _isExpense = value),
                          ),
                          const SizedBox(height: 12),
                          // 添加按钮
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _addCategory,
                              child: const Text('添加分类'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 现有分类列表
                  const Text('现有分类', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ListTile(
                          leading: Icon(
                            _getCategoryIcon(category.icon),
                            color: category.isExpense ? Colors.redAccent : Colors.greenAccent,
                            size: 24,
                          ),
                          title: Text(category.name),
                          subtitle: Text(category.isExpense ? '支出' : '收入'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCategory(category.id!), // 数据库分类id非空，用!解包
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
