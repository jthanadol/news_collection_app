import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:news_app/app_page/app_page.dart';
import 'package:news_app/app_page/forgot_page.dart';
import 'package:news_app/app_page/login_page.dart';
import 'package:news_app/app_page/register_page.dart';

void main() {
  //ตั้งค่า DateFormat ของ intl ให้เป็นภาษาไทย
  Intl.defaultLocale = 'th';
  initializeDateFormatting();

  runApp(const MyApp());
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
        AppPage.routeName: (context) => const AppPage(),
      },
      initialRoute: LoginPage.routeName,
    );
  }
}
