import 'dart:convert';
import 'dart:io' show Platform;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Login/auth_ui.dart';
import 'package:egpycopsversion4/Models/Countries.dart' show Country, countryFromJson;
import 'package:egpycopsversion4/Models/user.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Profile/completeRegistrationDataActivity.dart';
import 'package:egpycopsversion4/Utils/loader.dart' show Loader;
import 'package:egpycopsversion4/l10n/app_localizations.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

class RegisterActivityState extends State<RegisterActivity>
    with TickerProviderStateMixin {
  String mobileToken = "";

  // Contrôleurs
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
  String accountTypeID = "1"; // Force Personal

  @override
  void initState() {
    super.initState();

    // 🔹 Récupération du token Firebase
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null && mounted) setState(() => mobileToken = token);
    });

    _bootstrap();
  }

  /// 🔹 Charge les données initiales (UI Personal uniquement)
  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    myLanguage = prefs.getString('language') ?? "en";
    final t = AppLocalizations.of(context);

    // 🔹 On force l'affichage du type de compte Personal uniquement
    listDropAccountType
      ..clear()
      ..add({"id": "1", "name": t?.personal ?? "Personal"});
    accountTypeID = "1"; // Par défaut Personal

    // 🔹 Pays par défaut
    listDropCountries
      ..clear()
      ..add({
        "id": "0",
        "nameAr": "اختار دولتك",
        "nameEn": "Choose your Country",
        "isDefualt": false,
      });

    if (mounted) setState(() => _isReady = true);

    // 🔹 Charger les pays en arrière-plan
    _loadCountriesInBackground();
  }

  /// 🔹 Charge la liste des pays
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
        await prefs.setInt(
            _countriesCacheTsKey, DateTime.now().millisecondsSinceEpoch);
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
      Navigator.pop(context);
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

    final countryLabel = (myLanguage == 'ar') ? 'الدولة' : 'Country';

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
                            style: TextStyle(
                              color: Colors.black87, // Dark text for visibility on white card
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Account type (Personal uniquement)
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

                          // First name
                          AuthTextField(
                            controller: firstNameController,
                            hint: t?.firstNameWithAstric ?? 'First Name *',
                            icon: Icons.person_outline,
                            validator: (v) => (v == null || v.isEmpty)
                                ? (t?.pleaseEnterYourFirstName ??
                                    'Please enter your first name')
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Last name
                          AuthTextField(
                            controller: lastNameController,
                            hint: t?.lastNameWithAstric ?? 'Last Name *',
                            icon: Icons.badge_outlined,
                            validator: (v) => (v == null || v.isEmpty)
                                ? (t?.pleaseEnterYourLastName ??
                                    'Please enter your last name')
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Country dropdown
                          _AuthDropdown(
                            label: countryLabel,
                            value: countryID,
                            items: listDropCountries
                                .map((m) => DropdownMenuItem<String>(
                                      value: m['id'].toString(),
                                      child: Text(
                                        (myLanguage == 'ar'
                                                ? m['nameAr']
                                                : m['nameEn'])
                                            .toString(),
                                        textDirection: textDirection,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => countryID = v ?? "0"),
                          ),
                          const SizedBox(height: 16),

                          // Email
                          AuthTextField(
                            controller: emailController,
                            hint: t?.emailWithAstric ?? 'Email *',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => (v == null || v.isEmpty)
                                ? (t?.pleaseEnterYourEmail ??
                                    'Please enter your email')
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          AuthTextField(
                            controller: passwordController,
                            hint: t?.passwordWithAstric ?? 'Password *',
                            icon: Icons.lock_outline,
                            obscure: _obscure,
                            onToggleObscure: () =>
                                setState(() => _obscure = !_obscure),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return t?.pleaseEnterYourPassword ??
                                    'Please enter your password';
                              } else if (v.length < 8) {
                                return t?.passwordCannotBeLessThan8 ??
                                    'Password cannot be less than 8';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Register button
                          AuthButton(
                            text: t?.register ?? 'Register',
                            loading: _loadingBtn,
                            onPressed: _onRegisterPressed,
                          ),

                          const SizedBox(height: 24),
                          
                          // Back to login section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                myLanguage == 'ar' 
                                    ? 'هل لديك حساب بالفعل؟' 
                                    : 'Already have an account?',
                                style: TextStyle(
                                  color: Colors.black54, // Dark text for visibility
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: _goToLogin,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                ),
                                child: Text(
                                  t?.login ?? (myLanguage == 'ar' ? 'تسجيل الدخول' : 'Login'),
                                  style: TextStyle(
                                    color: Color(0xFF2196F3), // Consistent blue color
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
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

  /// ---------- Gère l'action Register ----------
  Future<void> _onRegisterPressed() async {
    final t = AppLocalizations.of(context);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (countryID == "0") {
      Fluttertoast.showToast(
        msg: myLanguage == 'ar' ? 'يرجى اختيار الدولة' : 'Please select a country',
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
  // ✅ Récupération du userID stocké
  final prefs = await SharedPreferences.getInstance();
  final userID = prefs.getString("userID") ?? "";

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => CompleteRegistrationDataPageActivity(
        title: 'Personal',
        userID: userID,
        email: email,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
      ),
    ),
    ModalRoute.withName("/CompleteData"),
  );
}

else if (response == "2") {
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
        Fluttertoast.showToast(
          msg: t?.errorConnectingWithServer ?? 'Error connecting with server',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.white,
          textColor: Colors.red,
          fontSize: 16.0,
        );
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

  Future<String> _register(
      String email, String password, String firstName, String lastName) async {
    final languageID = myLanguage == "en" ? "2" : "1";
    final deviceTypeID = Platform.isIOS ? "3" : "2";
    final accountID = "2"; // ✅ Force Personal
    final encodedPassword = Uri.encodeComponent(password);

    final url =
        '$baseUrl/Users/Register/?AccountTypeID=$accountID'
        '&Fname=$firstName&Lname=$lastName&Email=$email'
        '&password=$encodedPassword&token=$mobileToken'
        '&LanguageID=$languageID&DeviceTypeID=$deviceTypeID&countryID=$countryID';

    debugPrint("[REGISTER] URL envoyée: $url");

    try {
      final uri = Uri.parse(url);
      final response = await http.post(uri);
      debugPrint("[REGISTER] Status Code: ${response.statusCode}");
      debugPrint("[REGISTER] Réponse brute: ${response.body}");

      if (response.statusCode != 200) return response.body;

      final jsonResponse = json.decode(response.body.toString());
      debugPrint("[REGISTER] Réponse décodée: $jsonResponse");

      final loginData = User.fromJson(jsonResponse);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("userID", loginData.userID ?? "");
      await prefs.setString("email", loginData.email ?? "");
      await prefs.setString("loginUsername", loginData.loginUsername ?? "");
      await prefs.setString("name", loginData.name ?? "");
      await prefs.setBool("isValidate", loginData.isValidate ?? false);
      await prefs.setBool("isActiveted", loginData.isActiveted ?? false);
      await prefs.setString("accountType", loginData.accountType ?? "");
      await prefs.setBool("hasMainAccount", loginData.hasMainAccount ?? false);
      await prefs.setString("sucessCode", loginData.sucessCode ?? "");
     await prefs.setString("mobile", firstNameController.text.trim() + "_mobile");
await prefs.setString("address", ""); // ou un champ si tu l'ajoutes
      return loginData.sucessCode ?? "Error";
    } catch (e) {
      debugPrint('[REGISTER] ❌ Exception: $e');
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        style: TextStyle(
          color: Colors.black87, // Dark text for visibility
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Colors.white, // White dropdown background
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.black54,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white, // White background for the field
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.black54, // Dark label for visibility
            fontSize: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Color(0xFF2196F3), // Using a blue color since primaryColor import has issues
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }
}
