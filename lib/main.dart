import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // 确保数据库初始化
    final provider = ExpenseProvider();
    await provider.initDatabase();
    await provider.loadCategories();
    await provider.loadExpenses();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: MaterialApp(
        title: '记账应用',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh', 'CN')],
        locale: const Locale('zh', 'CN'),
        theme: ThemeData(primarySwatch: Colors.green), // 主色调改为绿色更贴合参考图
        home: const AppBottomNavBar(),
      ),
    );
  }
}
