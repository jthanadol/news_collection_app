class SettingApp {
  static SettingApp settingApp = SettingApp();

  String appThemp = 'light-theme';
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

  SettingApp();

  void setTextSize() {
    //ขนาดปกติ
    if (textSize.contains('normal')) {
      textSizeH1 = 24;
      textSizeH2 = 20;
      textSizeH3 = 18;
      textSizeBody = 16;
      textSizeCaption = 14;
      textSizeButton = 16;
      //ขนาดใหญ่
    } else if (textSize.contains('big')) {
      textSizeH1 = 32;
      textSizeH2 = 28;
      textSizeH3 = 24;
      textSizeBody = 20;
      textSizeCaption = 18;
      textSizeButton = 20;
      //ขนาดเล็ก
    } else {
      textSizeH1 = 20;
      textSizeH2 = 18;
      textSizeH3 = 16;
      textSizeBody = 14;
      textSizeCaption = 12;
      textSizeButton = 14;
    }
  }

  void setButton() {
    //ขนาดปกติ
    if (appSize.contains('normal')) {
      buttonSize = 48;
      iconSize = 24;
      //ขนาดใหญ่
    } else if (appSize.contains('big')) {
      buttonSize = 56;
      iconSize = 32;
      //ขนาดเล็ก
    } else {
      buttonSize = 36;
      iconSize = 16;
    }
  }
}
