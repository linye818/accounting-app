import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/category.dart' as cat; // 别名解决冲突

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<cat.Category> _categories = [];
  Database? _database;

  UnmodifiableListView<Expense> get expenses => UnmodifiableListView(_expenses);
  UnmodifiableListView<cat.Category> get categories => UnmodifiableListView(_categories);

  // 初始化数据库（关键修复：确保数据库表存在）
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
        // 创建支出表
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
        // 插入默认分类（确保有可选分类）
        await db.insert('categories', {
          'name': '餐饮美食',
          'icon': 'restaurant',
          'is_expense': 1
        });
        await db.insert('categories', {
          'name': '交通出行',
          'icon': 'directions_car',
          'is_expense': 1
        });
        await db.insert('categories', {
          'name': '购物消费',
          'icon': 'shopping_cart',
          'is_expense': 1
        });
        await db.insert('categories', {
          'name': '工资收入',
          'icon': 'attach_money',
          'is_expense': 0
        });
      },
    );

    // 初始化时加载数据
    await loadCategories();
    await loadExpenses();
  }

  // 加载分类（修复：确保正确查询和转换）
  Future<void> loadCategories() async {
    if (_database == null) await initDatabase();
    
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

  // 加载账单（修复：按日期倒序排列，最新的在前）
  Future<void> loadExpenses() async {
    if (_database == null) await initDatabase();
    
    final List<Map<String, dynamic>> maps = await _database!.query(
      'expenses',
      orderBy: 'date DESC', // 最新的账单显示在前面
    );
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

  // 添加账单
  Future<void> addExpense(Expense expense) async {
    if (_database == null) await initDatabase();
    
    final id = await _database!.insert('expenses', {
      'amount': expense.amount,
      'category_id': expense.categoryId,
      'date': expense.date.millisecondsSinceEpoch,
      'description': expense.description,
      'is_expense': expense.isExpense ? 1 : 0,
    });
    
    _expenses.insert(0, Expense( // 插入到列表开头，立即显示
      id: id,
      amount: expense.amount,
      categoryId: expense.categoryId,
      date: expense.date,
      description: expense.description,
      isExpense: expense.isExpense,
    ));
    notifyListeners();
  }

  // 更新账单
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
}
