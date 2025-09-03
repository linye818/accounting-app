import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../models/category.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;

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
    if (widget.expense != null) {
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _categoryId = widget.expense!.categoryId;
      _date = widget.expense!.date;
      _isExpense = widget.expense!.isExpense;
    } else {
      _categoryId = 1;
      _date = DateTime.now();
      _isExpense = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      await provider.initDatabase();
      await provider.loadCategories();
    } catch (e) {
      print('添加/编辑账单页加载错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _submitForm() {
    if (_descriptionController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('描述和金额不能为空')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的金额')),
      );
      return;
    }

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
        .where((cat) => cat.isExpense == _isExpense)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? '添加账单' : '编辑账单'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: ListView(
                  children: [
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: '账单描述'),
                    ),
                    TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: '金额',
                        prefixText: '¥',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    DropdownButtonFormField<int>(
                      value: _categoryId,
                      decoration: const InputDecoration(labelText: '选择分类'),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id!,
                          child: Row(
                            children: [
                              Icon(
                                _getCategoryIcon(category.icon),
                                size: 18,
                              ),
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
                    SwitchListTile(
                      title: const Text('是否为支出'),
                      value: _isExpense,
                      onChanged: (value) {
                        setState(() {
                          _isExpense = value;
                          if (categories.isEmpty && value) {
                            _categoryId = 1;
                          } else if (categories.isEmpty && !value) {
                            _categoryId = 101;
                          }
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('选择日期'),
                      subtitle: Text(DateFormat('yyyy-MM-dd').format(_date)),
                      onTap: _selectDate,
                    ),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(widget.expense == null ? '添加' : '保存'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'home':
        return Icons.home;
      case 'movie':
        return Icons.movie;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'more_horiz':
        return Icons.more_horiz;
      case 'work':
        return Icons.work;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'trending_up':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }
}
