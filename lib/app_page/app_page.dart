import 'package:flutter/material.dart';
import 'package:news_app/app_page/about_page.dart';
import 'package:news_app/app_page/forgot_page.dart';
import 'package:news_app/app_page/login_page.dart';
import 'package:news_app/app_page/offline_news.dart';
import 'package:news_app/app_page/register_page.dart';
import 'package:news_app/app_page/setting_page.dart';
import 'package:news_app/config/setting_app.dart';

import 'fact_check_page.dart';
import 'home_page.dart';
import 'more_page.dart';
import 'read_new_page.dart';
import 'search_new_page.dart';
import 'world_page.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

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
        LoginPage.routeName: (context) => const LoginPage(),
        RegisterPage.routeName: (context) => const RegisterPage(),
        ForgotPage.routeName: (context) => const ForgotPage(),
        AppPage.routeName: (context) => const AppPage(),
        ReadNewPage.routeName: (context) => const ReadNewPage(),
        SearchNewPage.routeName: (context) => const SearchNewPage(),
        OfflineNews.routeName: (context) => const OfflineNews(),
        SettingPage.routeName: (context) => const SettingPage(),
        AboutPage.routeName: (context) => const AboutPage(),
      },
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          bottomNavigationBar: BottomAppBar(
            color: Colors.black12,
            child: TabBar(
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.home,
                    size: SettingApp.settingApp.iconSize,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.public,
                    size: SettingApp.settingApp.iconSize,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.fact_check,
                    size: SettingApp.settingApp.iconSize,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.widgets,
                    size: SettingApp.settingApp.iconSize,
                  ),
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
