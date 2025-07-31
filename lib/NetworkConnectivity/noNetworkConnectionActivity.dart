import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NoInternetConnectionActivity extends StatefulWidget {
  @override
  _NoInternetConnectionActivityState createState() => _NoInternetConnectionActivityState();
}

class _NoInternetConnectionActivityState extends State<NoInternetConnectionActivity> {
  @override
  void initState() {
    super.initState();
  }

  Future<String> _checkNetwork() async {
    var result = await Connectivity().checkConnectivity();
    return (result == ConnectivityResult.none) ? '0' : '1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: SizedBox(
          width: 160,
          height: 110,
          child: Image.asset('images/logotransparents.png', fit: BoxFit.contain),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('images/internet.png', width: 200, height: 200),
                const SizedBox(height: 30),
                Text(
                  AppLocalizations.of(context)!.errorConnectingToTheInternet,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: 'cocon-next-arabic-regular',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.pressRetryToTryAgain,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: 'cocon-next-arabic-regular',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.all(14.0),
                      ),
                      onPressed: () async {
                        String responseNetwork = await _checkNetwork();
                        if (responseNetwork == '1') {
                          Navigator.of(context).pop();
                        }
                        // else do nothing or show error
                      },
                      child: Text(
                        AppLocalizations.of(context)!.retry,
                        style: TextStyle(
                          fontSize: 25.0,
                          fontFamily: 'cocon-next-arabic-regular',
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
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
