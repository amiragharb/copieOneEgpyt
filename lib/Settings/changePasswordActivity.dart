
// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, unnecessary_new, prefer_final_fields, unused_field, deprecated_member_use

import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

BaseUrl BASE_URL = BaseUrl();
String baseUrl = BASE_URL.BASE_URL;
int saveState = 0;
bool viewCurrentPassword = false;
bool viewNewPassword = false;

class ChangePasswordActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChangePasswordActivityState();
}

class ChangePasswordActivityState extends State<ChangePasswordActivity>
    with TickerProviderStateMixin {
  String mobileToken = '';
  final _formKey = GlobalKey<FormState>();
  late Animation _animationLogin;

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  String userID = "", email = "";

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((String? token) {
      if (token != null) {
        mobileToken = token;
      }
    });
    getSharedData();
  }

  Future<void> getSharedData() async {
    final prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userID") ?? "";
    email = prefs.getString("email") ?? "";
    String connectionResponse = await _checkInternetConnection();
    if (connectionResponse != '1') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => NoInternetConnectionActivity(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(AppLocalizations.of(context)!.changePassword,
            style: TextStyle(color: Colors.white)),
        backgroundColor: primaryDarkColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              buildPasswordField(
                controller: currentPasswordController,
                label: AppLocalizations.of(context)!.currentPasswordWithAstric,
                obscureText: !viewCurrentPassword,
                toggleVisibility: () => setState(() {
                  viewCurrentPassword = !viewCurrentPassword;
                }),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterYourCurrentPassword;
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              buildPasswordField(
                controller: newPasswordController,
                label: AppLocalizations.of(context)!.newPasswordWithAstric,
                obscureText: !viewNewPassword,
                toggleVisibility: () => setState(() {
                  viewNewPassword = !viewNewPassword;
                }),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterNewPassword;
                  } else if (value.length < 8) {
                    return AppLocalizations.of(context)!.passwordCannotBeLessThan8;
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String connectionResponse = await _checkInternetConnection();
                      if (connectionResponse == '1') {
                        if (saveState == 0 || saveState == 2) animateButton();
                        String response = await _updatePassword(
                          currentPasswordController.text,
                          newPasswordController.text,
                        );
                        setState(() {
                          saveState = 2;
                        });
                        if (response == '1') {
                          Navigator.of(context).pop();
                          Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!.passwordUpdatedSuccessfully,
                            backgroundColor: Colors.white,
                            textColor: Colors.green,
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!.errorConnectingWithServer,
                            backgroundColor: Colors.white,
                            textColor: Colors.red,
                          );
                        }
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => NoInternetConnectionActivity(),
                        ));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDarkColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  child: buildSaveButton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentColor)),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVisibility,
        ),
      ),
      validator: validator,
    );
  }

  Future<String> _updatePassword(String oldPassword, String newPassword) async {
    String encodedOld = Uri.encodeComponent(oldPassword);
    String encodedNew = Uri.encodeComponent(newPassword);
    final url = Uri.parse('$baseUrl/Users/UpdatePassword/?Email=$email&OldPassWord=$encodedOld&NewPassWord=$encodedNew&UserID=$userID&Token=$mobileToken');
    final response = await http.post(url);
    if (response.statusCode == 200) {
      return json.decode(response.body).toString();
    }
    return "0";
  }

  Widget buildSaveButton() {
    if (saveState == 1) {
      return CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
    } else {
      return Text(
        AppLocalizations.of(context)!.save,
        style: TextStyle(fontSize: 18.0, fontFamily: 'cocon-next-arabic-regular'),
      );
    }
  }

  void animateButton() {
    var controller = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animationLogin = Tween(begin: 0.0, end: 1.0).animate(controller)..addListener(() {
      setState(() {});
    });
    controller.forward();
    setState(() {
      saveState = 1;
    });
  }

  Future<String> _checkInternetConnection() async {
    var result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.none ? "0" : "1";
  }
}
