import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Firebase/FirebaseMessageWrapper.dart';
import 'package:egpycopsversion4/Home/homeActivity.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

BaseUrl BASE_URL = BaseUrl();
String baseUrl = BASE_URL.BASE_URL;
String? newNotification;  // Make sure to handle nullability properly

class NotificationDetailsActivity extends StatefulWidget {
  NotificationDetailsActivity(String notificationText) {
    newNotification = notificationText; // Assign passed notification text
  }

  @override
  State<StatefulWidget> createState() {
    return NotificationDetailsActivityState();
  }
}

class NotificationDetailsActivityState
    extends State<NotificationDetailsActivity> with TickerProviderStateMixin {
  String? mobileToken;

  var _formKey = GlobalKey<FormState>();
  int loginState = 0;
  Animation? _animationLogin;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((String? token) {
      if (token != null) {
        print("Token  " + token);
        mobileToken = token;
      } else {
        print("Failed to get token");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            AppLocalizations.of(context)!.notifications,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeActivity(false)),
                  ModalRoute.withName("/Home"));
            },
          ),
          backgroundColor: primaryDarkColor, systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body:
         FirebaseMessageWrapper(
  child: Container(
    color: grey200,
    child: Transform.translate(
      offset: Offset(0, 0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: Column(
              children: <Widget>[
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/logotransparents.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    child: Text(
                      newNotification ?? 'No notification text',
                      style: TextStyle(
                        color: primaryDarkColor,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
)),

      onWillPop: _onWillPop,
    );
  }

  Future<bool> _onWillPop() async {
    print("onWillPop");
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeActivity(false)),
        ModalRoute.withName("/Home"));
    return true;  // Ensure the method returns a Future<bool>
  }

  Future<String> _checkInternetConnection() async {
    String connectionResult;
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      connectionResult = "0";
    } else {
      connectionResult = "1";
    }
    return connectionResult;
  }
}
