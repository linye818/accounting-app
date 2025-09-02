import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/category.dart';

class DatabaseHelper {
  // 单例模式：确保整个App只有一个数据库连接
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // 获取数据库连接
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('accounting.db');
    return _database!;
  }

  // 初始化数据库（第一次打开App时创建数据库文件）
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // 创建数据库表（第一次使用时创建两个表：记录和分类）
  Future _createDB(Database db, int version) async {
    // 创建收支记录表
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        categoryId INTEGER NOT NULL,
        isExpense INTEGER NOT NULL
      )
    ''');

    // 创建分类表
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        isExpense INTEGER NOT NULL
      )
    ''');

    // 把预设的分类（餐饮、工资等）添加到数据库
    for (var category in defaultCategories) {
      await db.insert('categories', category.toMap());
    }
  }

  // 保存新的记账记录到数据库
  Future<int> insertExpense(Expense expense) async {
    final db = await instance.database;
    return await db.insert('expenses', expense.toMap());
  }

  // 从数据库获取所有记账记录（可按条件筛选）
  Future<List<Expense>> getAllExpenses({bool? isExpense, DateTime? startDate, DateTime? endDate}) async {
    final db = await instance.database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (isExpense != null) {
      whereClauses.add('isExpense = ?');
      whereArgs.add(isExpense ? 1 : 0);
    }

    if (startDate != null) {
      whereClauses.add('date >= ?');
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }

    if (endDate != null) {
      whereClauses.add('date <= ?');
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    String whereStr = whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';

    final maps = await db.query(
      'expenses',
      where: whereStr,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  // 更新已有的记账记录
  Future<int> updateExpense(Expense expense) async {
    final db = await instance.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // 删除一条记账记录
  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 获取所有分类（可筛选支出或收入分类）
  Future<List<Category>> getAllCategories({bool? isExpense}) async {
    final db = await instance.database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (isExpense != null) {
      whereClauses.add('isExpense = ?');
      whereArgs.add(isExpense ? 1 : 0);
    }

    String whereStr = whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';

    final maps = await db.query(
      'categories',
      where: whereStr,
      whereArgs: whereArgs,
    );

    return maps.map((map) => Category.fromMap(map)).toList();
  }

  // 关闭数据库连接
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
