import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense.dart';
// 使用别名解决Category类冲突
import '../models/category.dart' as cat;

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<cat.Category> _categories = [];
  Database? _database;

  UnmodifiableListView<Expense> get expenses => UnmodifiableListView(_expenses);
  UnmodifiableListView<cat.Category> get categories => UnmodifiableListView(_categories);

  // 初始化数据库
  Future<void> initDatabase(Database db) async {
    _database = db;
    // 加载数据
    await loadExpenses();
    await loadCategories();
  }

  // 加载支出记录
  Future<void> loadExpenses() async {
    if (_database == null) return;
    
    final List<Map<String, dynamic>> maps = await _database!.query('expenses');
    _expenses = List.generate(maps.length, (i) {
      return Expense(
        id: maps[i]['id'],
        amount: maps[i]['amount'],
        categoryId: maps[i]['category_id'],
        date: DateTime.fromMillisecondsSinceEpoch(maps[i]['date']),
        description: maps[i]['description'],
        isExpense: maps[i]['is_expense'] == 1,
      );
    });
    notifyListeners();
  }

  // 加载分类
  Future<void> loadCategories() async {
    if (_database == null) return;
    
    final List<Map<String, dynamic>> maps = await _database!.query('categories');
    _categories = List.generate(maps.length, (i) {
      return cat.Category(
        id: maps[i]['id'],
        name: maps[i]['name'],
        icon: maps[i]['icon'],
        isExpense: maps[i]['is_expense'] == 1,
      );
    });
    notifyListeners();
  }

  // 获取分类名称
  String getCategoryName(int categoryId) {
    return _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => cat.Category(id: -1, name: '未知', icon: 'question_mark', isExpense: true),
    ).name;
  }

  // 获取分类图标
  String getCategoryIcon(int categoryId) {
    return _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => cat.Category(id: -1, name: '未知', icon: 'question_mark', isExpense: true),
    ).icon;
  }

  // 添加支出
  Future<void> addExpense(Expense expense) async {
    if (_database == null) return;
    
    final id = await _database!.insert('expenses', {
      'amount': expense.amount,
      'category_id': expense.categoryId,
      'date': expense.date.millisecondsSinceEpoch,
      'description': expense.description,
      'is_expense': expense.isExpense ? 1 : 0,
    });
    
    final newExpense = Expense(
      id: id,
      amount: expense.amount,
      categoryId: expense.categoryId,
      date: expense.date,
      description: expense.description,
      isExpense: expense.isExpense,
    );
    
    _expenses.add(newExpense);
    notifyListeners();
  }

  // 更新支出
  Future<void> updateExpense(Expense expense) async {
    if (_database == null) return;
    
    await _database!.update(
      'expenses',
      {
        'amount': expense.amount,
        'category_id': expense.categoryId,
        'date': expense.date.millisecondsSinceEpoch,
        'description': expense.description,
        'is_expense': expense.isExpense ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [expense.id],
    );
    
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }
  }

  // 删除支出
  Future<void> deleteExpense(int id) async {
    if (_database == null) return;
    
    await _database!.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
