import 'dart:async';

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
  final _formKeyOldPass = GlobalKey<FormState>();
  String _email = '';
  String _otp = '';
  String _oldPass = '';
  String _password = '';
  String _confirmPassword = '';
  String? _errorMessage;
  bool _isReqForgot = false;
  bool _isCountdown = false;
  int _timeCountdown = 60;

  Future<void> getOTP() async {
    if (!_isCountdown) {
      setState(() {
        _errorMessage = null;
      });
      startCountdown();

      List<dynamic> res = await ApiAction.apiAction.getOTP(email: _email);

      setState(() {
        _errorMessage = (res[1]) ? null : res[0];
      });
    }
  }

  getForgot() async {
    if (!_isReqForgot) {
      setState(() {
        _errorMessage = null;
        _isReqForgot = true;
      });

      List<dynamic> res = await ApiAction.apiAction.forgot(email: _email, otp: _otp, oldPass: _oldPass, password: _password);

      setState(() {
        _errorMessage = (res[1]) ? null : res[0];
        _isReqForgot = false;
      });
    }
  }

  void startCountdown() {
    if (!_isCountdown) {
      setState(() {
        _isCountdown = true;
      });
      Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          if (_timeCountdown == 0) {
            setState(() {
              _timeCountdown = 60;
              _isCountdown = false;
            });
            timer.cancel();
          } else {
            setState(() {
              _timeCountdown--;
            });
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SingleChildScrollView forgotByOTP() {
      return SingleChildScrollView(
        child: Column(
          children: [
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
            const SizedBox(
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
                        const Shadow(
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
                      prefixIcon: const Icon(Icons.email),
                      prefixIconColor: Colors.white,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
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
                        const Shadow(
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
            const SizedBox(
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
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
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
                            prefixIcon: const Icon(Icons.key),
                            prefixIconColor: Colors.white,
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
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
                              const Shadow(
                                color: Colors.black,
                                blurRadius: 5,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: Colors.grey,
                        ),
                        onPressed: (!_isCountdown)
                            ? () {
                                if (_formKeyEmail.currentState!.validate()) {
                                  _formKeyEmail.currentState!.save();
                                  getOTP();
                                }
                              }
                            : null,
                        child: Text(
                          (!_isCountdown) ? 'ส่งรหัส OTP' : _timeCountdown.toString(),
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: SettingApp.settingApp.textSizeButton,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'รหัสผ่านใหม่',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: SettingApp.settingApp.textSizeH3,
                      shadows: [
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'กรุณากรอกรหัสผ่านใหม่'),
                      LengthRangeValidator(min: 6, max: 100, errorText: 'รหัสผ่านใหม่สั้นเกินไป'),
                    ]),
                    obscureText: true,
                    onSaved: (String? password) {
                      _password = password!;
                    },
                    decoration: InputDecoration(
                      errorStyle: TextStyle(
                        fontSize: SettingApp.settingApp.textSizeBody,
                        color: Colors.red,
                      ),
                      prefixIcon: const Icon(Icons.password),
                      prefixIconColor: Colors.white,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
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
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'ยืนยันรหัสผ่าน',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: SettingApp.settingApp.textSizeH3,
                      shadows: [
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'กรุณากรอกรหัสผ่านยืนยัน'),
                      LengthRangeValidator(min: 6, max: 100, errorText: 'รหัสผ่านยืนยันสั้นเกินไป'),
                    ]),
                    obscureText: true,
                    onSaved: (String? confirmPassword) {
                      _confirmPassword = confirmPassword!;
                    },
                    decoration: InputDecoration(
                      errorStyle: TextStyle(
                        fontSize: SettingApp.settingApp.textSizeBody,
                        color: Colors.red,
                      ),
                      prefixIcon: const Icon(Icons.password),
                      prefixIconColor: Colors.white,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
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
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
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
      );
    }

    SingleChildScrollView forgotByOldPass() {
      return SingleChildScrollView(
        child: Column(
          children: [
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
            const SizedBox(
              height: 16,
            ),
            Form(
              key: _formKeyOldPass,
              child: Column(
                children: [
                  Text(
                    'อีเมล',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: SettingApp.settingApp.textSizeH3,
                      shadows: [
                        const Shadow(
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
                      prefixIcon: const Icon(Icons.email),
                      prefixIconColor: Colors.white,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
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
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'รหัสผ่านเก่า',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: SettingApp.settingApp.textSizeH3,
                      shadows: [
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    validator: RequiredValidator(errorText: 'กรุณากรอกรหัสผ่านเก่า'),
                    obscureText: true,
                    onSaved: (String? oldPass) {
                      _oldPass = oldPass!;
                    },
                    decoration: InputDecoration(
                      errorStyle: TextStyle(
                        fontSize: SettingApp.settingApp.textSizeBody,
                        color: Colors.red,
                      ),
                      prefixIcon: const Icon(Icons.password),
                      prefixIconColor: Colors.white,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
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
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'รหัสผ่านใหม่',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: SettingApp.settingApp.textSizeH3,
                      shadows: [
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'กรุณากรอกรหัสผ่านใหม่'),
                      LengthRangeValidator(min: 6, max: 100, errorText: 'รหัสผ่านใหม่สั้นเกินไป'),
                    ]),
                    obscureText: true,
                    onSaved: (String? password) {
                      _password = password!;
                    },
                    decoration: InputDecoration(
                      errorStyle: TextStyle(
                        fontSize: SettingApp.settingApp.textSizeBody,
                        color: Colors.red,
                      ),
                      prefixIcon: const Icon(Icons.password),
                      prefixIconColor: Colors.white,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
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
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'ยืนยันรหัสผ่าน',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: SettingApp.settingApp.textSizeH3,
                      shadows: [
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'กรุณากรอกรหัสผ่านยืนยัน'),
                      LengthRangeValidator(min: 6, max: 100, errorText: 'รหัสผ่านยืนยันสั้นเกินไป'),
                    ]),
                    obscureText: true,
                    onSaved: (String? confirmPassword) {
                      _confirmPassword = confirmPassword!;
                    },
                    decoration: InputDecoration(
                      errorStyle: TextStyle(
                        fontSize: SettingApp.settingApp.textSizeBody,
                        color: Colors.red,
                      ),
                      prefixIcon: const Icon(Icons.password),
                      prefixIconColor: Colors.white,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
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
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKeyOldPass.currentState!.validate()) {
                        _formKeyOldPass.currentState!.save();
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
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          bottom: TabBar(
              onTap: (value) {
                setState(() {
                  _oldPass = '';
                  _otp = '';
                  _email = '';
                  _password = '';
                  _confirmPassword = '';
                  _errorMessage = '';
                });
              },
              labelColor: SettingApp.settingApp.colorIconHighlight,
              unselectedLabelColor: Colors.white,
              indicatorColor: SettingApp.settingApp.colorIconHighlight,
              tabs: [
                Tab(
                  child: Text(
                    'เปลี่ยนด้วย OTP',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeButton,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'เปลี่ยนด้วยรหัสเก่า',
                    style: TextStyle(
                      fontSize: SettingApp.settingApp.textSizeButton,
                    ),
                  ),
                ),
              ]),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white, // กำหนดสีของปุ่มย้อน (Back button)
            onPressed: () {
              // การทำงานเมื่อกดปุ่มย้อน
              Navigator.pop(context);
            },
          ),
          title: Text(
            'เปลี่ยนรหัสผ่าน',
            style: TextStyle(
              color: Colors.white,
              fontSize: SettingApp.settingApp.textSizeH1,
              fontWeight: FontWeight.bold,
              shadows: [
                const Shadow(
                  color: Colors.black,
                  blurRadius: 5,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/background_2.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          width: double.infinity,
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
          ),
          child: SafeArea(
            child: TabBarView(children: [
              forgotByOTP(),
              forgotByOldPass(),
            ]),
          ),
        ),
      ),
    );
  }
}
