import 'package:flutter/material.dart';
import 'package:news_app/config/setting_app.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  static const routeName = "/about_page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          iconSize: SettingApp.settingApp.iconSize,
        ),
        title: Text(
          'เกี่ยวกับแอปพลิเคชัน',
          style: TextStyle(
            fontSize: SettingApp.settingApp.textSizeH2,
          ),
        ),
      ),
    );
  }
}
