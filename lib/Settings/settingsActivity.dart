
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Settings/changeCategoriesActivity.dart';
import 'package:egpycopsversion4/Settings/changeLanguageActivity.dart';
import 'package:egpycopsversion4/Settings/changePasswordActivity.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsActivity extends StatefulWidget {
  const SettingsActivity({Key? key}) : super(key: key);

  @override
  State<SettingsActivity> createState() => SettingsActivityState();
}

class SettingsActivityState extends State<SettingsActivity>
    with TickerProviderStateMixin {
  String? mobileToken;
  final _formKey = GlobalKey<FormState>();
  String userID = "", email = "";

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((String? token) {
      if (token != null) {
        mobileToken = token;
        print("Token: $token");
      }
    });
    getSharedData();
  }

  Future<void> getSharedData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userID") ?? "";
    email = prefs.getString("email") ?? "";

    String connectionResponse = await _checkInternetConnection();
    if (connectionResponse != '1') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => NoInternetConnectionActivity()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
        ),
        backgroundColor: primaryDarkColor,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          color: backgroundGreyColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildSettingsButton(
                iconPath: 'images/list.png',
                text: AppLocalizations.of(context)!.newsCategories,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChangeCategoriesActivity(),
                  ));
                },
              ),
              buildSettingsButton(
                iconPath: 'images/lock.png',
                text: AppLocalizations.of(context)!.changePassword,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChangePasswordActivity(),
                  ));
                },
              ),
              buildSettingsButton(
                iconPath: 'images/translate.png',
                text: AppLocalizations.of(context)!.language,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChangeLanguageActivity(),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSettingsButton({
    required String iconPath,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: SizedBox(
        width: double.infinity,
        height: 50.0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: primaryColor, backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            elevation: 0,
          ),
          onPressed: onPressed,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(iconPath, color: primaryColor),
              ),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontFamily: 'cocon-next-arabic-regular',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _checkInternetConnection() async {
    var result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.none ? "0" : "1";
  }
}
