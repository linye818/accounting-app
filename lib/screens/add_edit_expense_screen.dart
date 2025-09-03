import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart' as cat;
import '../providers/expense_provider.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? existingExpense;
  final int? preselectedCategoryId; // 从分类点击进入时的预选择
  final bool? preselectedIsExpense;

  const AddEditExpenseScreen({
    Key? key,
    this.existingExpense,
    this.preselectedCategoryId,
    this.preselectedIsExpense,
  }) : super(key: key);

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _description;
  late double _amount;
  late int _categoryId;
  late DateTime _date;
  late bool _isExpense;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 初始化表单数据
    if (widget.existingExpense != null) {
      // 编辑已有账单
      _description = widget.existingExpense!.description;
      _amount = widget.existingExpense!.amount;
      _categoryId = widget.existingExpense!.categoryId;
      _date = widget.existingExpense!.date;
      _isExpense = widget.existingExpense!.isExpense;
      _isLoading = false;
    } else if (widget.preselectedCategoryId != null) {
      // 从分类点击进入
      _description = '';
      _amount = 0.0;
      _categoryId = widget.preselectedCategoryId!;
      _date = DateTime.now();
      _isExpense = widget.preselectedIsExpense ?? true;
      _isLoading = false;
    } else {
      // 新增账单默认值
      _description = '';
      _amount = 0.0;
      _categoryId = -1; // 初始值，会在加载分类后更新
      _date = DateTime.now();
      _isExpense = true;
      // 加载分类后设置默认分类
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDefaultCategory();
      });
    }
  }

  // 加载默认分类（确保有分类可选）
  Future<void> _loadDefaultCategory() async {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    await provider.loadCategories();
    if (provider.categories.isNotEmpty) {
      setState(() {
        _categoryId = provider.categories.first.id;
        _isLoading = false;
      });
    }
  }

  // 提交表单
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final expense = Expense(
        id: widget.existingExpense?.id ?? 0,
        description: _description,
        amount: _amount,
        categoryId: _categoryId,
        date: _date,
        isExpense: _isExpense,
      );

      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      if (widget.existingExpense != null) {
        provider.updateExpense(expense);
      } else {
        provider.addExpense(expense);
      }

      Navigator.pop(context);
    }
  }

  // 选择日期
  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() => _date = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final categories = provider.categories
        .where((cat) => cat.isExpense == _isExpense) // 只显示当前类型（支出/收入）的分类
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingExpense != null ? '编辑账单' : '添加账单'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // 描述
                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(
                        labelText: '账单描述',
                        hintText: '例如：午餐、公交费',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入账单描述';
                        }
                        return null;
                      },
                      onSaved: (value) => _description = value!,
                    ),

                    const SizedBox(height: 16),

                    // 金额
                    TextFormField(
                      initialValue: _amount.toString(),
                      decoration: const InputDecoration(
                        labelText: '金额',
                        prefixText: '¥',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入金额';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return '请输入有效的正数';
                        }
                        return null;
                      },
                      onSaved: (value) => _amount = double.parse(value!),
                    ),

                    const SizedBox(height: 16),

                    // 分类（关键修复：确保分类下拉可用）
                    DropdownButtonFormField<int>(
                      value: _categoryId,
                      decoration: const InputDecoration(labelText: '选择分类'),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Row(
                            children: [
                              Icon(_getCategoryIcon(category.icon), size: 18),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _categoryId = value!),
                      validator: (value) {
                        if (value == null || value == -1) {
                          return '请选择分类';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // 日期
                    ListTile(
                      title: const Text('选择日期'),
                      subtitle: Text(_date == DateTime.now()
                          ? '今天 ${DateFormat('yyyy-MM-dd').format(_date)}'
                          : DateFormat('yyyy-MM-dd').format(_date)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDate,
                    ),

                    const SizedBox(height: 16),

                    // 支出/收入切换
                    SwitchListTile(
                      title: const Text('支出/收入'),
                      subtitle: Text(_isExpense ? '当前：支出' : '当前：收入'),
                      value: _isExpense,
                      onChanged: (value) {
                        setState(() {
                          _isExpense = value;
                          // 切换时自动选择第一个对应类型的分类
                          if (categories.isNotEmpty) {
                            _categoryId = categories.first.id;
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    // 提交按钮
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: Text(widget.existingExpense != null ? '更新账单' : '添加账单'),
                    ),
                  ],
                ),
              ),
            ),
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
}
