import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../models/account_category.dart'; // 引用重命名后的分类类

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
    // 初始化表单数据（编辑时加载已有数据，添加时用默认值）
    if (widget.expense != null) {
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _categoryId = widget.expense!.categoryId;
      _date = widget.expense!.date;
      _isExpense = widget.expense!.isExpense;
    } else {
      _categoryId = 1; // 默认分类ID（餐饮）
      _date = DateTime.now();
      _isExpense = true; // 默认是支出
    }
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
      print('添加/编辑账单页加载错误: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 提交表单（添加/编辑账单）
  void _submitForm() {
    // 验证表单
    if (_descriptionController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('描述和金额不能为空')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的金额（如 100 或 100.50）')),
      );
      return;
    }

    // 构建账单对象
    final expense = Expense(
      id: widget.expense?.id ?? 0, // 编辑时用已有ID，添加时临时设为0（数据库会自动生成）
      description: _descriptionController.text,
      amount: amount,
      categoryId: _categoryId,
      date: _date,
      isExpense: _isExpense,
    );

    // 提交到Provider
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    if (widget.expense == null) {
      provider.addExpense(expense);
    } else {
      provider.updateExpense(expense);
    }

    // 返回上一页
    Navigator.pop(context);
  }

  // 选择日期
  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020), // 最早可选2020年
      lastDate: DateTime.now(),   // 最晚可选今天
    );
    if (pickedDate != null) {
      setState(() => _date = pickedDate);
    }
  }

  // 获取分类对应的图标
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
    // 过滤当前类型（支出/收入）的分类
    final filteredCategories = provider.categories
        .where((cat) => cat.isExpense == _isExpense)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? '添加账单' : '编辑账单'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 加载中
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // 账单描述
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '账单描述',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 16),

                  // 金额
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: '金额',
                      prefixText: '¥',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 16),

                  // 分类选择
                  DropdownButtonFormField<int>(
                    value: _categoryId,
                    decoration: const InputDecoration(
                      labelText: '选择分类',
                      border: OutlineInputBorder(),
                    ),
                    // 生成分类选项（修复空安全：用 ! 确认id非空，数据库分类一定有id）
                    items: filteredCategories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id!,
                        child: Row(
                          children: [
                            Icon(_getCategoryIcon(category.icon), size: 18),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    // 切换分类
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
                        // 切换类型时，默认选中第一个分类（修复空安全）
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
