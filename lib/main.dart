import 'package:egpycopsversion4/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Profile/completeRegistrationDataActivity.dart';
import 'Login/login.dart';
import 'Login/needVerificationActivity.dart' hide CompleteRegistrationDataPageActivity;
import 'Language/language.dart';
import 'Home/homeActivity.dart';

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

    if (!prefs.containsKey('language')) {
      setState(() => _defaultHome = const LanguageActivity(fromHome: false));
      return;
    }

    final loggedIn = (prefs.getString('userID') ?? '').isNotEmpty;
    if (!loggedIn) {
      setState(() => _defaultHome = LoginActivity());
      return;
    }

    final hasMain = prefs.getBool('hasMainAccount') ?? false;
    final acctType = prefs.getString('accountType') ?? '';
    final validated = prefs.getBool('isValidate') ?? false;

    if (validated) {
     _defaultHome = hasMain
    ? HomeActivity(false)
    : CompleteRegistrationDataPageActivity(title: acctType)
; // ✅

    } else {
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
}
