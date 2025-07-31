// lib/Login/needVerificationActivity.dart
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart' show BaseUrl;
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Home/homeActivity.dart';
import 'package:egpycopsversion4/Login/login.dart';
import 'package:egpycopsversion4/Models/user.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Profile/completeRegistrationDataActivity.dart';
import 'package:egpycopsversion4/Translation/LocaleHelper.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

BaseUrl BASE_URL = BaseUrl();
String baseUrl = BASE_URL.BASE_URL;

class NeedVerificationActivity extends StatefulWidget {
  const NeedVerificationActivity({Key? key}) : super(key: key);

  @override
  NeedVerificationActivityState createState() => NeedVerificationActivityState();
}

class NeedVerificationActivityState extends State<NeedVerificationActivity> {
  late SpecificLocalizationDelegate _specificLocalizationDelegate;

  // Helper **local** (on n’utilise pas le helper global ici)
  final LocaleHelper _helper = LocaleHelper();

  @override
  void initState() {
    super.initState();

    // Fallback immédiat pour éviter tout LateInitializationError
    _specificLocalizationDelegate = SpecificLocalizationDelegate(Locale('en'));

    _helper.onLocaleChanged = onLocaleChange;

    // Charge la langue préférée et met à jour la locale
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language') ?? 'en';
    onLocaleChange(Locale(lang));
  }

  void onLocaleChange(Locale locale) {
    if (!mounted) return;
    setState(() {
      _specificLocalizationDelegate = SpecificLocalizationDelegate(locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ce MaterialApp fournit la localisation si ton MyApp global ne la fournit pas.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FallbackCupertinoLocalisationsDelegate(),
      ],
      // IMPORTANT : on ajoute notre delegate spécifique APRES les delegates systèmes
      builder: (context, child) {
        return Localizations.override(
          context: context,
          delegates: [
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            const FallbackCupertinoLocalisationsDelegate(),
            _specificLocalizationDelegate,
          ],
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      supportedLocales: const [Locale('en'), Locale('ar')],
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        hintColor: accentColor,
        fontFamily: 'cocon-next-arabic-regular',
      ),
      home: const CompleteRegistrationDataPageActivity(title: 'EGY Copts'),
    );
  }
}

class CompleteRegistrationDataPageActivity extends StatefulWidget {
  const CompleteRegistrationDataPageActivity({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _CompleteRegistrationDataPageActivityState createState() =>
      _CompleteRegistrationDataPageActivityState();
}

class _CompleteRegistrationDataPageActivityState
    extends State<CompleteRegistrationDataPageActivity> with TickerProviderStateMixin {
  // État local (pas de variables globales pour éviter les collisions)
  String myLanguage = 'en';
  String userID = '';
  String? emailStored;
  String? passwordStored;
  String mobileToken = '';
  String? accountType;
  bool hasMainAccount = false;

  int loginState = 0;
  late final AnimationController _animController;
  late final Animation<double> _animationLogin;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationLogin = Tween<double>(begin: 0, end: 1).animate(_animController);

    // Token FCM
    FirebaseMessaging.instance.getToken().then((token) {
      if (!mounted) return;
      if (token != null) setState(() => mobileToken = token);
    });

    _readPrefsAndInit();
  }

  Future<void> _readPrefsAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      myLanguage = prefs.getString('language') ?? 'en';
      userID = prefs.getString('userID') ?? '';
      emailStored = prefs.getString('email');
      passwordStored = prefs.getString('password');
      accountType = prefs.getString('accountType');
      hasMainAccount = prefs.getBool('hasMainAccount') ?? false;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _animateButton() {
    _animController.forward(from: 0);
    setState(() => loginState = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            AppLocalizations.of(context)!.accountValidation,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
          ),
        ),
        backgroundColor: primaryDarkColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0),
            child: GestureDetector(
              child: SizedBox(
                width: 30.0,
                height: 30.0,
                child: Image.asset('images/logout_white.png'),
              ),
              onTap: () async {
                final response = await _logout();
                if (!mounted) return;
                if (response == "1") {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginActivity()),
                    ModalRoute.withName("/Login"),
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.errorConnectingWithServer,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.white,
                    textColor: Colors.red,
                    fontSize: 16.0,
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                child: Text(
                  AppLocalizations.of(context)!.accountNotValidated,
                  style: TextStyle(
                    fontSize: 26.0,
                    fontFamily: 'cocon-next-arabic-regular',
                    color: logoBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                child: Text(
                  AppLocalizations.of(context)!.pleaseCheckYourEmailToValidateYourAccount,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontFamily: 'cocon-next-arabic-regular',
                    color: primaryDarkColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Icon(Icons.mail, color: accentColor, size: 50),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 20.0, right: 15.0, left: 15.0),
                  child: InkWell(
                    child: Text(
                      AppLocalizations.of(context)!.resendValidationEmail,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 22.0,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.underline,
                        fontFamily: 'cocon-next-arabic-regular',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    onTap: () async {
                      final response = await _sendActivationEmail();
                      Fluttertoast.showToast(
                        msg: response == "1"
                            ? AppLocalizations.of(context)!
                                .emailWasSentToYouPleaseCheckYourEmailToValidateYourAccount
                            : AppLocalizations.of(context)!.errorConnectingWithServer,
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.white,
                        textColor: response == "1" ? Colors.green : Colors.red,
                        fontSize: 16.0,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        width: double.maxFinite,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryDarkColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          ),
          onPressed: () async {
            final connection = await _checkInternetConnection();
            if (connection != '1') {
              if (!mounted) return;
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoInternetConnectionActivity()));
              return;
            }

            if (loginState == 0 || loginState == 2) _animateButton();

            final response = await _login(emailStored ?? '', passwordStored ?? '');
            if (!mounted) return;

            if (response == '1') {
              setState(() => loginState = 2);

              if (hasMainAccount) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomeActivity(false)),
                  ModalRoute.withName("/Home"),
                );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => CompleteRegistrationDataActivity(accountType ?? "")),
                  ModalRoute.withName("/CompleteData"),
                );
              }
            } else if (response == "2") {
              setState(() => loginState = 2);
              Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.accountIsNotActivated,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.white,
                textColor: Colors.red,
                fontSize: 16.0,
              );
            } else {
              Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.errorConnectingWithServer,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.white,
                textColor: Colors.red,
                fontSize: 16.0,
              );
            }
          },
          child: _buildLoginButton(),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    if (loginState == 1) {
      return const SizedBox(
        width: 24.0,
        height: 24.0,
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(Icons.refresh, color: Colors.white),
        ),
        Text(
          'Refresh',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontFamily: 'cocon-next-arabic-regular',
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Future<String> _sendActivationEmail() async {
    _showLoading(context);
    final response = await http.post(
      Uri.parse('$baseUrl/Users/SendActivationEmail/?UserID=$userID&Token=$mobileToken'),
    );
    _hideLoading(context);

    if (response.statusCode == 200) {
      return response.body.toString() == "\"1\"" ? "1" : response.body.toString();
    }
    return response.body.toString();
    }

  Future<String> _logout() async {
    _showLoading(context);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userID", "");
    await prefs.setString("loginUsername", "");
    await prefs.setString("name", "");
    await prefs.setString("accountType", "");
    await prefs.setString("email", "");
    await prefs.setString("address", "");
    await prefs.setBool("hasMainAccount", false);

    final response = await http.post(
      Uri.parse('$baseUrl/Users/Logout/?UserID=$userID&Token=$mobileToken'),
    );

    _hideLoading(context);

    if (response.statusCode == 200) {
      return response.body.toString() == "\"1\"" ? "1" : response.body.toString();
    }
    return response.body.toString();
  }

  Future<String> _login(String email, String password) async {
    final languageID = myLanguage == "en" ? "2" : "1";
    final deviceTypeID = Platform.isIOS ? "3" : "2";
    final encodedPassword = Uri.encodeComponent(password);

    final response = await http.post(
      Uri.parse(
        '$baseUrl/Users/login/?Email=$email&pass=$encodedPassword&LanguageID=$languageID&DeviceTypeID=$deviceTypeID&Token=$mobileToken',
      ),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body.toString());
      final loginData = User.fromJson(jsonResponse);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("userID", loginData.userID ?? "");
      await prefs.setString("loginUsername", loginData.loginUsername ?? "");
      await prefs.setString("name", loginData.name ?? "");
      await prefs.setBool("isValidate", loginData.isValidate ?? false);
      await prefs.setBool("isActiveted", loginData.isActiveted ?? false);
      await prefs.setString("accountType", loginData.accountType ?? "");
      await prefs.setString("email", loginData.email ?? "");
      await prefs.setString("address", loginData.address ?? "");
      await prefs.setBool("hasMainAccount", loginData.hasMainAccount ?? false);
      await prefs.setString("sucessCode", loginData.sucessCode ?? "");
      await prefs.setInt("governateID", loginData.governateID ?? 0);
      await prefs.setInt("branchID", loginData.branchID ?? 0);
      await prefs.setString("password", password);

      setState(() {
        // Mettre à jour l’état local pour la navigation qui suit
        hasMainAccount = loginData.hasMainAccount ?? false;
        accountType = loginData.accountType;
      });

      final code = loginData.sucessCode ?? "";
      if (code == "1" || code == "2") return code;
      return code;
    }

    return response.body;
  }

  Future<String> _checkInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.none ? "0" : "1";
  }

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
