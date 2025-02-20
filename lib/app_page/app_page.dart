import 'package:flutter/material.dart';

import 'fact_check_page.dart';
import 'home_page.dart';
import 'more_page.dart';
import 'read_new_page.dart';
import 'search_new_page.dart';
import 'world_page.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});
  static const routeName = "/app_page";

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
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
