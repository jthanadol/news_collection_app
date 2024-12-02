import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:news_app/app_page/read_new_page.dart';
import 'package:news_app/app_page/search_new_page.dart';
import 'app_page/fact_check_page.dart';
import 'app_page/home_page.dart';
import 'app_page/more_page.dart';
import 'app_page/world_page.dart';

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
        HomePage.routeName: (context) => const HomePage(),
        WorldPage.routeName: (context) => const WorldPage(),
        FactCheckPage.routeName: (context) => const FactCheckPage(),
        MorePage.routeName: (context) => const MorePage(),
        ReadNewPage.routeName: (context) => const ReadNewPage(),
        SearchNewPage.routeName: (context) => const SearchNewPage(),
      },
      home: const DefaultTabController(
        length: 4,
        child: Scaffold(
          bottomNavigationBar: BottomAppBar(
            color: Colors.black12,
            child: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.home),
                ),
                Tab(
                  icon: Icon(Icons.public),
                ),
                Tab(
                  icon: Icon(Icons.fact_check),
                ),
                Tab(
                  icon: Icon(Icons.widgets),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              HomePage(),
              WorldPage(),
              FactCheckPage(),
              MorePage(),
            ],
          ),
        ),
      ),
    );
  }
}
