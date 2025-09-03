import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../models/category.dart' as cat;

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({Key? key, required this.expense}) : super(key: key);

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late int _categoryId;
  late DateTime _date;
  late bool _isExpense;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.expense.description;
    _amountController.text = widget.expense.amount.toString();
    _categoryId = widget.expense.categoryId;
    _date = widget.expense.date;
    _isExpense = widget.expense.isExpense;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      await provider.initDatabase();
      await provider.loadCategories();
    } catch (e) {
      print('编辑账单页加载错误: $e');
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

    final updatedExpense = Expense(
      id: widget.expense.id,
      description: _descriptionController.text,
      amount: amount,
      categoryId: _categoryId,
      date: _date,
      isExpense: _isExpense,
    );

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    provider.updateExpense(updatedExpense);
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
      appBar: AppBar(title: const Text('编辑账单')),
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
                          value: category.id,
                          child: Row(
                            children: [
                              Icon(_getCategoryIcon(category.icon), size: 18),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
