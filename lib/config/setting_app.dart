import 'package:flutter/material.dart';
import 'package:news_app/config/path_file.dart';
import 'package:news_app/manage_file.dart';

class SettingApp {
  static SettingApp settingApp = SettingApp();

  bool darkThemp = false;
  String appSize = 'normal';
  String textSize = 'normal';
  bool showImageOnline = true;

  double textSizeH1 = 24; //หัวข้อใหญ่
  double textSizeH2 = 20; //หัวข้อรอง
  double textSizeH3 = 18; //หัวข้อย่อย
  double textSizeBody = 16; //ข้อความหลัก
  double textSizeCaption = 14; //ข้อความเล็ก
  double textSizeButton = 16; //ข้อความในปุ่ม

  double buttonSize = 48;
  double iconSize = 24;

  Color colorTextTitle = Colors.lightBlue;
  Color colorText = Colors.black;
  Color colorBackground = const Color.fromARGB(255, 221, 221, 221);
  Color colorButton = Colors.white;
  Color colorTextButton = Colors.black;
  Color colorLine = const Color(0xFFf2f4f5);
  Color colorIcon = Colors.black;
  Color colorIconHighlight = Colors.lightBlue;
  Color colorShadow = Colors.grey;

  String _filePath = '';

  SettingApp();

  void setTextSize() {
    //ขนาดปกติ
    if (textSize.contains('normal')) {
      textSizeH1 = 24;
      textSizeH2 = 20;
      textSizeH3 = 18;
      textSizeBody = 16;
      textSizeCaption = 14;
      //ขนาดใหญ่
    } else if (textSize.contains('big')) {
      textSizeH1 = 32;
      textSizeH2 = 28;
      textSizeH3 = 24;
      textSizeBody = 20;
      textSizeCaption = 18;
      //ขนาดเล็ก
    } else {
      textSizeH1 = 20;
      textSizeH2 = 18;
      textSizeH3 = 16;
      textSizeBody = 14;
      textSizeCaption = 12;
    }
  }

  void setButton() {
    //ขนาดปกติ
    if (appSize.contains('normal')) {
      buttonSize = 48;
      iconSize = 24;
      textSizeButton = 16;
      //ขนาดใหญ่
    } else if (appSize.contains('big')) {
      buttonSize = 56;
      iconSize = 32;
      textSizeButton = 20;
      //ขนาดเล็ก
    } else {
      buttonSize = 36;
      iconSize = 16;
      textSizeButton = 14;
    }
  }

  void switchTheme() {
    if (darkThemp) {
      colorTextTitle = Colors.lightBlue;
      colorText = Colors.white;
      colorBackground = const Color.fromARGB(255, 43, 44, 45);
      colorButton = const Color(0xFF171717);
      colorTextButton = Colors.white;
      colorLine = const Color(0xFF212121);
      colorIcon = Colors.white;
      colorIconHighlight = Colors.lightBlue;
      colorButton = const Color(0xFF171717);
      colorShadow = Colors.black.withOpacity(0.5);
    } else {
      colorTextTitle = Colors.lightBlue;
      colorText = Colors.black;
      colorBackground = const Color.fromARGB(255, 221, 221, 221);
      colorButton = Colors.white;
      colorTextButton = Colors.black;
      colorLine = const Color(0xFFf2f4f5);
      colorIcon = Colors.black;
      colorIconHighlight = Colors.lightBlue;
      colorButton = Colors.white;
      colorShadow = Colors.grey;
    }
  }

  Future<void> saveSettingFile() async {
    _filePath = (await PathFile.pathFile.getDocPath()) + '/setting';
    await ManageFile.manageFile.createDir(dirPath: _filePath);
    _filePath += '/setting_app.json';
    Map<String, dynamic> data = {
      "darkThemp": darkThemp,
      "appSize": appSize,
      "textSize": textSize,
      "showImageOnline": showImageOnline,
    };
    await ManageFile.manageFile.writeFileJson(fileName: _filePath, data: data);
  }

  Future<void> readSettingFile() async {
    if (_filePath.isEmpty) {
      _filePath = (await PathFile.pathFile.getDocPath()) + '/setting';
      _filePath += '/setting_app.json';
    }
    if (await ManageFile.manageFile.checkFileExists(fileName: _filePath)) {
      Map<String, dynamic> data = await ManageFile.manageFile.readFileJson(fileName: _filePath);
      darkThemp = data['darkThemp'];
      appSize = data['appSize'];
      textSize = data['textSize'];
      showImageOnline = data['showImageOnline'];
    } else {
      await saveSettingFile();
    }
    setButton();
    setTextSize();
    switchTheme();
  }
}
