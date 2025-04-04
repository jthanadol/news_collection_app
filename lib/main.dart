import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:news_app/app_page/about_page.dart';
import 'package:news_app/app_page/app_page.dart';
import 'package:news_app/app_page/forgot_page.dart';
import 'package:news_app/app_page/login_page.dart';
import 'package:news_app/app_page/offline_news.dart';
import 'package:news_app/app_page/read_news_page.dart';
import 'package:news_app/app_page/register_page.dart';
import 'package:news_app/app_page/search_news_page.dart';
import 'package:news_app/app_page/setting_page.dart';
import 'package:provider/provider.dart';

void main() {
  //ตั้งค่า DateFormat ของ intl ให้เป็นภาษาไทย
  Intl.defaultLocale = 'th';
  initializeDateFormatting();

  runApp(
    ChangeNotifierProvider(
      create: (context) => TabControllerProvider(), //สร้าง TabControllerProvider เพื่อให้ widget อื่นๆสามารถเรียกใช้ TabController ได้
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        LoginPage.routeName: (context) => const LoginPage(),
        RegisterPage.routeName: (context) => const RegisterPage(),
        ForgotPage.routeName: (context) => const ForgotPage(),
        AppPage.routeName: (context) => AppPage(),
        ReadNewsPage.routeName: (context) => const ReadNewsPage(),
        SearchNewsPage.routeName: (context) => const SearchNewsPage(),
        OfflineNews.routeName: (context) => const OfflineNews(),
        SettingPage.routeName: (context) => const SettingPage(),
        AboutPage.routeName: (context) => const AboutPage(),
      },
      initialRoute: LoginPage.routeName,
    );
  }
}
