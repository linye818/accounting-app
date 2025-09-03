import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/account_category.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<AccountCategory> _categories = [];
  Database? _database;

  // 对外提供不可修改的列表
  UnmodifiableListView<Expense> get expenses => UnmodifiableListView(_expenses);
  UnmodifiableListView<AccountCategory> get categories => UnmodifiableListView(_categories);

  // 初始化数据库（完全闭合所有括号）
  Future<void> initDatabase() async {
    if (_database != null) return;

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'accounting.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 创建分类表
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            is_expense INTEGER NOT NULL
          )
        ''');
        // 创建账单表
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            category_id INTEGER NOT NULL,
            date INTEGER NOT NULL,
            description TEXT NOT NULL,
            is_expense INTEGER NOT NULL,
            FOREIGN KEY (category_id) REFERENCES categories (id)
          )
        ''');
        // 插入默认分类（循环闭合）
        for (var category in defaultAccountCategories) {
          await db.insert('categories', {
            'name': category.name,
            'icon': category.icon,
            'is_expense': category.isExpense ? 1 : 0,
          });
        }
      }, // 闭合 onCreate 回调
    ); // 闭合 openDatabase 调用
  } // 闭合 initDatabase 方法

  // 加载分类
  Future<void> loadCategories() async {
    if (_database == null) await initDatabase();
    
    final List<Map<String, dynamic>> maps = await _database!.query('categories');
    _categories = List.generate(
      maps.length, 
      (i) => AccountCategory.fromMap(maps[i])
    );
    notifyListeners();
  }

  // 加载账单
  Future<void> loadExpenses() async {
    if (_database == null) await initDatabase();
    
    final List<Map<String, dynamic>> maps = await _database!.query('expenses', orderBy: 'date DESC');
    _expenses = List.generate(
      maps.length, 
      (i) => Expense.fromMap(maps[i])
    );
    notifyListeners();
  }

  // 添加分类
  Future<void> addCategory(AccountCategory category) async {
    if (_database == null) await initDatabase();
    
    final id = await _database!.insert('categories', {
      'name': category.name,
      'icon': category.icon,
      'is_expense': category.isExpense ? 1 : 0,
    });
    
    _categories.add(AccountCategory(
      id: id,
      name: category.name,
      icon: category.icon,
      isExpense: category.isExpense,
    ));
    notifyListeners();
  }

  // 删除分类
  Future<void> deleteCategory(int categoryId) async {
    if (_database == null) return;

    await _database!.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [categoryId],
    );

    _categories.removeWhere((c) => c.id == categoryId);
    notifyListeners();
  }

  // 添加账单
  Future<void> addExpense(Expense expense) async {
    if (_database == null) await initDatabase();
    
    final id = await _database!.insert('expenses', expense.toMap());
    
    _expenses.insert(0, Expense(
      id: id,
      description: expense.description,
      amount: expense.amount,
      categoryId: expense.categoryId,
      date: expense.date,
      isExpense: expense.isExpense,
    ));
    notifyListeners();
  }

  // 编辑账单
  Future<void> updateExpense(Expense expense) async {
    if (_database == null) return;
    
    await _database!.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
    
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }
  }

  // 删除账单
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
} // 闭合 ExpenseProvider 类
