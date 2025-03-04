import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:news_app/app_page/about_page.dart';
import 'package:news_app/app_page/login_page.dart';
import 'package:news_app/app_page/offline_news.dart';
import 'package:news_app/app_page/setting_page.dart';
import 'package:news_app/config/auth.dart';
import 'package:news_app/config/setting_app.dart';

class MorePage extends StatefulWidget {
  static const routeName = "/more_page"; //ชื่อที่ใช้อ้างถึงหน้านี้

  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "เมนูเพิ่มเติม",
          style: TextStyle(
            fontSize: SettingApp.settingApp.textSizeH2,
          ),
        ),
        backgroundColor: Colors.black12,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 36,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (Auth.auth.accountType == 'Email')
                  ? Icon(Icons.email)
                  : Image.asset(
                      'assets/img/google_icon.png',
                      cacheHeight: 40,
                    ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Auth.auth.email,
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                  Text(
                    'Account ID : ${Auth.auth.accountId}',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 36,
          ),
          Column(
            children: [
              buildButtonBar(
                context,
                routeName: OfflineNews.routeName,
                icon: Icons.download,
                text: 'ข่าวที่บันทึก',
              ),
              SizedBox(
                height: 16,
              ),
              buildButtonBar(
                context,
                icon: Icons.settings,
                routeName: SettingPage.routeName,
                text: 'การตั้งค่าแอปพลิเคชัน',
              ),
              SizedBox(
                height: 16,
              ),
              buildButtonBar(
                context,
                routeName: AboutPage.routeName,
                icon: Icons.question_mark,
                text: 'เกี่ยวกับแอปพลิเคชัน',
              ),
            ],
          ),
          SizedBox(
            height: 36,
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              fixedSize: Size.fromHeight(SettingApp.settingApp.buttonSize),
            ),
            onPressed: () {
              Auth.auth.logout();
              Navigator.pushReplacementNamed(context, LoginPage.routeName);
            },
            label: Text(
              "ออกจากระบบ",
              style: TextStyle(
                fontSize: SettingApp.settingApp.textSizeButton,
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

  ElevatedButton buildButtonBar(BuildContext context, {required String routeName, required IconData icon, required String text}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        fixedSize: Size.fromHeight(
          SettingApp.settingApp.buttonSize,
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(context, routeName);
      },
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: SettingApp.settingApp.textSizeButton,
            ),
          ),
          Icon(
            Icons.arrow_forward,
            size: SettingApp.settingApp.iconSize,
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
