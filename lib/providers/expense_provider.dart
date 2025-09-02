import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../database/database_helper.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<Category> _categories = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 获取所有记账记录
  List<Expense> get expenses => _expenses;

  // 获取所有分类
  List<Category> get categories => _categories;

  // 加载所有数据（从数据库读取到内存中）
  Future<void> loadData() async {
    _expenses = await _dbHelper.getAllExpenses();
    _categories = await _dbHelper.getAllCategories();
    notifyListeners(); // 通知所有页面数据已更新
  }

  // 添加新的记账记录
  Future<void> addExpense(Expense expense) async {
    await _dbHelper.insertExpense(expense);
    await loadData(); // 重新加载数据
  }

  // 更新记账记录
  Future<void> updateExpense(Expense expense) async {
    await _dbHelper.updateExpense(expense);
    await loadData(); // 重新加载数据
  }

  // 删除记账记录
  Future<void> deleteExpense(int id) async {
    await _dbHelper.deleteExpense(id);
    await loadData(); // 重新加载数据
  }

  // 根据ID查找分类名称
  String getCategoryName(int categoryId) {
    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => Category(id: -1, name: '未知', icon: 'question_mark', isExpense: true),
    );
    return category.name;
  }

  // 根据ID查找分类图标
  String getCategoryIcon(int categoryId) {
    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => Category(id: -1, name: '未知', icon: 'question_mark', isExpense: true),
    );
    return category.icon;
  }

  // 计算指定日期范围内的总支出
  double getTotalExpense({DateTime? startDate, DateTime? endDate}) {
    return _expenses
        .where((exp) => exp.isExpense)
        .where((exp) => startDate == null || exp.date.isAfter(startDate))
        .where((exp) => endDate == null || exp.date.isBefore(endDate))
        .fold(0, (sum, exp) => sum + exp.amount);
  }

  // 计算指定日期范围内的总收入
  double getTotalIncome({DateTime? startDate, DateTime? endDate}) {
    return _expenses
        .where((exp) => !exp.isExpense)
        .where((exp) => startDate == null || exp.date.isAfter(startDate))
        .where((exp) => endDate == null || exp.date.isBefore(endDate))
        .fold(0, (sum, exp) => sum + exp.amount);
  }
}
