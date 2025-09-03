import 'package:flutter/material.dart';
import '../screens/statistic_screen.dart';
import '../screens/category_manage_screen.dart';
import '../screens/add_edit_expense_screen.dart';
import '../screens/expense_list_screen.dart'; // 新增导入

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  // 导航页面列表（替换明细页为账单列表页）
  final List<Widget> _pages = [
    const StatisticScreen(),
    const CategoryManageScreen(),
    const AddEditExpenseScreen(),
    const ExpenseListScreen(), // 替换为账单列表页
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
