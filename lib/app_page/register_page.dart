import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/app_page/login_page.dart';

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
      appBar: AppBar(
        title: Text('สมัครสมาชิก'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_errRegister)
                    Text(
                      _msg,
                      style: TextStyle(color: Colors.red),
                    ),
                  Text('อีเมล'),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
                      EmailValidator(errorText: 'โปรดตรวจสอบความถูกต้องของอีเมล'),
                    ]),
                    onSaved: (String? em) {
                      _email = em!;
                    },
                  ),
                  Text('รหัสผ่าน'),
                  TextFormField(
                    obscureText: true,
                    validator: RequiredValidator(errorText: 'กรุณากรอกรหัสผ่าน'),
                    onSaved: (String? pass) {
                      _password = pass!;
                    },
                  ),
                  Text('ยืนยันรหัสผ่าน'),
                  TextFormField(
                    obscureText: true,
                    validator: RequiredValidator(errorText: 'กรุณากรอกรหัสผ่านยืนยัน'),
                    onSaved: (String? confirmPass) {
                      _confirmPassword = confirmPass!;
                    },
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
                                    title: Text('สมัครสมาชิกสำเร็จ'),
                                    content: Text(_msg),
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
                    label: Text('สมัครสมาชิก'),
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
