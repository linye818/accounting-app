import 'package:sqflite/sqflite.dart';

class Category {
  final int? id; // 改为可空类型，添加新分类时可以不提供id
  final String name;
  final String icon;
  final bool isExpense;

  Category({
    this.id, // 改为可选参数
    required this.name,
    required this.icon,
    required this.isExpense,
  });
}

class Category {
  final int id;
  final String name;
  final String icon; // 图标名称（比如“餐饮”对应“restaurant”图标）
  final bool isExpense; // true是支出分类，false是收入分类

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.isExpense,
  });

  // 转换为数据库可存储的格式
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'isExpense': isExpense ? 1 : 0,
    };
  }

  // 从数据库读取并转换为Category对象
  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      isExpense: map['isExpense'] == 1,
    );
  }
}

// 预设常用分类（App打开就有这些分类，不用自己新建）
List<Category> defaultCategories = [
  // 支出分类
  Category(id: 1, name: '餐饮', icon: 'restaurant', isExpense: true),
  Category(id: 2, name: '交通', icon: 'directions_car', isExpense: true),
  Category(id: 3, name: '购物', icon: 'shopping_cart', isExpense: true),
  Category(id: 4, name: '住房', icon: 'home', isExpense: true),
  Category(id: 5, name: '娱乐', icon: 'movie', isExpense: true),
  Category(id: 6, name: '医疗', icon: 'local_hospital', isExpense: true),
  Category(id: 7, name: '教育', icon: 'school', isExpense: true),
  Category(id: 8, name: '其他', icon: 'more_horiz', isExpense: true),
  
  // 收入分类
  Category(id: 101, name: '工资', icon: 'work', isExpense: false),
  Category(id: 102, name: '奖金', icon: 'card_giftcard', isExpense: false),
  Category(id: 103, name: '投资', icon: 'trending_up', isExpense: false),
  Category(id: 104, name: '其他', icon: 'more_horiz', isExpense: false),
];
