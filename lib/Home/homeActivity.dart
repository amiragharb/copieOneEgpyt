import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Family/addFamilyMemberActivity.dart';
import 'package:egpycopsversion4/Family/familyFragment.dart' show FamilyFragment;
import 'package:egpycopsversion4/Firebase/FirebaseMessageWrapper.dart';
import 'package:egpycopsversion4/Home/homeFragment.dart';
import 'package:egpycopsversion4/Home/myBookingsFragment.dart';
import 'package:egpycopsversion4/Home/youtubeLiveFragment.dart';
import 'package:egpycopsversion4/Settings/settingsActivity.dart';
import 'package:egpycopsversion4/Translation/LocaleHelper.dart';
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

  // Logout method to clear all user data and return to login
  Future<void> _logout() async {
    // Show confirmation dialog
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)?.logout ?? "Logout",
          style: const TextStyle(fontFamily: 'cocon-next-arabic-regular'),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: const TextStyle(fontFamily: 'cocon-next-arabic-regular'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)?.no ?? "Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)?.logout ?? "Logout",
              style: TextStyle(color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        // Clear SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        // Clear Firebase token if possible
        try {
          await FirebaseMessaging.instance.deleteToken();
        } catch (e) {
          print("Error clearing Firebase token: $e");
        }
        
        // Clear global variables
        userID = "";
        accountType = "";
        userName = "";
        userEmail = "";
        fragment = null;
        mobileToken = null;
        loginUsername = "";
        sucessCode = "";
        name = "";
        email = "";
        address = "";
        hasMainAccount = false;
        defaultGovernateID = 0;
        defaultBranchID = 0;
        
        // Show success message
        Fluttertoast.showToast(
          msg: "Logged out successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        
        // Navigate to login screen and clear navigation stack completely
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        
      } catch (e) {
        print("Error during logout: $e");
        Fluttertoast.showToast(
          msg: "Error during logout",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
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
            // For personal accounts, navigate to AddFamilyMemberActivity with profile data
            _openProfilePage();
          }
          break;
      }
    });
  }

  // Open profile page for personal accounts
  void _openProfilePage() async {
    // Navigate to AddFamilyMemberActivity with user's profile data
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddFamilyMemberActivity(
          false, // isAdd = false (editing profile)
          userName, // fullName
          "0", // relationshipId (not applicable for main person)
          0, // deacon (will be loaded from API)
          "", // nationalId (will be loaded from API)
          "", // mobileNumber (will be loaded from API)
          "", // accountMemberID (will be loaded from API)
          "", // addressConstructor (will be loaded from API)
          "", // branchIDConstructor (will be loaded from API)
          "", // governorateIDConstructor (will be loaded from API)
          "", // churchOfAttendancConstructore (will be loaded from API)
          1, // mainAccount = 1 (this is the main person)
          true), // personalAccount = true
    )).then((_) {
      setState(() {
        selectedBottomItem = 0;
        fragment = "MyBookings";
      });
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
    });
  }

  Drawer buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryDarkColor,
              primaryColor,
              primaryColor.withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            // Enhanced Header Section
            Container(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: <Widget>[
                      // Profile Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Enhanced Logo with glassmorphism effect
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.4),
                                    Colors.white.withOpacity(0.2),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Image.asset(
                                    'images/logotransparents.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Enhanced User Name
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                userName.isNotEmpty ? userName : "User",
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'cocon-next-arabic-regular',
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Enhanced Email with better styling
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      userEmail.isNotEmpty ? userEmail : "user@example.com",
                                      style: const TextStyle(
                                        fontSize: 13.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'cocon-next-arabic-regular',
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Enhanced Menu Items Section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Handle indicator
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          // Enhanced Language Selection
                          _buildSectionTitle("Language / اللغة"),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withOpacity(0.1),
                                  primaryColor.withOpacity(0.05),
                                ],
                              ),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildLanguageOption(
                                    isSelected: _appLocale.languageCode == 'en',
                                    flag: "🇺🇸",
                                    language: "English",
                                    onTap: () => _changeLanguage('en'),
                                    isLeft: true,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 50,
                                  color: primaryColor.withOpacity(0.2),
                                ),
                                Expanded(
                                  child: _buildLanguageOption(
                                    isSelected: _appLocale.languageCode == 'ar',
                                    flag: "🇪🇬",
                                    language: "العربية",
                                    onTap: () => _changeLanguage('ar'),
                                    isLeft: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Settings Menu Items
                          _buildSectionTitle("Settings"),
                          const SizedBox(height: 16),
                          
                          _buildMenuItem(
                            icon: Icons.settings_outlined,
                            title: AppLocalizations.of(context)?.settings ?? "App Settings",
                            subtitle: _appLocale.languageCode == 'ar' ? "التفضيلات والإعدادات" : "Preferences & Configuration",
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SettingsActivity()),
                              );
                            },
                          ),
                          
                          _buildMenuItem(
                            icon: Icons.info_outline,
                            title: _appLocale.languageCode == 'ar' ? "حول التطبيق" : "About",
                            subtitle: _appLocale.languageCode == 'ar' ? "إصدار التطبيق والمعلومات" : "App version & information",
                            onTap: () {
                              // Add about page navigation
                            },
                          ),
                          
                          _buildMenuItem(
                            icon: Icons.help_outline,
                            title: _appLocale.languageCode == 'ar' ? "المساعدة والدعم" : "Help & Support",
                            subtitle: _appLocale.languageCode == 'ar' ? "احصل على المساعدة وتواصل معنا" : "Get help and contact us",
                            onTap: () {
                              // Add help page navigation
                            },
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Enhanced Logout Button
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red[400]!,
                                  Colors.red[500]!,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _logout,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.logout_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          AppLocalizations.of(context)?.logout ?? "Logout",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            fontFamily: 'cocon-next-arabic-regular',
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.white.withOpacity(0.7),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: primaryDarkColor,
        fontFamily: 'cocon-next-arabic-regular',
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildLanguageOption({
    required bool isSelected,
    required String flag,
    required String language,
    required VoidCallback onTap,
    required bool isLeft,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isLeft ? 16 : 0),
          bottomLeft: Radius.circular(isLeft ? 16 : 0),
          topRight: Radius.circular(isLeft ? 0 : 16),
          bottomRight: Radius.circular(isLeft ? 0 : 16),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isLeft ? 16 : 0),
              bottomLeft: Radius.circular(isLeft ? 16 : 0),
              topRight: Radius.circular(isLeft ? 0 : 16),
              bottomRight: Radius.circular(isLeft ? 0 : 16),
            ),
            gradient: isSelected
                ? LinearGradient(
                    colors: [primaryDarkColor, primaryColor],
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                language,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : primaryDarkColor,
                  fontFamily: 'cocon-next-arabic-regular',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: primaryDarkColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryDarkColor,
                          fontFamily: 'cocon-next-arabic-regular',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontFamily: 'cocon-next-arabic-regular',
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
