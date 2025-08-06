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

      customControllerDrawerName.drawerNameController.text = userName;
      customControllerDrawerEmail.drawerEmailController.text = userEmail;
    });
  }

  Drawer buildDrawer() {
    return Drawer(
      child: Column(
        children: <Widget>[
          // Header section
          Container(
            color: primaryColor,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Image.asset('images/logotransparents.png', fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // User name
                    MyCustomDrawerName(customController: customControllerDrawerName),
                    const SizedBox(height: 5),
                    // User email
                    MyCustomDrawerEmail(customController: customControllerDrawerEmail),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          
          // Menu items section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                // Language selection section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.language ?? "Language",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          fontFamily: 'cocon-next-arabic-regular',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[300]!, width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _changeLanguage('en'),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                      gradient: _appLocale.languageCode == 'en'
                                          ? LinearGradient(
                                              colors: [primaryColor, primaryColor.withOpacity(0.8)],
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "🇺🇸",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "English",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _appLocale.languageCode == 'en'
                                                ? Colors.white
                                                : Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _changeLanguage('ar'),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                      gradient: _appLocale.languageCode == 'ar'
                                          ? LinearGradient(
                                              colors: [primaryColor, primaryColor.withOpacity(0.8)],
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "🇪🇬",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "العربية",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _appLocale.languageCode == 'ar'
                                                ? Colors.white
                                                : Colors.grey[700],
                                            fontFamily: 'cocon-next-arabic-regular',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                Divider(color: Colors.grey[300], thickness: 1),
                const SizedBox(height: 10),
                
                // Logout button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _logout,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.red[400]!,
                              Colors.red[500]!,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 15),
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
                              Icons.arrow_forward_ios,
                              color: Colors.white.withOpacity(0.7),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
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
      userName.isNotEmpty ? userName : "User",
      style: const TextStyle(
        fontSize: 18.0,
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontFamily: 'cocon-next-arabic-regular',
      ),
      textAlign: TextAlign.center,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        userEmail.isNotEmpty ? userEmail : "user@example.com",
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14.0,
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontFamily: 'cocon-next-arabic-regular',
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
