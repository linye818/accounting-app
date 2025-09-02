import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../providers/expense_provider.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? existingExpense; // 如果是编辑，这里会传入已有的记录

  const AddEditExpenseScreen({
    super.key,
    this.existingExpense,
  });

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _amount;
  late DateTime _selectedDate;
  late int _selectedCategoryId;
  late bool _isExpense;

  @override
  void initState() {
    super.initState();
    
    // 如果是编辑模式，初始化表单数据为已有记录的值
    if (widget.existingExpense != null) {
      _title = widget.existingExpense!.title;
      _amount = widget.existingExpense!.amount;
      _selectedDate = widget.existingExpense!.date;
      _selectedCategoryId = widget.existingExpense!.categoryId;
      _isExpense = widget.existingExpense!.isExpense;
    } else {
      // 如果是新增模式，初始化默认值
      _title = '';
      _amount = 0.0;
      _selectedDate = DateTime.now();
      _selectedCategoryId = 1; // 默认选中第一个分类（餐饮）
      _isExpense = true; // 默认是支出
    }
  }

  // 保存记录
  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final expense = Expense(
        id: widget.existingExpense?.id, // 编辑模式时保留原ID
        title: _title,
        amount: _amount,
        date: _selectedDate,
        categoryId: _selectedCategoryId,
        isExpense: _isExpense,
      );

      try {
        if (widget.existingExpense == null) {
          // 新增记录
          await Provider.of<ExpenseProvider>(context, listen: false)
              .addExpense(expense);
        } else {
          // 更新记录
          await Provider.of<ExpenseProvider>(context, listen: false)
              .updateExpense(expense);
        }
        // 保存成功后返回首页
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('保存失败: $e')),
          );
        }
      }
    }
  }

  // 选择日期
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingExpense == null ? '添加记录' : '编辑记录',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 标题输入框
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: '标题',
                  hintText: '例如：午餐、打车费',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入标题';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              const SizedBox(height: 16),
              // 金额输入框
              TextFormField(
                initialValue: _amount.toString(),
                decoration: const InputDecoration(
                  labelText: '金额',
                  prefixText: '¥',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入金额';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return '请输入有效的金额';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              const SizedBox(height: 16),
              // 日期选择
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '日期',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 收支类型切换
              SwitchListTile(
                title: Text(_isExpense ? '支出' : '收入'),
                value: _isExpense,
                onChanged: (value) {
                  setState(() {
                    _isExpense = value;
                    // 切换类型时，默认选中对应类型的第一个分类
                    final provider = Provider.of<ExpenseProvider>(context, listen: false);
                    final categories = provider.categories
                        .where((cat) => cat.isExpense == _isExpense)
                        .toList();
                    if (categories.isNotEmpty) {
                      _selectedCategoryId = categories.first.id;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              // 分类选择
              Consumer<ExpenseProvider>(
                builder: (ctx, provider, _) {
                  // 只显示当前类型（支出/收入）的分类
                  final filteredCategories = provider.categories
                      .where((cat) => cat.isExpense == _isExpense)
                      .toList();

                  return DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: '分类',
                      border: OutlineInputBorder(),
                    ),
                    items: filteredCategories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Row(
                          children: [
                            Icon(MdiIcons.fromString(category.icon)),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return '请选择分类';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              // 保存按钮
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
