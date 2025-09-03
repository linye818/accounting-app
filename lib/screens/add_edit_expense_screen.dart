import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../models/account_category.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense; // 编辑时传入已有账单，添加时为null

  const AddEditExpenseScreen({Key? key, this.expense}) : super(key: key);

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late int _categoryId;
  late DateTime _date;
  late bool _isExpense;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 初始化表单数据
    if (widget.expense != null) {
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toStringAsFixed(2);
      _categoryId = widget.expense!.categoryId;
      _date = widget.expense!.date;
      _isExpense = widget.expense!.isExpense;
    } else {
      _categoryId = 1; // 默认分类（餐饮）
      _date = DateTime.now();
      _isExpense = true; // 默认支出
    }
    // 加载分类数据
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  // 加载分类
  Future<void> _loadData() async {
    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      await provider.initDatabase();
      await provider.loadCategories();
    } catch (e) {
      print('加载分类错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 提交表单
  void _submitForm() {
    // 验证表单
    if (_descriptionController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('描述和金额不能为空')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的正数金额（如 100 或 100.50）')),
      );
      return;
    }

    // 提交数据
    final expense = Expense(
      id: widget.expense?.id ?? 0,
      description: _descriptionController.text,
      amount: amount,
      categoryId: _categoryId,
      date: _date,
      isExpense: _isExpense,
    );

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    if (widget.expense == null) {
      provider.addExpense(expense);
    } else {
      provider.updateExpense(expense);
    }

    Navigator.pop(context);
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

  // 获取分类图标
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
    final filteredCategories = provider.categories
        .where((cat) => cat.isExpense == _isExpense)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? '添加账单' : '编辑账单'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // 描述输入框
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '账单描述',
                      border: OutlineInputBorder(),
                      hintText: '如：午餐、打车费',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // 金额输入框
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: '金额',
                      prefixText: '¥',
                      border: OutlineInputBorder(),
                      hintText: '请输入金额',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // 分类选择下拉框
                  DropdownButtonFormField<int>(
                    value: _categoryId,
                    decoration: const InputDecoration(
                      labelText: '选择分类',
                      border: OutlineInputBorder(),
                    ),
                    items: filteredCategories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id!, // 数据库分类id非空
                        child: Row(
                          children: [
                            Icon(_getCategoryIcon(category.icon), size: 18),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _categoryId = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // 支出/收入切换
                  SwitchListTile(
                    title: const Text('支出 / 收入'),
                    value: _isExpense,
                    onChanged: (value) {
                      setState(() {
                        _isExpense = value;
                        // 切换类型时默认选中第一个分类
                        if (filteredCategories.isNotEmpty) {
                          _categoryId = filteredCategories.first.id!;
                        }
                      });
                    },
                    secondary: Icon(_isExpense ? Icons.money_off : Icons.attach_money),
                  ),
                  const SizedBox(height: 16),

                  // 日期选择
                  ListTile(
                    title: const Text('选择日期'),
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(_date)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectDate,
                  ),
                  const SizedBox(height: 24),

                  // 提交按钮（关键修复：移除 styleFrom 中的 fontSize，在 Text 内设置）
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        // 移除错误的 fontSize 参数
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.expense == null ? '添加账单' : '保存修改',
                        style: const TextStyle(fontSize: 18), // 正确设置字体大小的位置
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
