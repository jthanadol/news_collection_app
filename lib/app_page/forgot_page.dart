import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/app_page/login_page.dart';
import 'package:news_app/config/setting_app.dart';

class ForgotPage extends StatefulWidget {
  const ForgotPage({super.key});
  static const routeName = "/forgot_page";

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _otp = '';
  String _password = '';
  String _confirmPassword = '';
  String? _errorMessage;
  bool _isReqOTP = false;
  bool _isReqForgot = false;

  Future<void> getOTP() async {
    if (!_isReqOTP) {
      setState(() {
        _errorMessage = null;
        _isReqOTP = true;
      });

      List<dynamic> res = await ApiAction.apiAction.getOTP(email: _email);

      setState(() {
        _errorMessage = (res[1]) ? null : res[0];
        _isReqOTP = false;
      });
    }
  }

  getForgot() async {
    if (!_isReqForgot) {
      setState(() {
        _errorMessage = null;
        _isReqForgot = true;
      });

      List<dynamic> res = await ApiAction.apiAction.getForgot(email: _email, otp: _otp, password: _password);

      setState(() {
        _errorMessage = (res[1]) ? null : res[0];
        _isReqForgot = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white, // กำหนดสีของปุ่มย้อน (Back button)
          onPressed: () {
            // การทำงานเมื่อกดปุ่มย้อน
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background_2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'ลืมรหัสผ่าน',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SettingApp.settingApp.textSizeH1,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                SizedBox(
                  height: 16,
                ),
                Form(
                  key: _formKeyEmail,
                  child: Column(
                    children: [
                      Text(
                        'อีเมล',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: SettingApp.settingApp.textSizeH3,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 5,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
                          EmailValidator(errorText: 'โปรดตรวจสอบความถูกต้องของอีเมล'),
                        ]),
                        onSaved: (String? email) {
                          _email = email!;
                        },
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                            fontSize: SettingApp.settingApp.textSizeBody,
                            color: Colors.red,
                          ),
                          prefixIcon: Icon(Icons.email),
                          prefixIconColor: Colors.white,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SettingApp.settingApp.textSizeBody,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 5,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'OTP',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: SettingApp.settingApp.textSizeH3,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 5,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        validator: RequiredValidator(errorText: 'กรุณากรอกรหัส OTP'),
                        keyboardType: TextInputType.number,
                        onSaved: (String? otp) {
                          _otp = otp!;
                        },
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                            fontSize: SettingApp.settingApp.textSizeBody,
                            color: Colors.red,
                          ),
                          prefixIcon: Icon(Icons.key),
                          prefixIconColor: Colors.white,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SettingApp.settingApp.textSizeBody,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 5,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKeyEmail.currentState!.validate()) {
                            _formKeyEmail.currentState!.save();
                            getOTP();
                          }
                        },
                        child: Text(
                          'ส่งรหัส OTP',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: SettingApp.settingApp.textSizeButton,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'รหัสผ่านใหม่',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: SettingApp.settingApp.textSizeH3,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 5,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        validator: RequiredValidator(errorText: 'กรุณากรอกรหัสผ่านใหม่'),
                        obscureText: true,
                        onSaved: (String? password) {
                          _password = password!;
                        },
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                            fontSize: SettingApp.settingApp.textSizeBody,
                            color: Colors.red,
                          ),
                          prefixIcon: Icon(Icons.password),
                          prefixIconColor: Colors.white,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SettingApp.settingApp.textSizeBody,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 5,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'ยืนยันรหัสผ่าน',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: SettingApp.settingApp.textSizeH3,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 5,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        validator: RequiredValidator(errorText: 'กรุณากรอกยืนยันรหัสผ่าน'),
                        obscureText: true,
                        onSaved: (String? confirmPassword) {
                          _confirmPassword = confirmPassword!;
                        },
                        decoration: InputDecoration(
                          errorStyle: TextStyle(
                            fontSize: SettingApp.settingApp.textSizeBody,
                            color: Colors.red,
                          ),
                          prefixIcon: Icon(Icons.password),
                          prefixIconColor: Colors.white,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SettingApp.settingApp.textSizeBody,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 5,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate() && _formKeyEmail.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _formKeyEmail.currentState!.save();
                            if (_password != _confirmPassword) {
                              setState(() {
                                _errorMessage = 'รหัสกับยืนยันรหัสไม่ตรงกัน';
                              });
                            } else {
                              await getForgot();
                              if (_errorMessage == null) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                          'เปลี่ยนรหัสผ่านสำเร็จ',
                                          style: TextStyle(fontSize: SettingApp.settingApp.textSizeBody),
                                        ),
                                        content: Text(
                                          'เมื่อกด \'ตกลง\' จะนำท่านไปยังหน้าเข้าสู่ระบบ',
                                          style: TextStyle(fontSize: SettingApp.settingApp.textSizeBody),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pushReplacementNamed(context, LoginPage.routeName);
                                            },
                                            child: Text(
                                              'ตกลง',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: SettingApp.settingApp.textSizeButton,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                              }
                            }
                          }
                        },
                        child: Text(
                          'ยืนยันการเปลี่ยนแปลง',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: SettingApp.settingApp.textSizeButton,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
