import 'dart:convert';
import 'dart:io' show Platform;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Login/auth_ui.dart';
import 'package:egpycopsversion4/Models/Countries.dart' show Country, countryFromJson;
import 'package:egpycopsversion4/Models/user.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Profile/completeRegistrationDataActivity.dart';
import 'package:egpycopsversion4/Translation/localizations.dart' hide AppLocalizations;
import 'package:egpycopsversion4/Utils/loader.dart' show Loader;
import 'package:egpycopsversion4/l10n/app_localizations.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Pour pouvoir revenir/aller au login
import 'package:egpycopsversion4/Login/login.dart' as lg;

import 'needVerificationActivity.dart' hide CompleteRegistrationDataPageActivity;

/// ---------- Etat global minimal ----------
String myLanguage = "en";
final BaseUrl _BASE_URL = BaseUrl();
final String baseUrl = _BASE_URL.BASE_URL;

/// ---------- Cache pays ----------
const _countriesCacheKey = 'countries_json_v1';
const _countriesCacheTsKey = 'countries_json_ts_v1';
const _countriesTTL = Duration(hours: 24);

class RegisterActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RegisterActivityState();
}

class RegisterActivityState extends State<RegisterActivity> with TickerProviderStateMixin {
  String mobileToken = "";

  // Contrôleurs
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController  = TextEditingController();
  final TextEditingController emailController     = TextEditingController();
  final TextEditingController passwordController  = TextEditingController();

  // Form / état UI
  final _formKey = GlobalKey<FormState>();
  bool _loadingBtn = false;
  bool _obscure = true;
  bool _isReady = false;

  // Dropdowns
  List<Country> countriesList = [];
  final List<Map<String, dynamic>> listDropCountries = [];
  final List<Map<String, dynamic>> listDropAccountType = [];
  String countryID = "0";
  String accountTypeID = "1"; // Fixe: "Personal"

  @override
  void initState() {
    super.initState();

    // FCM token
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null && mounted) setState(() => mobileToken = token);
    });

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    myLanguage = prefs.getString('language') ?? "en";

    final t = AppLocalizations.of(context);
    listDropAccountType
      ..clear()
      ..add({"id": "1", "name": t?.personal ?? "Personal"});
    accountTypeID = "1"; // Valeur sélectionnée par défaut

    // Ajoute l’option par défaut pour les pays (UI immédiate)
    listDropCountries
      ..clear()
      ..add({
        "id": "0",
        "nameAr": "اختار دولتك",
        "nameEn": "Choose your Country",
        "isDefualt": false,
      });

    if (mounted) setState(() => _isReady = true);

    // Charge les pays (cache + réseau) en arrière-plan
    _loadCountriesInBackground();
  }

  Future<void> _loadCountriesInBackground() async {
    final prefs = await SharedPreferences.getInstance();

    // 1) Cache
    try {
      final ts = prefs.getInt(_countriesCacheTsKey) ?? 0;
      final cached = prefs.getString(_countriesCacheKey);
      if (cached != null &&
          DateTime.now()
                  .difference(DateTime.fromMillisecondsSinceEpoch(ts)) <
              _countriesTTL) {
        final list = countryFromJson(cached);
        _populateCountries(list);
      }
    } catch (_) {}

    // 2) Réseau
    try {
      final resp = await http.get(Uri.parse('$baseUrl/Booking/GetCountries/'));
      if (resp.statusCode == 200) {
        await prefs.setString(_countriesCacheKey, resp.body);
        await prefs.setInt(_countriesCacheTsKey, DateTime.now().millisecondsSinceEpoch);
        final list = countryFromJson(resp.body);
        _populateCountries(list);
      }
    } catch (_) {}
  }

  void _populateCountries(List<Country> list) {
    if (!mounted) return;
    setState(() {
      countriesList = list;
      // Conserve l’entrée par défaut et remplace le reste
      listDropCountries.removeWhere((m) => m['id'].toString() != '0');
      for (final c in list) {
        listDropCountries.add({
          "id": c.id,
          "nameAr": c.nameAr,
          "nameEn": c.nameEn,
          "isDefualt": c.isDefualt,
        });
        if (c.isDefualt == true) countryID = c.id.toString();
      }
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ---- Naviguer vers le Login ----
  void _goToLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // si on vient du login
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => lg.LoginActivity()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    myLanguage = t?.localeName ?? Localizations.localeOf(context).languageCode;

    final countryLabel =
        (myLanguage == 'ar') ? 'الدولة' : 'Country';
    final pleaseSelectCountryMsg =
        (myLanguage == 'ar') ? 'يرجى اختيار الدولة' : 'Please select a country';

    final textDirection =
        myLanguage == 'ar' ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        body: AuthScaffold(
          backgroundColor: Colors.white,
          child: !_isReady
              ? Center(child: Loader())
              : GlassCard(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t?.createNewAccount ?? 'Create new account',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Account type
                          _AuthDropdown(
                            label: t?.accountTypeWithAstric ?? 'Account Type *',
                            value: accountTypeID,
                            items: listDropAccountType
                                .map((m) => DropdownMenuItem<String>(
                                      value: m['id'].toString(),
                                      child: Text(m['name'].toString()),
                                    ))
                                .toList(),
                            onChanged: (_) {}, // Non modifiable
                          ),
                          const SizedBox(height: 16),

                          // First / Last name
                          AuthTextField(
                            controller: firstNameController,
                            hint: t?.firstNameWithAstric ?? 'First Name *',
                            icon: Icons.person_outline,
                            validator: (v) => (v == null || v.isEmpty)
                                ? (t?.pleaseEnterYourFirstName ?? 'Please enter your first name')
                                : null,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: lastNameController,
                            hint: t?.lastNameWithAstric ?? 'Last Name *',
                            icon: Icons.badge_outlined,
                            validator: (v) => (v == null || v.isEmpty)
                                ? (t?.pleaseEnterYourLastName ?? 'Please enter your last name')
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Country (UI affichée même si API échoue)
                          _AuthDropdown(
                            label: countryLabel,
                            value: countryID,
                            items: listDropCountries
                                .map((m) => DropdownMenuItem<String>(
                                      value: m['id'].toString(),
                                      child: Text(
                                        (myLanguage == 'ar' ? m['nameAr'] : m['nameEn']).toString(),
                                        textDirection: textDirection,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => countryID = v ?? "0"),
                          ),
                          const SizedBox(height: 16),

                          // Email / Password
                          AuthTextField(
                            controller: emailController,
                            hint: t?.emailWithAstric ?? 'Email *',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => (v == null || v.isEmpty)
                                ? (t?.pleaseEnterYourEmail ?? 'Please enter your email')
                                : null,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: passwordController,
                            hint: t?.passwordWithAstric ?? 'Password *',
                            icon: Icons.lock_outline,
                            obscure: _obscure,
                            onToggleObscure: () => setState(() => _obscure = !_obscure),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return t?.pleaseEnterYourPassword ?? 'Please enter your password';
                              } else if (v.length < 8) {
                                return t?.passwordCannotBeLessThan8 ?? 'Password cannot be less than 8';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Register button
                          AuthButton(
                            text: t?.register ?? 'Register',
                            loading: _loadingBtn,
                            onPressed: () async {
                              if (!(_formKey.currentState?.validate() ?? false)) return;

                              if (countryID == "0") {
                                Fluttertoast.showToast(
                                  msg: pleaseSelectCountryMsg,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.white,
                                  textColor: Colors.red,
                                  fontSize: 16.0,
                                );
                                return;
                              }

                              final net = await _checkInternetConnection();
                              if (net != '1') {
                                if (!mounted) return;
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => NoInternetConnectionActivity()),
                                );
                                return;
                              }

                              setState(() => _loadingBtn = true);

                              final email = emailController.text.trim();
                              final checkEmailResponse = await _checkEmail(email);
                              if (checkEmailResponse == "0") {
                                final response = await _register(
                                  email,
                                  passwordController.text,
                                  firstNameController.text.trim(),
                                  lastNameController.text.trim(),
                                );

                                setState(() => _loadingBtn = false);
                                if (!mounted) return;

                                if (response == '1') {
                                  // On navigue TOUJOURS vers la complétion d'inscription
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                  MaterialPageRoute(
  builder: (_) => const CompleteRegistrationDataPageActivity(title: 'Personal'),
),


                                    ModalRoute.withName("/CompleteData"),
                                  );
                                } else if (response == "2") {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (_) => NeedVerificationActivity()),
                                    ModalRoute.withName("/NeedVerification"),
                                  );
                                  Fluttertoast.showToast(
                                    msg: t?.accountCreatedSuccessfully ?? 'Account created successfully.',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.white,
                                    textColor: Colors.green,
                                    fontSize: 16.0,
                                  );
                                } else {
                                  if (response == "\"Duplicate email\"") {
                                    Fluttertoast.showToast(
                                      msg: t?.sorryThisEmailIsUsedBefore ?? 'This email is already used.',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.white,
                                      textColor: Colors.red,
                                      fontSize: 16.0,
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: t?.errorConnectingWithServer ?? 'Error connecting with server',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.white,
                                      textColor: Colors.red,
                                      fontSize: 16.0,
                                    );
                                  }
                                }
                              } else {
                                setState(() => _loadingBtn = false);
                                Fluttertoast.showToast(
                                  msg: t?.sorryThisEmailIsUsedBefore ?? 'This email is already used.',
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.white,
                                  textColor: Colors.red,
                                  fontSize: 16.0,
                                );
                              }
                            },
                          ),

                          // ---- Lien vers le Login ----
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                t?.donNotHaveAccount ?? 'Don’t have an account?',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),

                          TextButton(
                            onPressed: _goToLogin,
                            child: Text(
                              t?.login ?? 'Login',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
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
    );
  }

  /// ---------- API helpers ----------
  Future<String> _checkEmail(String email) async {
    try {
      final resp = await http.get(Uri.parse('$baseUrl/Users/CheckEmail/?Email=$email'));
      if (resp.statusCode == 200) {
        return (resp.body.toString() == "\"1\"") ? "1" : "0";
      }
    } catch (_) {}
    return "0";
  }

  Future<String> _register(String email, String password, String firstName, String lastName) async {
    final languageID = myLanguage == "en" ? "2" : "1";
    final deviceTypeID = Platform.isIOS ? "3" : "2";
    final accountID = "2"; // Fixe: Personal = 2
    final encodedPassword = Uri.encodeComponent(password);

    final uri = Uri.parse(
      '$baseUrl/Users/Register/?AccountTypeID=$accountID'
      '&Fname=$firstName&Lname=$lastName&Email=$email'
      '&password=$encodedPassword&token=$mobileToken'
      '&LanguageID=$languageID&DeviceTypeID=$deviceTypeID&countryID=$countryID',
    );

    try {
      final response = await http.post(uri);
      if (response.statusCode != 200) return response.body;

      final jsonResponse = json.decode(response.body.toString());
      final loginData = User.fromJson(jsonResponse);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("password",      password);
      await prefs.setString("userID",        loginData.userID ?? "");
      await prefs.setString("loginUsername", loginData.loginUsername ?? "");
      await prefs.setString("name",          loginData.name ?? "");
      await prefs.setBool  ("isValidate",    loginData.isValidate ?? false);
      await prefs.setBool  ("isActiveted",   loginData.isActiveted ?? false);
      await prefs.setString("accountType",   loginData.accountType ?? "");
      await prefs.setString("email",         loginData.email ?? "");
      await prefs.setString("address",       loginData.address ?? "");
      await prefs.setBool  ("hasMainAccount",loginData.hasMainAccount ?? false);
      await prefs.setString("sucessCode",    loginData.sucessCode ?? "");
      await prefs.setInt   ("governateID",   loginData.governateID ?? 0);
      await prefs.setInt   ("branchID",      loginData.branchID ?? 0);

      return loginData.sucessCode ?? "Error";
    } catch (e) {
      if (kDebugMode) debugPrint('[REGISTER] exception: $e');
      return 'Error';
    }
  }

  Future<String> _checkInternetConnection() async {
    final r = await Connectivity().checkConnectivity();
    return r == ConnectivityResult.none ? "0" : "1";
  }
}

/// ---------- Dropdown stylé ----------
class _AuthDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _AuthDropdown({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      dropdownColor: const Color(0xFF203A43),
      decoration: InputDecoration(
        filled: true,
        fillColor: AuthColors.fieldFill,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Colors.white),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
