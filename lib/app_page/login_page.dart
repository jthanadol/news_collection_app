import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app/api_response/api_action.dart';
import 'package:news_app/app_page/app_page.dart';
import 'package:news_app/app_page/forgot_page.dart';
import 'package:news_app/app_page/register_page.dart';
import 'package:news_app/config/auth.dart';
import 'package:news_app/config/setting_app.dart';

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

  void initState() {
    super.initState();
    SettingApp.settingApp.readSettingFile();
    checkLoginFile();
  }

  Future<void> checkLoginFile() async {
    await Auth.auth.readLoginFile();
    if (Auth.auth.isLogin) {
      Navigator.pushReplacementNamed(context, AppPage.routeName);
    }
  }

  Future<void> getLogin() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _errLogin = false;
      });

      var res = await ApiAction.apiAction.login(email: _email, password: _password);
      if (res[1] == -1) {
        _errLogin = true;
      } else {
        Auth.auth.login(email: _email, accountId: res[1], accountType: "Email");
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

        List<dynamic> res = await ApiAction.apiAction.googleLogin(
          email: _googleSignIn.currentUser!.email,
          googleId: _googleSignIn.currentUser!.id,
        );

        setState(() {
          if (res[1] == -1) {
            _errLogin = true;
            _msg = res[0];
          } else {
            Auth.auth.login(email: _googleSignIn.currentUser!.email, accountId: res[1], accountType: "Google");
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
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/background_2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'เข้าสู่ระบบ',
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
                const SizedBox(
                  height: 50,
                ),
                if (_errLogin)
                  Text(
                    _msg,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: SettingApp.settingApp.textSizeBody,
                    ),
                  ),
                const SizedBox(
                  height: 16,
                ),
                Form(
                  key: _fromKey,
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
                        onSaved: (String? em) {
                          _email = em!;
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
                        'รหัสผ่าน',
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
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, ForgotPage.routeName);
                            },
                            child: Text(
                              'ลืมรหัสผ่าน ?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: SettingApp.settingApp.textSizeButton,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
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
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (_fromKey.currentState!.validate()) {
                            _fromKey.currentState?.save();
                            await getLogin();
                            if (!_errLogin) {
                              _fromKey.currentState?.reset();
                              Navigator.pushReplacementNamed(context, AppPage.routeName);
                            }
                          }
                        },
                        icon: Icon(
                          Icons.login,
                          color: Colors.black87,
                          size: SettingApp.settingApp.iconSize,
                        ),
                        label: Text(
                          'เข้าสู่ระบบ',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: SettingApp.settingApp.textSizeButton,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.white,
                  thickness: 1,
                  height: 24,
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await googleLogin();
                    if (!_errLogin && Auth.auth.isLogin) {
                      try {
                        Navigator.pushReplacementNamed(context, AppPage.routeName);
                      } catch (e) {
                        print('Google Login error : ${e.toString()}');
                      }
                    }
                  },
                  label: Text(
                    'Google',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: SettingApp.settingApp.textSizeButton,
                    ),
                  ),
                  icon: Image.asset(
                    'assets/img/google_icon.png',
                    cacheHeight: SettingApp.settingApp.iconSize.toInt(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ยังไม่มีบัญชี ?',
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
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RegisterPage.routeName);
                      },
                      child: Text(
                        'สมัครสมาชิกที่นี่',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SettingApp.settingApp.textSizeButton,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
