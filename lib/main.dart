import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // 自动生成的国际化类

import 'screens/home_screen.dart';
import 'providers/expense_provider.dart';
import 'models/expense.dart';
import 'models/category.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        title: AppLocalizations.of(context)?.appTitle ?? '记账应用',
        localizationsDelegates: const [
          AppLocalizations.delegate, // 自定义语言代理
          GlobalMaterialLocalizations.delegate, // Material 组件国际化
          GlobalWidgetsLocalizations.delegate, // Widget 国际化
          GlobalCupertinoLocalizations.delegate, // Cupertino 组件国际化
        ],
        supportedLocales: const [
          Locale('zh', 'CN'), // 支持中文
          Locale('en', 'US'), // 支持英文（可选）
        ],
        locale: const Locale('zh', 'CN'), // 默认中文
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
