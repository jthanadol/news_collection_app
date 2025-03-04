import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/app_page/login_page.dart';
import 'package:news_app/config/setting_app.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static const routeName = "/register_page";

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  bool _isLoading = false;
  bool _errRegister = false;
  bool _successRegister = false;
  String _msg = '';

  Future<void> getRegister() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _errRegister = false;
      });

      var res = await ApiAction.apiAction.register(email: _email, password: _password);

      _errRegister = !res[1];
      _successRegister = res[1];
      _msg = res[0];
      setState(() {
        _isLoading = false;
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'สมัครสมาชิก',
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
                  if (_errRegister)
                    Text(
                      _msg,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: SettingApp.settingApp.textSizeBody,
                      ),
                    ),
                  SizedBox(
                    height: 16,
                  ),
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
                    onSaved: (String? em) {
                      _email = em!;
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
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'รหัสผ่าน',
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
                    obscureText: true,
                    validator: RequiredValidator(errorText: 'กรุณากรอกรหัสผ่าน'),
                    onSaved: (String? pass) {
                      _password = pass!;
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
                  TextFormField(
                    obscureText: true,
                    validator: RequiredValidator(errorText: 'กรุณากรอกรหัสผ่านยืนยัน'),
                    onSaved: (String? confirmPass) {
                      _confirmPassword = confirmPass!;
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
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      setState(() {
                        _errRegister = false;
                      });
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        if (_password != _confirmPassword) {
                          setState(() {
                            _msg = 'รหัสกับยืนยันรหัสไม่ตรงกัน';
                            _errRegister = true;
                          });
                        } else {
                          await getRegister();
                          if (_successRegister) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'สมัครสมาชิกสำเร็จ',
                                      style: TextStyle(
                                        fontSize: SettingApp.settingApp.textSizeBody,
                                      ),
                                    ),
                                    content: Text(_msg),
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
                    label: Text(
                      'สมัครสมาชิก',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
