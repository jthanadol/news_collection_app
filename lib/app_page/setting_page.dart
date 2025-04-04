import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
            SettingApp.settingApp.saveSettingFile();
            Navigator.pop(context);
          },
          iconSize: SettingApp.settingApp.iconSize,
          color: SettingApp.settingApp.colorIcon,
        ),
        title: Text(
          'การตั้งค่า',
          style: TextStyle(
            fontSize: SettingApp.settingApp.textSizeH2,
            color: SettingApp.settingApp.colorText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 24,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              'ธีมสี',
              style: TextStyle(
                color: SettingApp.settingApp.colorTextTitle,
                fontSize: SettingApp.settingApp.textSizeH3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: SettingApp.settingApp.colorButton,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: SettingApp.settingApp.colorShadow,
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          fixedSize: Size.fromHeight(SettingApp.settingApp.buttonSize),
                          overlayColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          SettingApp.settingApp.darkThemp = false;
                          SettingApp.settingApp.switchTheme();
                          setState(() {});
                        },
                        label: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'สว่าง',
                              style: TextStyle(
                                color: SettingApp.settingApp.colorTextButton,
                                fontSize: SettingApp.settingApp.textSizeButton,
                              ),
                            ),
                            Icon(
                              (SettingApp.settingApp.darkThemp) ? Icons.circle_outlined : Icons.check_circle,
                              color: (SettingApp.settingApp.darkThemp) ? SettingApp.settingApp.colorIcon : SettingApp.settingApp.colorIconHighlight,
                              size: SettingApp.settingApp.iconSize,
                            ),
                          ],
                        ),
                        icon: Icon(
                          Icons.light_mode,
                          color: SettingApp.settingApp.colorIcon,
                          size: SettingApp.settingApp.iconSize,
                        ),
                      ),
                    ),
                    Divider(
                      color: SettingApp.settingApp.colorBackground,
                      thickness: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          fixedSize: Size.fromHeight(SettingApp.settingApp.buttonSize),
                          overlayColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          SettingApp.settingApp.darkThemp = true;
                          SettingApp.settingApp.switchTheme();
                          setState(() {});
                        },
                        label: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'มืด',
                              style: TextStyle(
                                color: SettingApp.settingApp.colorTextButton,
                                fontSize: SettingApp.settingApp.textSizeButton,
                              ),
                            ),
                            Icon(
                              (!SettingApp.settingApp.darkThemp) ? Icons.circle_outlined : Icons.check_circle,
                              size: SettingApp.settingApp.iconSize,
                              color: (!SettingApp.settingApp.darkThemp) ? SettingApp.settingApp.colorIcon : SettingApp.settingApp.colorIconHighlight,
                            ),
                          ],
                        ),
                        icon: Icon(
                          Icons.dark_mode,
                          color: SettingApp.settingApp.colorIcon,
                          size: SettingApp.settingApp.iconSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 24,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              'ขนาดปุ่ม',
              style: TextStyle(
                color: SettingApp.settingApp.colorTextTitle,
                fontSize: SettingApp.settingApp.textSizeH3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: SettingApp.settingApp.colorButton,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: SettingApp.settingApp.colorShadow,
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size.fromHeight(SettingApp.settingApp.buttonSize),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          overlayColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          SettingApp.settingApp.appSize = 'big';
                          SettingApp.settingApp.setButton();
                          setState(() {});
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ขนาดใหญ่',
                              style: TextStyle(
                                color: SettingApp.settingApp.colorTextButton,
                                fontSize: SettingApp.settingApp.textSizeButton,
                              ),
                            ),
                            Icon(
                              (!SettingApp.settingApp.appSize.contains('big')) ? Icons.circle_outlined : Icons.check_circle,
                              size: SettingApp.settingApp.iconSize,
                              color: (!SettingApp.settingApp.appSize.contains('big')) ? SettingApp.settingApp.colorIcon : SettingApp.settingApp.colorIconHighlight,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      color: SettingApp.settingApp.colorBackground,
                      thickness: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size.fromHeight(SettingApp.settingApp.buttonSize),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          overlayColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          SettingApp.settingApp.appSize = 'normal';
                          SettingApp.settingApp.setButton();
                          setState(() {});
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ขนาดปกติ',
                              style: TextStyle(
                                color: SettingApp.settingApp.colorTextButton,
                                fontSize: SettingApp.settingApp.textSizeButton,
                              ),
                            ),
                            Icon(
                              (!SettingApp.settingApp.appSize.contains('normal')) ? Icons.circle_outlined : Icons.check_circle,
                              size: SettingApp.settingApp.iconSize,
                              color: (!SettingApp.settingApp.appSize.contains('normal')) ? SettingApp.settingApp.colorIcon : SettingApp.settingApp.colorIconHighlight,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      color: SettingApp.settingApp.colorBackground,
                      thickness: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          fixedSize: Size.fromHeight(SettingApp.settingApp.buttonSize),
                          elevation: 0,
                          overlayColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          SettingApp.settingApp.appSize = 'small';
                          SettingApp.settingApp.setButton();
                          setState(() {});
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ขนาดเล็ก',
                              style: TextStyle(
                                color: SettingApp.settingApp.colorTextButton,
                                fontSize: SettingApp.settingApp.textSizeButton,
                              ),
                            ),
                            Icon(
                              (!SettingApp.settingApp.appSize.contains('small')) ? Icons.circle_outlined : Icons.check_circle,
                              size: SettingApp.settingApp.iconSize,
                              color: (!SettingApp.settingApp.appSize.contains('small')) ? SettingApp.settingApp.colorIcon : SettingApp.settingApp.colorIconHighlight,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 24,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              'ตัวอักษร',
              style: TextStyle(
                color: SettingApp.settingApp.colorTextTitle,
                fontSize: SettingApp.settingApp.textSizeH3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: SettingApp.settingApp.colorButton,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: SettingApp.settingApp.colorShadow,
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size.fromHeight(SettingApp.settingApp.buttonSize),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          overlayColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          SettingApp.settingApp.textSize = 'big';
                          SettingApp.settingApp.setTextSize();
                          setState(() {});
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ขนาดใหญ่',
                              style: TextStyle(
                                color: SettingApp.settingApp.colorTextButton,
                                fontSize: SettingApp.settingApp.textSizeButton,
                              ),
                            ),
                            Icon(
                              (!SettingApp.settingApp.textSize.contains('big')) ? Icons.circle_outlined : Icons.check_circle,
                              size: SettingApp.settingApp.iconSize,
                              color: (!SettingApp.settingApp.textSize.contains('big')) ? SettingApp.settingApp.colorIcon : SettingApp.settingApp.colorIconHighlight,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      color: SettingApp.settingApp.colorBackground,
                      thickness: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size.fromHeight(SettingApp.settingApp.buttonSize),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          overlayColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          SettingApp.settingApp.textSize = 'normal';
                          SettingApp.settingApp.setTextSize();
                          setState(() {});
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ขนาดปกติ',
                              style: TextStyle(
                                color: SettingApp.settingApp.colorTextButton,
                                fontSize: SettingApp.settingApp.textSizeButton,
                              ),
                            ),
                            Icon(
                              (!SettingApp.settingApp.textSize.contains('normal')) ? Icons.circle_outlined : Icons.check_circle,
                              size: SettingApp.settingApp.iconSize,
                              color: (!SettingApp.settingApp.textSize.contains('normal')) ? SettingApp.settingApp.colorIcon : SettingApp.settingApp.colorIconHighlight,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      color: SettingApp.settingApp.colorBackground,
                      thickness: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          fixedSize: Size.fromHeight(SettingApp.settingApp.buttonSize),
                          elevation: 0,
                          overlayColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          SettingApp.settingApp.textSize = 'small';
                          SettingApp.settingApp.setTextSize();
                          setState(() {});
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ขนาดเล็ก',
                              style: TextStyle(
                                color: SettingApp.settingApp.colorTextButton,
                                fontSize: SettingApp.settingApp.textSizeButton,
                              ),
                            ),
                            Icon(
                              (!SettingApp.settingApp.textSize.contains('small')) ? Icons.circle_outlined : Icons.check_circle,
                              size: SettingApp.settingApp.iconSize,
                              color: (!SettingApp.settingApp.textSize.contains('small')) ? SettingApp.settingApp.colorIcon : SettingApp.settingApp.colorIconHighlight,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      color: SettingApp.settingApp.colorBackground,
                      thickness: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          fixedSize: Size.fromHeight(SettingApp.settingApp.buttonSize),
                          elevation: 0,
                          overlayColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: SettingApp.settingApp.colorBackground,
                                title: Text(
                                  'เลือกสี',
                                  style: TextStyle(
                                    fontSize: SettingApp.settingApp.textSizeH3,
                                    color: SettingApp.settingApp.colorText,
                                  ),
                                ),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      BlockPicker(
                                        pickerColor: SettingApp.settingApp.colorText,
                                        availableColors: [
                                          Colors.black,
                                          Colors.white,
                                          Colors.red,
                                          Colors.green,
                                          Colors.blue,
                                          Colors.yellow,
                                          Colors.orange,
                                          Colors.pink,
                                          Colors.purple,
                                          Colors.brown,
                                          Colors.grey,
                                          SettingApp.settingApp.colorText,
                                        ],
                                        onColorChanged: (color) {
                                          SettingApp.settingApp.colorText = color;
                                          setState(() {});
                                        },
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                backgroundColor: SettingApp.settingApp.colorBackground,
                                                title: Text(
                                                  'รหัสสี',
                                                  style: TextStyle(
                                                    fontSize: SettingApp.settingApp.textSizeBody,
                                                    color: SettingApp.settingApp.colorText,
                                                  ),
                                                ),
                                                content: ColorPicker(
                                                  pickerColor: SettingApp.settingApp.colorText,
                                                  onColorChanged: (color) {
                                                    SettingApp.settingApp.colorText = color;
                                                    setState(() {});
                                                  },
                                                  showLabel: false,
                                                  enableAlpha: false,
                                                  pickerAreaHeightPercent: 0.8,
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('ปิด',
                                                        style: TextStyle(
                                                          fontSize: SettingApp.settingApp.textSizeButton,
                                                          color: SettingApp.settingApp.colorTextButton,
                                                        )),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Text(
                                          'เลือกเพิ่มเติม',
                                          style: TextStyle(
                                            fontSize: SettingApp.settingApp.textSizeButton,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'ปิด',
                                      style: TextStyle(
                                        fontSize: SettingApp.settingApp.textSizeButton,
                                        color: SettingApp.settingApp.colorTextButton,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'สีตัวอักษร',
                              style: TextStyle(
                                color: SettingApp.settingApp.colorTextButton,
                                fontSize: SettingApp.settingApp.textSizeButton,
                              ),
                            ),
                            Container(
                              width: SettingApp.settingApp.iconSize,
                              height: SettingApp.settingApp.iconSize,
                              decoration: BoxDecoration(
                                color: SettingApp.settingApp.colorText,
                                shape: BoxShape.circle,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 24,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              'ตั้งค่าเพิ่มเติม',
              style: TextStyle(
                color: SettingApp.settingApp.colorTextTitle,
                fontSize: SettingApp.settingApp.textSizeH3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: SettingApp.settingApp.colorButton,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: SettingApp.settingApp.colorShadow,
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                height: SettingApp.settingApp.buttonSize + 8,
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size.fromHeight(SettingApp.settingApp.buttonSize),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    overlayColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    setState(() {
                      SettingApp.settingApp.showImageOnline = !SettingApp.settingApp.showImageOnline;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'แสดงรูปภาพออนไลน์',
                        style: TextStyle(
                          color: SettingApp.settingApp.colorTextButton,
                          fontSize: SettingApp.settingApp.textSizeButton,
                        ),
                        softWrap: true,
                      ),
                      Transform.scale(
                        scale: (SettingApp.settingApp.appSize.contains('big')) ? 1.2 : (SettingApp.settingApp.appSize.contains('small') ? 0.8 : 1),
                        child: Switch(
                          focusColor: SettingApp.settingApp.colorIcon,
                          inactiveThumbColor: SettingApp.settingApp.colorIcon,
                          inactiveTrackColor: SettingApp.settingApp.colorIcon.withOpacity(0.2),
                          activeColor: SettingApp.settingApp.colorIconHighlight,
                          activeTrackColor: SettingApp.settingApp.colorIconHighlight.withOpacity(0.4),
                          value: SettingApp.settingApp.showImageOnline,
                          onChanged: (value) {
                            setState(() {
                              SettingApp.settingApp.showImageOnline = value;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }
}
