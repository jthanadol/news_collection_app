import 'package:flutter/material.dart';
import 'package:news_app/app_page/about_page.dart';
import 'package:news_app/app_page/app_page.dart';
import 'package:news_app/app_page/login_page.dart';
import 'package:news_app/app_page/offline_news.dart';
import 'package:news_app/app_page/setting_page.dart';
import 'package:news_app/config/auth.dart';
import 'package:news_app/config/setting_app.dart';
import 'package:provider/provider.dart';

class MorePage extends StatefulWidget {
  static const routeName = "/more_page"; //ชื่อที่ใช้อ้างถึงหน้านี้

  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingApp.settingApp.colorBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: SettingApp.settingApp.colorShadow,
                spreadRadius: 6,
                blurRadius: 10,
                offset: const Offset(0, 1),
              ),
            ],
            image: DecorationImage(
              image: (SettingApp.settingApp.darkThemp) ? const AssetImage('assets/img/appbar_dark.jpg') : const AssetImage('assets/img/appbar_light.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          "เมนูเพิ่มเติม",
          style: TextStyle(
            fontSize: SettingApp.settingApp.textSizeH2,
            color: SettingApp.settingApp.colorText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 36,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (Auth.auth.accountType == 'Email')
                  ? Image.asset(
                      'assets/img/mail.png',
                      cacheHeight: 40,
                    )
                  : Image.asset(
                      'assets/img/google_icon.png',
                      cacheHeight: 40,
                    ),
              SizedBox(
                width: 16,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Auth.auth.email,
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                      color: SettingApp.settingApp.colorText,
                    ),
                  ),
                  Text(
                    'Account ID : ${Auth.auth.accountId}',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                      color: SettingApp.settingApp.colorText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 36,
          ),
          Container(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Column(
              children: [
                buildButtonBar(
                  context,
                  routeName: OfflineNews.routeName,
                  icon: Icons.download,
                  text: 'ข่าวที่บันทึก',
                ),
                const SizedBox(
                  height: 8,
                ),
                buildButtonBar(
                  context,
                  icon: Icons.settings,
                  routeName: SettingPage.routeName,
                  text: 'การตั้งค่าแอปพลิเคชัน',
                  refesh: true,
                ),
                const SizedBox(
                  height: 8,
                ),
                buildButtonBar(
                  context,
                  routeName: AboutPage.routeName,
                  icon: Icons.question_mark,
                  text: 'เกี่ยวกับแอปพลิเคชัน',
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 36,
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              fixedSize: Size.fromHeight(SettingApp.settingApp.buttonSize),
              backgroundColor: SettingApp.settingApp.colorButton,
              iconColor: Colors.red,
            ),
            onPressed: () {
              Auth.auth.logout();
              Navigator.pushReplacementNamed(context, LoginPage.routeName);
            },
            label: Text(
              "ออกจากระบบ",
              style: TextStyle(
                fontSize: SettingApp.settingApp.textSizeButton,
                color: Colors.red,
              ),
            ),
            icon: Icon(
              Icons.logout,
              size: SettingApp.settingApp.iconSize,
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton buildButtonBar(BuildContext context, {required String routeName, required IconData icon, required String text, bool refesh = false}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        fixedSize: Size.fromHeight(
          SettingApp.settingApp.buttonSize,
        ),
        iconColor: SettingApp.settingApp.colorIcon,
        backgroundColor: SettingApp.settingApp.colorButton,
      ),
      onPressed: () async {
        if (refesh) {
          await Navigator.pushNamed(context, routeName);
          var tabProvider = Provider.of<TabControllerProvider>(context, listen: false);
          tabProvider.refreshTabBar();
          setState(() {});
        } else {
          Navigator.pushNamed(context, routeName);
        }
      },
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: SettingApp.settingApp.textSizeButton,
              color: SettingApp.settingApp.colorTextButton,
            ),
          ),
          Icon(
            Icons.arrow_forward,
            size: SettingApp.settingApp.iconSize,
            color: SettingApp.settingApp.colorIcon,
          )
        ],
      ),
      icon: Icon(
        icon,
        size: SettingApp.settingApp.iconSize,
      ),
    );
  }
}
