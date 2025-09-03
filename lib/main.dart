import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'widgets/bottom_nav_bar.dart'; // 确保导入路径正确

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ExpenseProvider(),
      child: MaterialApp(
        title: '记账助手',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // 关键修复：将 AppBottomNavBar 改为 BottomNavBar（与组件类名一致）
        home: const BottomNavBar(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
