import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/category.dart';

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
      Category(
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
        content: const Text('删除分类后，该分类下的账单将变为“未知”分类，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<ExpenseProvider>(context, listen: false);
