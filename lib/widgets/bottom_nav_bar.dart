import 'package:flutter/material.dart';
import '../screens/statistic_screen.dart';
import '../screens/category_manage_screen.dart';
import '../screens/add_edit_expense_screen.dart';
import '../screens/detail_screen.dart';
import '../models/expense.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  // 导航页面列表（修复 DetailScreen 参数）
  final List<Widget> _pages = [
    const StatisticScreen(),
    const CategoryManageScreen(),
    const AddEditExpenseScreen(), // 添加账单页（无需参数）
    // 明细页：临时传一个默认账单（实际使用时需替换为真实账单）
    DetailScreen(
      expense: Expense(
        id: 0,
        description: '默认明细',
        amount: 0.0,
        categoryId: 1,
        date: DateTime.now(),
        isExpense: true,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '统计',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: '分类',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '添加',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '明细',
          ),
        ],
      ),
    );
  }
}
