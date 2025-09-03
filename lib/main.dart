import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/expense_provider.dart';
import 'widgets/bottom_nav_bar.dart'; // 导入底部导航组件

void main() {
  // 全局异常捕获（可选，用于后续调试）
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter 框架异常: ${details.exception}');
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
        // 支持中文本地化
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('zh', 'CN')],
        locale: const Locale('zh', 'CN'),
        // 主题配置
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // 关键修复：将 AppBottomNavBar 改为 BottomNavBar（与组件类名一致）
        home: const BottomNavBar(),
        debugShowCheckedModeBanner: false, // 隐藏调试横幅
      ),
    );
  }
}
