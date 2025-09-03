import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/category.dart' as cat;

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<cat.Category> _categories = [];
  Database? _database;

  UnmodifiableListView<Expense> get expenses => UnmodifiableListView(_expenses);
  UnmodifiableListView<cat.Category> get categories => UnmodifiableListView(_categories);

  Future<void> initDatabase() async {
    if (_database != null) return;

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'accounting.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            is_expense INTEGER NOT NULL
          )
        ''');
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
        await db.insert('categories', {
          'name': '餐饮美食',
          'icon': 'restaurant',
          'is_expense': 1
        });
      },
    );
  }

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

  Future<void> loadExpenses() async {
    if (_database == null) await initDatabase();
    
    final List<Map<String, dynamic>> maps = await _database!.query('expenses', orderBy: 'date DESC');
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

  Future<void> addCategory(cat.Category category) async {
    if (_database == null) await initDatabase();
    
    final id = await _database!.insert('categories', {
      'name': category.name,
      'icon': category.icon,
      'is_expense': category.isExpense ? 1 : 0,
    });
    
    _categories.add(cat.Category(
      id: id,
      name: category.name,
      icon: category.icon,
      isExpense: category.isExpense,
    ));
    notifyListeners();
  }

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

  Future<void> addExpense(Expense expense) async {
    if (_database == null) await initDatabase();
    
    final id = await _database!.insert('expenses', {
      'amount': expense.amount,
      'category_id': expense.categoryId,
      'date': expense.date.millisecondsSinceEpoch,
      'description': expense.description,
      'is_expense': expense.isExpense ? 1 : 0,
    });
    
    _expenses.insert(0, Expense(
      id: id,
      amount: expense.amount,
      categoryId: expense.categoryId,
      date: expense.date,
      description: expense.description,
      isExpense: expense.isExpense,
    ));
    notifyListeners();
  }

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
