import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/Home/homeActivity.dart';
import 'package:egpycopsversion4/Login/auth_ui.dart';
import 'package:egpycopsversion4/Models/user.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Profile/completeRegistrationDataActivity.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:egpycopsversion4/Login/forgotPassword.dart' as fp;
import 'package:egpycopsversion4/Login/register.dart' as rg;

void _log(String msg) {
  if (kDebugMode) debugPrint('[LOGIN] $msg');
}

class LoginActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> with TickerProviderStateMixin {
  String myLanguage = "en";
  String mobileToken = "";
  int loginState = 0;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadLang();
    FirebaseMessaging.instance.getToken().then((t) {
      if (t != null) setState(() => mobileToken = t);
      _log('FCM token present=${t != null}');
    });
  }

  Future<void> _loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      myLanguage = prefs.getString('language') ?? 'en';
      rememberMe = prefs.getBool('remember_me') ?? false;
      if (rememberMe) {
        emailController.text = prefs.getString('remember_email') ?? '';
      }
    });
  }

  Future<void> _persistRemember(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', value);
    if (value) {
      await prefs.setString('remember_email', emailController.text.trim());
    } else {
      await prefs.remove('remember_email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: AuthScaffold(
          backgroundColor: Colors.white,
          topLogoAsset: 'images/logotransparents.png',
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: LoginCard(
                      title: t?.loginUser ?? 'Login',
                      emailController: emailController,
                      passwordController: passwordController,
                      remember: rememberMe,
                      loading: (loginState == 1),
                      onRememberChanged: (v) async {
                        setState(() => rememberMe = v);
                        await _persistRemember(v);
                      },
                      onForgotPassword: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => fp.ForgotPasswordActivity()));
                      },
                      onRegister: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => rg.RegisterActivity()));
                      },
                      onSubmit: (email, pass, remember) async {
                        final net = await _checkInternetConnection();
                        if (net != '1') {
                          if (!mounted) return;
                          Navigator.push(context, MaterialPageRoute(builder: (_) => NoInternetConnectionActivity()));
                          return;
                        }

                        setState(() => loginState = 1);
                        final code = await _login(email, pass);
                        if (!mounted) return;

                        if (code == '1') {
                          setState(() => loginState = 2);
                          final prefs = await SharedPreferences.getInstance();
                          final hasMainAccount = prefs.getBool('hasMainAccount') ?? false;
                          final accountType = prefs.getString('accountType') ?? '';

                          if (hasMainAccount) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => HomeActivity(false)),
                              ModalRoute.withName('/Home'),
                            );
                          } else {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => CompleteRegistrationDataActivity(accountType)),
                              ModalRoute.withName('/CompleteData'),
                            );
                          }
                        } else {
                          _handleLoginError(context, code ?? 'Error');
                          setState(() => loginState = 0);
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<String> _checkInternetConnection() async {
    final r = await Connectivity().checkConnectivity();
    return r == ConnectivityResult.none ? '0' : '1';
  }

  Future<String?> _login(String rawEmail, String rawPassword) async {
    final email = rawEmail.trim().toLowerCase();
    final password = rawPassword.trim();
    final languageID = (myLanguage == "en") ? "2" : "1";
    final deviceTypeID = Platform.isIOS ? "3" : "2";

    final uri = Uri.https(
      'egycopts.com',
      '/api_1_0_8/api/Users/login/',
      {
        'Email': email,
        'pass': password,
        'LanguageID': languageID,
        'DeviceTypeID': deviceTypeID,
        if (mobileToken.isNotEmpty) 'Token': mobileToken,
      },
    );

    try {
      final resp = await http.post(uri).timeout(const Duration(seconds: 20));
      if (resp.statusCode != 200) {
        return 'SERVER_ERROR:${resp.statusCode}:${resp.body}';
      }

      dynamic parsed;
      try {
        parsed = json.decode(resp.body);
      } catch (_) {
        parsed = resp.body;
      }

      if (parsed is String) return parsed.replaceAll('"', '');

      final user = User.fromJson(parsed);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userID',        user.userID ?? '');
      await prefs.setString('loginUsername', user.loginUsername ?? '');
      await prefs.setString('name',          user.name ?? '');
      await prefs.setBool  ('isValidate',    user.isValidate ?? false);
      await prefs.setBool  ('isActiveted',   user.isActiveted ?? false);
      await prefs.setString('accountType',   user.accountType ?? '');
      await prefs.setString('email',         user.email ?? '');
      await prefs.setString('address',       user.address ?? '');
      await prefs.setBool  ('hasMainAccount',user.hasMainAccount ?? false);
      await prefs.setString('sucessCode',    user.sucessCode ?? '');
      await prefs.setInt   ('governateID',   user.governateID ?? 0);
      await prefs.setInt   ('branchID',      user.branchID ?? 0);
      await prefs.setString('password',      password);

      return user.sucessCode;
    } on TimeoutException {
      return 'SERVER_ERROR:408:Request timeout';
    } catch (e) {
      return 'SERVER_ERROR:0:$e';
    }
  }

  void _handleLoginError(BuildContext context, String code) {
    if (code.startsWith('SERVER_ERROR')) {
      final parts = code.split(':');
      final status = parts.length > 1 ? parts[1] : '';
      final msg    = parts.length > 2 ? parts.sublist(2).join(':') : '';
      final text = 'Server error ($status). ${msg.isNotEmpty ? msg : 'Please try again later.'}';
      Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        textColor: Colors.red,
        fontSize: 16.0,
      );
      return;
    }

    String msg;
    if (code == '2') {
      msg = AppLocalizations.of(context)?.accountIsNotActivated ?? 'Account is not activated';
    } else if (code == '3') {
      msg = AppLocalizations.of(context)?.emailAndPasswordDoesNotMatch ?? 'Email and password do not match';
    } else if (code == '4') {
      msg = 'Email or Password is empty';
    } else {
      msg = AppLocalizations.of(context)?.emailAndPasswordDoesNotMatch ?? 'Email and password do not match';
    }

    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.white,
      textColor: Colors.red,
      fontSize: 16.0,
    );
  }
}
