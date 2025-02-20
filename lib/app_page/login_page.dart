import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/app_page/app_page.dart';
import 'package:news_app/app_page/forgot_page.dart';
import 'package:news_app/app_page/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const routeName = "/login_page";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _fromKey = GlobalKey<FormState>();
  final _googleSignIn = GoogleSignIn();

  String _email = '';
  String _password = '';

  bool _isLoading = false;
  bool _errLogin = false;
  String _msg = '';

  Future<void> getLogin() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _errLogin = false;
      });

      var res = await ApiAction.apiAction.login(email: _email, password: _password);
      if (res[1] == -1) {
        _errLogin = true;
      }
      _msg = res[0];
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> googleLogin() async {
    try {
      await _googleSignIn.signIn();
      if (_googleSignIn.currentUser != null) {
        setState(() {
          _errLogin = false;
          _msg = '';
        });

        List<dynamic> res = await ApiAction.apiAction.googleLogin(email: _googleSignIn.currentUser!.email, googleId: _googleSignIn.currentUser!.id);

        setState(() {
          if (res[1] == -1) {
            _errLogin = true;
            _msg = res[0];
          }
        });
      }
    } catch (error) {
      print("Error during Google Sign-In: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_errLogin)
                  Text(
                    _msg,
                    style: const TextStyle(color: Colors.red),
                  ),
                Form(
                  key: _fromKey,
                  child: Column(
                    children: [
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
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (_fromKey.currentState!.validate()) {
                            _fromKey.currentState?.save();
                            await getLogin();
                            if (!_errLogin) {
                              _fromKey.currentState?.reset();
                              Navigator.pushNamed(context, AppPage.routeName);
                            }
                          }
                        },
                        icon: Icon(Icons.login),
                        label: Text('เข้าสู่ระบบ'),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, RegisterPage.routeName);
                  },
                  label: Text('สมัครสมาชิก'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, ForgotPage.routeName);
                  },
                  label: Text('ลืมรหัสผ่าน'),
                ),
                Divider(),
                ElevatedButton.icon(
                  onPressed: () async {
                    await googleLogin();
                    if (!_errLogin) {
                      Navigator.pushNamed(context, AppPage.routeName);
                    }
                  },
                  label: Text('Google'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
