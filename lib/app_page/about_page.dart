import 'package:flutter/material.dart';
import 'package:news_app/config/setting_app.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  static const routeName = "/about_page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingApp.settingApp.colorBackground,
      appBar: AppBar(
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          iconSize: SettingApp.settingApp.iconSize,
          color: SettingApp.settingApp.colorIcon,
        ),
        title: Text(
          'เกี่ยวกับแอปพลิเคชัน',
          style: TextStyle(fontSize: SettingApp.settingApp.textSizeH2, color: SettingApp.settingApp.colorText),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 36,
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.92,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: SettingApp.settingApp.colorButton,
                boxShadow: [
                  BoxShadow(
                    color: SettingApp.settingApp.colorShadow,
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เป็นแอปพลิเคชันที่ใช้ในการแสดงข่าวสารทั่วโลกและตรวจสอบข้อเท็จจริงข้อข่าว ผ่านการดึง API และ การทำ Web Scraping',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                      color: SettingApp.settingApp.colorText,
                    ),
                  ),
                  Divider(
                    color: SettingApp.settingApp.colorLine,
                    height: 20,
                    thickness: 5,
                  ),
                  Text(
                    'version 1.0.0',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                      color: SettingApp.settingApp.colorText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
