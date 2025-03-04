import 'package:flutter/material.dart';
import 'package:news_app/config/setting_app.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});
  static const routeName = "/setting_page";

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
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
          'การตั้งค่า',
          style: TextStyle(
            fontSize: SettingApp.settingApp.textSizeH2,
          ),
        ),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Text(
                'หน้าต่างแอปพลิเคชัน(UI)',
                style: TextStyle(
                  fontSize: SettingApp.settingApp.textSizeH3,
                ),
              ),
              Row(
                children: [
                  Text(
                    'ธีมสี : ',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                  Radio(
                    value: 'light-theme',
                    groupValue: SettingApp.settingApp.appThemp,
                    onChanged: (value) {
                      setState(() {
                        SettingApp.settingApp.appThemp = value!;
                      });
                    },
                  ),
                  Text(
                    'สว่าง',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                  Radio(
                    value: 'dark-theme',
                    groupValue: SettingApp.settingApp.appThemp,
                    onChanged: (value) {
                      setState(() {
                        SettingApp.settingApp.appThemp = value!;
                      });
                    },
                  ),
                  Text(
                    'มืด',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'ขนาดปุ่ม : ',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                  Radio(
                    value: 'small',
                    groupValue: SettingApp.settingApp.appSize,
                    onChanged: (value) {
                      SettingApp.settingApp.appSize = value!;
                      SettingApp.settingApp.setButton();
                      setState(() {});
                    },
                  ),
                  Text(
                    'เล็ก',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                  Radio(
                    value: 'normal',
                    groupValue: SettingApp.settingApp.appSize,
                    onChanged: (value) {
                      SettingApp.settingApp.appSize = value!;
                      SettingApp.settingApp.setButton();
                      setState(() {});
                    },
                  ),
                  Text(
                    'ปกติ',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                  Radio(
                    value: 'big',
                    groupValue: SettingApp.settingApp.appSize,
                    onChanged: (value) {
                      SettingApp.settingApp.appSize = value!;
                      SettingApp.settingApp.setButton();
                      setState(() {});
                    },
                  ),
                  Text(
                    'ใหญ่',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'ตัวอักษร',
                style: TextStyle(
                  fontSize: SettingApp.settingApp.textSizeH3,
                ),
              ),
              Row(
                children: [
                  Text(
                    'ขนาด : ',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                  Radio(
                    value: 'small',
                    groupValue: SettingApp.settingApp.textSize,
                    onChanged: (value) {
                      SettingApp.settingApp.textSize = value!;
                      SettingApp.settingApp.setTextSize();
                      setState(() {});
                    },
                  ),
                  Text(
                    'เล็ก',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                  Radio(
                    value: 'normal',
                    groupValue: SettingApp.settingApp.textSize,
                    onChanged: (value) {
                      SettingApp.settingApp.textSize = value!;
                      SettingApp.settingApp.setTextSize();
                      setState(() {});
                    },
                  ),
                  Text(
                    'ปกติ',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                  Radio(
                    value: 'big',
                    groupValue: SettingApp.settingApp.textSize,
                    onChanged: (value) {
                      SettingApp.settingApp.textSize = value!;
                      SettingApp.settingApp.setTextSize();
                      setState(() {});
                    },
                  ),
                  Text(
                    'ใหญ่',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'สี : ',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                  Text('-'),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'ตั้งค่าเพิ่มเติม',
                style: TextStyle(
                  fontSize: SettingApp.settingApp.textSizeH3,
                ),
              ),
              Row(
                children: [
                  Text(
                    'แสดงรูปภาพออนไลน์ : ',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                  Radio(
                    value: true,
                    groupValue: SettingApp.settingApp.showImageOnline,
                    onChanged: (value) {
                      setState(() {
                        SettingApp.settingApp.showImageOnline = value!;
                      });
                    },
                  ),
                  Text(
                    'เปิด',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                  Radio(
                    value: false,
                    groupValue: SettingApp.settingApp.showImageOnline,
                    onChanged: (value) {
                      setState(() {
                        SettingApp.settingApp.showImageOnline = value!;
                      });
                    },
                  ),
                  Text(
                    'ปิด',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
