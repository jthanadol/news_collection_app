import 'package:flutter/material.dart';
import 'package:news_app/config/setting_app.dart';
import 'package:provider/provider.dart';

import 'fact_check_page.dart';
import 'home_page.dart';
import 'more_page.dart';
import 'world_page.dart';

class AppPage extends StatefulWidget {
  AppPage({super.key});
  static const routeName = "/app_page";

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Provider.of<TabControllerProvider>(context, listen: false).setTabController(this);
  }

  @override
  Widget build(BuildContext context) {
    TabController _tabController = Provider.of<TabControllerProvider>(context).controller;

    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: SettingApp.settingApp.colorShadow,
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: BottomAppBar(
          color: SettingApp.settingApp.colorButton,
          child: TabBar(
            controller: _tabController,
            labelColor: SettingApp.settingApp.colorIconHighlight,
            unselectedLabelColor: SettingApp.settingApp.colorIcon,
            indicatorColor: SettingApp.settingApp.colorIconHighlight,
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
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HomePage(),
          WorldPage(),
          FactCheckPage(),
          MorePage(),
        ],
      ),
    );
  }
}

class TabControllerProvider with ChangeNotifier {
  late TabController _tabController;

  void setTabController(TickerProvider vsync) {
    _tabController = TabController(length: 4, vsync: vsync);
  }

  TabController get controller => _tabController;

  void refreshTabBar() {
    notifyListeners(); // รีเฟรช UI
  }
}
