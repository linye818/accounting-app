import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? existingExpense;

  const AddEditExpenseScreen({Key? key, this.existingExpense}) : super(key: key);

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _description; // 用 description 替代 title，匹配 Expense 类
  late double _amount;
  late int _categoryId;
  late DateTime _date;
  late bool _isExpense;

  @override
  void initState() {
    super.initState();
    // 初始化：编辑时加载现有数据，新增时用默认值
    if (widget.existingExpense != null) {
      _description = widget.existingExpense!.description; // 改用 description
      _amount = widget.existingExpense!.amount;
      _categoryId = widget.existingExpense!.categoryId;
      _date = widget.existingExpense!.date;
      _isExpense = widget.existingExpense!.isExpense;
    } else {
      _description = '';
      _amount = 0.0;
      _categoryId = 1; // 默认分类ID
      _date = DateTime.now();
      _isExpense = true; // 默认是支出
    }
  }

  // 提交表单：新增或更新支出
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final expense = Expense(
        id: widget.existingExpense?.id ?? 0, // 编辑时用原ID，新增时暂用0（数据库会自动生成）
        description: _description, // 传递 description，而非 title
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

      Navigator.pop(context); // 返回首页
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
    final categories = provider.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingExpense != null ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 描述输入框（替代原 title 输入框）
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),

              // 金额输入框
              TextFormField(
                initialValue: _amount.toString(),
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value!),
              ),

              // 分类下拉选择
              DropdownButtonFormField<int>(
                value: _categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map((category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _categoryId = value!),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),

              // 日期选择
              ListTile(
                title: Text('Date: ${DateFormat.yMd().format(_date)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),

              // 支出/收入切换
              SwitchListTile(
                title: const Text('Is Expense?'),
                value: _isExpense,
                onChanged: (value) => setState(() => _isExpense = value),
              ),

              // 提交按钮
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.existingExpense != null ? 'Update' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
