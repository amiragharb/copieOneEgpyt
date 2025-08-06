import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Family/addFamilyMemberActivity.dart';
import 'package:egpycopsversion4/Family/familyFragment.dart' show FamilyFragment;
import 'package:egpycopsversion4/Firebase/FirebaseMessageWrapper.dart';
import 'package:egpycopsversion4/Home/homeFragment.dart';
import 'package:egpycopsversion4/Home/myBookingsFragment.dart';
import 'package:egpycopsversion4/Home/youtubeLiveFragment.dart';
import 'package:egpycopsversion4/Login/login.dart';
import 'package:egpycopsversion4/Models/user.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Settings/settingsActivity.dart';
import 'package:egpycopsversion4/Settings/changePasswordActivity.dart';
import 'package:egpycopsversion4/Translation/LocaleHelper.dart';
import 'package:egpycopsversion4/Translation/localizations.dart' hide AppLocalizations; // <-- plus de hide
import 'package:egpycopsversion4/l10n/app_localizations.dart';

import '../main.dart' show languageHome, setAppLocale;

typedef LocaleChangeCallback = void Function(Locale locale);

late BuildContext mContext;

BaseUrl BASE_URL = BaseUrl();
String baseUrl = BASE_URL.BASE_URL;

// Variables globales
String userID = "";
String accountType = "";
String userName = "";
String userEmail = "";
String? fragment;
String? mobileToken;
late bool firstLogin;

String loginUsername = "";
String sucessCode = "";
String name = "";
String email = "";
String address = "";
bool hasMainAccount = false;
int defaultGovernateID = 0, defaultBranchID = 0;

// Helper de langue
LocaleHelper helper = LocaleHelper();

class HomeActivity extends StatefulWidget {
  final bool fromMain;
  const HomeActivity(this.fromMain, {Key? key}) : super(key: key);

  @override
  HomeActivityState createState() => HomeActivityState();
}

class HomeActivityState extends State<HomeActivity> {
  late GlobalKey<ScaffoldState> _scaffoldKey;
  int selectedBottomItem = 0;

  Locale _appLocale = Locale(languageHome ?? 'en');

  // Contrôleurs personnalisés pour le drawer
  MyCustomControllerDrawerName customControllerDrawerName =
      MyCustomControllerDrawerName(drawerNameController: TextEditingController());
  MyCustomControllerDrawerEmail customControllerDrawerEmail =
      MyCustomControllerDrawerEmail(drawerEmailController: TextEditingController());

  @override
  void initState() {
    super.initState();
    _scaffoldKey = GlobalKey();
    helper.onLocaleChanged = onLocaleChange;

    fragment = "MyBookings";
    initApp();
  }

  Future<void> initApp() async {
    try {
      mobileToken = await FirebaseMessaging.instance.getToken();
    } catch (e, s) {
      debugPrint("❌ Erreur Firebase Token: $e");
      debugPrint("$s");
    }

    if (mobileToken == null || mobileToken!.isEmpty) {
      Fluttertoast.showToast(
        msg: "Erreur lors de l'initialisation du token Firebase.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    await getSharedData();
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      _appLocale = locale;
    });
  }

  // Méthode à utiliser pour changer de langue (ex: via bouton settings)
  Future<void> _changeLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
    
    // Use the global setAppLocale to ensure proper language switching
    await setAppLocale(langCode);
    
    // Also update local state
    onLocaleChange(Locale(langCode));
  }

  void onBottomNavTap(int index) {
    setState(() {
      selectedBottomItem = index;
      switch (index) {
        case 0:
          fragment = "MyBookings";
          break;
        case 1:
          fragment = "News";
          break;
        case 2:
          fragment = "Live";
          break;
        case 3:
          if (accountType == "1") 
          {
            fragment = "Profile";
          } else {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddFamilyMemberActivity(
                  false, "", "0", 0, "", "", "", "", "", "", "", 1, true),
            )).then((_) {
              setState(() {
                selectedBottomItem = 0;
                fragment = "MyBookings";
              });
            });
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate, // <-- Important !
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      locale: _appLocale,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        hintColor: accentColor,
        fontFamily: 'cocon-next-arabic-regular',
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: _appLocale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: _scaffoldKey,
          drawer: buildDrawer(),
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
            title: Image.asset('images/logotransparents.png', height: 100.0, width: 100.0),
            backgroundColor: primaryDarkColor,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          body: buildBody(),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
                BoxShadow(
                  color: primaryColor.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: primaryColor.withOpacity(0.12),
                  width: 0.8,
                ),
              ),
            ),
            child: SafeArea(
              child: Container(
                height: 75,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: 'images/online_booking.png',
                      label: AppLocalizations.of(context)?.myBookings ?? "Bookings",
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: 'images/earth.png',
                      label: AppLocalizations.of(context)?.news ?? "News",
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: 'images/live.png',
                      label: AppLocalizations.of(context)?.live ?? "Live",
                    ),
                    _buildNavItem(
                      index: 3,
                      icon: accountType == "1" ? 'images/love.png' : 'images/user.png',
                      label: accountType == "1"
                          ? (AppLocalizations.of(context)?.myFamily ?? "Family")
                          : (AppLocalizations.of(context)?.myProfile ?? "Profile"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBody() {
    switch (fragment) {
      case "News":
        return FirebaseMessageWrapper(child: HomeFragment());
      case "MyBookings":
        return FirebaseMessageWrapper(child: MyBookingsFragment());
      case "Profile":
        return FirebaseMessageWrapper(child: FamilyFragment());
      case "Live":
        return FirebaseMessageWrapper(child: YoutubeLiveFragment());
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildNavItem({
    required int index,
    required String icon,
    required String label,
  }) {
    final bool isSelected = selectedBottomItem == index;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onBottomNavTap(index),
          borderRadius: BorderRadius.circular(16),
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primaryColor.withOpacity(0.12),
                        primaryColor.withOpacity(0.08),
                        primaryColor.withOpacity(0.04),
                      ],
                    )
                  : null,
              border: isSelected
                  ? Border.all(
                      color: primaryColor.withOpacity(0.2),
                      width: 1,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Professional icon container
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isSelected ? 36 : 32,
                      height: isSelected ? 36 : 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isSelected
                            ? RadialGradient(
                                colors: [
                                  primaryColor.withOpacity(0.15),
                                  primaryColor.withOpacity(0.05),
                                ],
                              )
                            : null,
                        border: isSelected
                            ? Border.all(
                                color: primaryColor.withOpacity(0.3),
                                width: 1.5,
                              )
                            : null,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: Image.asset(
                        icon,
                        height: isSelected ? 22 : 20,
                        width: isSelected ? 22 : 20,
                        color: isSelected ? primaryColor : greyColor,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.apps,
                            size: isSelected ? 22 : 20,
                            color: isSelected ? primaryColor : greyColor,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSelected ? 4 : 3),
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: isSelected ? 10.5 : 9.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? primaryColor : greyColor,
                      fontFamily: 'cocon-next-arabic-regular',
                      letterSpacing: isSelected ? 0.3 : 0.2,
                      height: 1.1,
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(top: 2),
                  height: isSelected ? 3 : 0,
                  width: isSelected ? 24 : 0,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              primaryColor.withOpacity(0.8),
                              primaryColor,
                              primaryColor.withOpacity(0.8),
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
      return false;
    }

    if (fragment != "MyBookings") {
      setState(() {
        fragment = "MyBookings";
        selectedBottomItem = 0;
      });
      return false;
    }

    bool? exit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          AppLocalizations.of(mContext)?.areYouSureOfExitFromEGYCopts ?? "Exit?",
          style: const TextStyle(fontFamily: 'cocon-next-arabic-regular'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            child: Text(AppLocalizations.of(mContext)?.yes ?? "Yes"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(mContext)?.no ?? "No"),
          ),
        ],
      ),
    );
    return exit ?? false;
  }

  Future<void> getSharedData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Préférence de langue au démarrage (optionnel)
    String? savedLang = prefs.getString("language");
    if (savedLang != null && savedLang != _appLocale.languageCode) {
      setState(() {
        _appLocale = Locale(savedLang);
      });
    }

    setState(() {
      userID = prefs.getString("userID") ?? "";
      userName = prefs.getString("loginUsername") ?? "";
      userEmail = prefs.getString("email") ?? "";
      accountType = prefs.getString("accountType") ?? "";
      fragment = fragment ?? "MyBookings";

      customControllerDrawerName.drawerNameController.text = userName;
      customControllerDrawerEmail.drawerEmailController.text = userEmail;
    });
  }

  Drawer buildDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            color: primaryColor,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0),
                  child: SizedBox(
                    width: 140,
                    height: 110,
                    child: Image.asset('images/logotransparents.png', fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: MyCustomDrawerName(customController: customControllerDrawerName),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: MyCustomDrawerEmail(customController: customControllerDrawerEmail),
                ),
                // Exemple : bouton switch langue
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => _changeLanguage('en'),
                        child: const Text("English"),
                      ),
                      TextButton(
                        onPressed: () => _changeLanguage('ar'),
                        child: const Text("العربية"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// === Classes des contrôleurs et widgets personnalisés ===

class MyCustomControllerDrawerName {
  final TextEditingController drawerNameController;
  bool enable;
  MyCustomControllerDrawerName({required this.drawerNameController, this.enable = true});
}

class MyCustomDrawerName extends StatelessWidget {
  final MyCustomControllerDrawerName customController;
  const MyCustomDrawerName({Key? key, required this.customController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      userName,
      style: const TextStyle(fontSize: 20.0, color: Colors.white),
    );
  }
}

class MyCustomControllerDrawerEmail {
  final TextEditingController drawerEmailController;
  bool enable;
  MyCustomControllerDrawerEmail({required this.drawerEmailController, this.enable = true});
}

class MyCustomDrawerEmail extends StatelessWidget {
  final MyCustomControllerDrawerEmail customController;
  const MyCustomDrawerEmail({Key? key, required this.customController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Text(
        userEmail,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18.0, color: Colors.white),
      ),
    );
  }
}
