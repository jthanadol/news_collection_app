import 'package:flutter/material.dart';
import 'package:news_app/app_page/read_new_page.dart';
import 'app_page/fact_check_page.dart';
import 'app_page/home_page.dart';
import 'app_page/more_page.dart';
import 'app_page/world_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        HomePage.routeName: (context) => HomePage(),
        WorldPage.routeName: (context) => WorldPage(),
        FactCheckPage.routeName: (context) => FactCheckPage(),
        MorePage.routeName: (context) => MorePage(),
        ReadNewPage.routeName: (context) => ReadNewPage(),
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
