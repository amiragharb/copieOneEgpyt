import 'package:egpycopsversion4/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Profile/completeRegistrationDataActivity.dart';
import 'Login/login.dart';
import 'Login/needVerificationActivity.dart' hide CompleteRegistrationDataPageActivity;
import 'Language/language.dart';
import 'Home/homeActivity.dart';
import 'API/apiClient.dart';

// Locale contrôlée par un ValueNotifier
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));
String? languageHome;

/// Change la langue à chaud et la persiste
Future<void> setAppLocale(String code) async {
  languageHome = code;
  localeNotifier.value = Locale(code);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('language', code);
}

Future<void> main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    debugPrint("❗️Caught error: ${details.exception}");
  };

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().catchError((_) {});

  final prefs = await SharedPreferences.getInstance();
  languageHome = prefs.getString('language');
  localeNotifier.value = Locale(languageHome ?? 'en');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _defaultHome = const LanguageActivity(fromHome: false);

  @override
  void initState() {
    super.initState();
    _decideStart();
  }

 Future<void> _decideStart() async {
  final prefs = await SharedPreferences.getInstance();

  // Si pas de langue → page sélection langue
  if (!prefs.containsKey('language')) {
    setState(() => _defaultHome = const LanguageActivity(fromHome: false));
    return;
  }

  final userID = prefs.getString('userID') ?? '';
  final email = prefs.getString('email') ?? '';
  final name = prefs.getString('name') ?? '';
  final hasMain = prefs.getBool('hasMainAccount') ?? false;
  final acctType = prefs.getString('accountType') ?? '';
  final validated = prefs.getBool('isValidate') ?? false;

  // Séparation prénom / nom
  final parts = name.split(' ');
  final firstName = parts.isNotEmpty ? parts.first : '';
  final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

  // 1️⃣ Si pas connecté → Login
  if (userID.isEmpty) {
    setState(() => _defaultHome = LoginActivity());
    return;
  }

  // 2️⃣ Si compte validé
  if (validated) {
    if (acctType == "2") {
      // ✅ Compte Personnel → Home direct
      _defaultHome = HomeActivity(false);
    } else {
      // ✅ Compte Famille - Check if user already has profile data
      if (!hasMain) {
        // Check if user already has profile data in API
        final bool hasExistingProfile = await _checkForExistingProfile(userID);
        if (hasExistingProfile) {
          // User has profile data, set the flag and go to home
          await prefs.setBool('hasMainAccount', true);
          _defaultHome = HomeActivity(false);
        } else {
          // User needs to complete registration
          _defaultHome = CompleteRegistrationDataPageActivity(
            title: acctType.isEmpty ? 'Family' : acctType,
            userID: userID,
            email: email,
            firstName: firstName,
            lastName: lastName,
          );
        }
      } else {
        _defaultHome = HomeActivity(false);
      }
    }
  } else {
    // 3️⃣ Compte non validé → Vérification email
    _defaultHome = const NeedVerificationActivity();
  }

  setState(() {});
}


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (_, loc, __) {
        return MaterialApp(
          title: 'EGY Copts',
          debugShowCheckedModeBanner: false,
          locale: loc,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          builder: (ctx, child) {
            return MediaQuery(
              data: MediaQuery.of(ctx).copyWith(
                textScaler: const TextScaler.linear(1.0),
                alwaysUse24HourFormat: false,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          theme: ThemeData(
            fontFamily: 'cocon-next-arabic-regular',
            brightness: Brightness.light,
          ),
          home: _defaultHome,
          routes: {
            '/home': (_) => HomeActivity(false),
            '/login': (_) => LoginActivity(),
            '/language': (_) => const LanguageActivity(fromHome: true),
          },
        );
      },
    );
  }

  /// Check if user already has profile data in the API
  Future<bool> _checkForExistingProfile(String userID) async {
    try {
      String baseUrl = BaseUrl().BASE_URL;
      final prefs = await SharedPreferences.getInstance();
      String? mobileToken = prefs.getString('mobileToken');
      
      // If no token, try to get it
      if (mobileToken == null || mobileToken.isEmpty) {
        return false; // Can't check without token
      }
      
      final url = '$baseUrl/Family/GetFamilyMembers/?UserID=$userID&Token=$mobileToken';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final List<dynamic> data = json.decode(response.body);
        // If we have any family member data, user has already completed registration
        return data.isNotEmpty;
      }
      return false;
    } catch (e) {
      print('Error checking existing profile: $e');
      return false;
    }
  }
}
