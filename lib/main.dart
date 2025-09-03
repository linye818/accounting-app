import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // 新增导入，用于 PlatformDispatcher
import 'providers/expense_provider.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Flutter 框架内异常捕获
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter 框架异常: ${details.exception}');
  };

  // 平台级异常捕获
  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    debugPrint('平台级未捕获异常: $error\n$stackTrace');
    return true; // 返回 true 表示异常已处理
  };

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
        theme: ThemeData(primarySwatch: Colors.green),
        home: const AppBottomNavBar(),
      ),
    );
  }
}
