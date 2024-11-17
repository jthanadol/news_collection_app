import 'package:flutter/material.dart';
import 'app_page/fact_check_page.dart';
import 'app_page/home_page.dart';
import 'app_page/more_page.dart';
import 'app_page/world_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      initialRoute: HomePage.routeName,
      routes: {
        HomePage.routeName: (context) => HomePage(),
        WorldPage.routeName: (context) => WorldPage(),
        FactCheckPage.routeName: (context) => FactCheckPage(),
        MorePage.routeName: (context) => MorePage()
      },
    );
  }
}
