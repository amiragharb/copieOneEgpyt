import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Home/homeActivity.dart';
import 'package:egpycopsversion4/Home/homeFragment.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Translation/LocaleHelper.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../authService.dart';
import '../main.dart';

BaseUrl BASE_URL = BaseUrl();
String baseUrl = BASE_URL.BASE_URL;

AuthService appAuth = AuthService();

// Add missing global variables
LocaleHelper helper = LocaleHelper();
String myLanguage = "en";
String languageHome = "en";

class ChangeLanguageActivity extends StatefulWidget {
  @override
  _ChangeLanguageActivityState createState() => _ChangeLanguageActivityState();
}

class _ChangeLanguageActivityState extends State<ChangeLanguageActivity> {
  late SpecificLocalizationDelegate _specificLocalizationDelegate;
  String userID = "";
  String mobileToken = "";

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((String? token) {
      if (token != null) {
        print("Token: $token");
        mobileToken = token;
      }
    });
    getDataFromShared();
  }

  Future<void> getDataFromShared() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      myLanguage = (prefs.getString('language') ?? "en");
      userID = prefs.getString("userID") ?? "";
    });
    print('userID: $userID');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppLocalizations.of(context)!.language,
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.normal,
            fontFamily: 'cocon-next-arabic-regular',
          ),
        ),
        backgroundColor: primaryDarkColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Column(
              children: [
                Image.asset(
                  'images/logotransparents.png',
                  height: 200,
                  width: 200,
                ),
                const SizedBox(height: 70),
                _buildLanguageButton(context, "English", "en", accentColor),
                const SizedBox(height: 20),
                _buildLanguageButton(context, "العربية", "ar", primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, String text, String langCode, Color color) {
    bool isSelected = myLanguage == langCode;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 50.0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? color.withOpacity(0.8) : color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: isSelected ? 8.0 : 2.0,
          ),
          onPressed: () async {
            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );

            try {
              languageHome = langCode;
              await insertDataIntoShared(langCode);
              String connectionResponse = await _checkInternetConnection();

              if (connectionResponse == '1') {
                String response = await setUserLangID();

                // Hide loading indicator
                Navigator.of(context).pop();

                if (response == '"1"') {
                  // Update helper if it exists and has the callback
                  if (helper.onLocaleChanged != null) {
                    helper.onLocaleChanged!(Locale(langCode));
                  }
                  
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeActivity(false)),
                    ModalRoute.withName("/Home"),
                  );
                } else {
                  _showErrorToast(context);
                }
              } else {
                // Hide loading indicator
                Navigator.of(context).pop();
                
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => NoInternetConnectionActivity()),
                );
              }
            } catch (e) {
              // Hide loading indicator
              Navigator.of(context).pop();
              _showErrorToast(context);
              print('Error changing language: $e');
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                const Icon(Icons.check, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontFamily: 'cocon-next-arabic-regular',
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorToast(BuildContext context) {
    Fluttertoast.showToast(
      msg: AppLocalizations.of(context)!.errorConnectingWithServer,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.red,
      fontSize: 16.0,
    );
  }

  Future<String> _checkInternetConnection() async {
    try {
      var result = await Connectivity().checkConnectivity();
      return result == ConnectivityResult.none ? "0" : "1";
    } catch (e) {
      print('Error checking connectivity: $e');
      return "0";
    }
  }

  Future<String> setUserLangID() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String currentLanguage = prefs.getString("language") ?? "en";
      String languageID = currentLanguage == "en" ? "2" : "1";

      final response = await http.post(
        Uri.parse('$baseUrl/Users/SetUserLangID/?UserAccountID=$userID&LanguageID=$languageID&token=$mobileToken'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print("SetUserLangID response: ${response.body}");

      return response.statusCode == 200 ? response.body : "error";
    } catch (e) {
      print('Error setting user language: $e');
      return "error";
    }
  }

  Future<bool> insertDataIntoShared(String language) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("language", language);
      
      // Update global variable
      setState(() {
        myLanguage = language;
      });
      
      return true;
    } catch (e) {
      print('Error saving language preference: $e');
      return false;
    }
  }
}