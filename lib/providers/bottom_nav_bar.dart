import 'package:flutter/material.dart';
import '../screens/detail_screen.dart';
import '../screens/statistic_screen.dart';
import '../screens/category_setting_screen.dart'; // 新增导入

class AppBottomNavBar extends StatefulWidget {
  const AppBottomNavBar({Key? key}) : super(key: key);

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const DetailScreen(),
    const StatisticScreen(),
    const CategorySettingScreen(), // 新增“分类设置”页面
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: '明细',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: '统计',
          ),
          BottomNavigationBarItem( // 新增“设置”入口
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
