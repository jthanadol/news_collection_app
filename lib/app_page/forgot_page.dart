import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/app_page/login_page.dart';

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
      appBar: AppBar(
        title: Text('ลืมรหัสผ่าน'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                Form(
                  key: _formKeyEmail,
                  child: Column(
                    children: [
                      Text('อีเมล'),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
                          EmailValidator(errorText: 'โปรดตรวจสอบความถูกต้องของอีเมล'),
                        ]),
                        onSaved: (String? email) {
                          _email = email!;
                        },
                      ),
                    ],
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text('OTP'),
                      TextFormField(
                        validator: RequiredValidator(errorText: 'กรุณากรอกรหัส OTP'),
                        keyboardType: TextInputType.number,
                        onSaved: (String? otp) {
                          _otp = otp!;
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKeyEmail.currentState!.validate()) {
                            _formKeyEmail.currentState!.save();
                            getOTP();
                          }
                        },
                        child: Text('ส่งรหัส OTP'),
                      ),
                      Text('รหัสผ่านใหม่'),
                      TextFormField(
                        validator: RequiredValidator(errorText: 'กรุณากรอกรหัสผ่านใหม่'),
                        obscureText: true,
                        onSaved: (String? password) {
                          _password = password!;
                        },
                      ),
                      Text('ยืนยันรหัสผ่าน'),
                      TextFormField(
                        validator: RequiredValidator(errorText: 'กรุณากรอกยืนยันรหัสผ่าน'),
                        obscureText: true,
                        onSaved: (String? confirmPassword) {
                          _confirmPassword = confirmPassword!;
                        },
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
                                        title: Text('เปลี่ยนรหัสผ่านสำเร็จ'),
                                        content: Text('เมื่อกด \'ตกลง\' จะนำท่านไปยังหน้าเข้าสู่ระบบ'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                LoginPage.routeName,
                                                (route) => false,
                                              );
                                            },
                                            child: Text('ตกลง'),
                                          ),
                                        ],
                                      );
                                    });
                              }
                            }
                          }
                        },
                        child: Text('ยืนยันการเปลี่ยนแปลง'),
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
