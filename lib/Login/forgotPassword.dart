// lib/Login/forgotPassword.dart
import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Login/auth_ui.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void _log(String msg) { if (kDebugMode) debugPrint('[FORGOT] $msg'); }

final BaseUrl _BASE_URL = BaseUrl();
final String _baseUrl = _BASE_URL.BASE_URL;

class ForgotPasswordActivity extends StatefulWidget {
  const ForgotPasswordActivity({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordActivity> createState() => ForgotPasswordActivityState();
}

class ForgotPasswordActivityState extends State<ForgotPasswordActivity>
    with TickerProviderStateMixin {
  String mobileToken = "";
  final TextEditingController _email = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  int _state = 0; // 0=idle,1=loading,2=done
  String myLanguage = "en";

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      mobileToken = (await FirebaseMessaging.instance.getToken()) ?? "";
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    myLanguage = prefs.getString('language') ?? "en";

    final net = await _checkInternetConnection();
    if (net != '1' && mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => NoInternetConnectionActivity(),
      ));
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: AuthScaffold(
       backgroundColor: Colors.white,                 // fond blanc
  topLogoAsset: 'images/logotransparents.png',  // enlève cet argument si non utilisé
        child: GlassCard(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t?.forgotPassword ?? 'Forgot password',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 28),
                AuthTextField(
                  controller: _email,
                  hint: t?.emailWithAstric ?? 'Email *',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? (t?.pleaseEnterYourEmail ?? 'Please enter your email')
                          : null,
                ),
                const SizedBox(height: 16),
                AuthButton(
                  text: t?.send ?? 'Send',
                  loading: _state == 1,
                  onPressed: () async {
                    if (!(_formKey.currentState?.validate() ?? false)) return;

                    final net = await _checkInternetConnection();
                    if (net != '1') {
                      if (!mounted) return;
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => NoInternetConnectionActivity(),
                      ));
                      return;
                    }

                    setState(() => _state = 1);
                    final resp = await _forgotPassword(_email.text.trim());
                    setState(() => _state = 2);

                    if (resp == '1') {
                      if (mounted) Navigator.of(context).pop();
                      Fluttertoast.showToast(
                        msg: t?.anEmailHasBeenSentToYouPleaseCheckYourInbox
                            ?? 'An email has been sent. Please check your inbox.',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.white,
                        textColor: Colors.green,
                        fontSize: 16.0,
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: t?.emailNotFoundPleaseCheckYourEmail
                            ?? 'Email not found. Please check your email.',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.white,
                        textColor: Colors.red,
                        fontSize: 16.0,
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.maybePop(context),
                  child: const Text('Back', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _forgotPassword(String email) async {
    // Construit un URI correct à partir du baseUrl
    final base = Uri.parse(_baseUrl);
    final host = base.host;                 // ex. egycopts.com
    final prefix = base.path;               // ex. /api_1_0_8/api
    final uri = Uri.https(host, '$prefix/Users/ForgetPassword/', {'Email': email});

    try {
      final response = await http.post(uri).timeout(const Duration(seconds: 20));
      _log('status=${response.statusCode} body=${response.body}');
      if (response.statusCode != 200) return "0";

      dynamic parsed;
      try { parsed = json.decode(response.body); } catch (_) { parsed = response.body; }
      if (parsed is String) return parsed.replaceAll('"', '');
      return parsed.toString();
    } on TimeoutException { return "0"; } catch (_) { return "0"; }
  }

  Future<String> _checkInternetConnection() async {
    final r = await Connectivity().checkConnectivity();
    return r == ConnectivityResult.none ? "0" : "1";
  }
}
