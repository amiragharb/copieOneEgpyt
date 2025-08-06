import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Home/homeActivity.dart';
import 'package:egpycopsversion4/Login/auth_ui.dart';
import 'package:egpycopsversion4/Models/churchs.dart';
import 'package:egpycopsversion4/Models/governorates.dart';
import 'package:egpycopsversion4/Models/personRelation.dart';
import 'package:egpycopsversion4/l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:egpycopsversion4/l10n/app_localizations.dart';

// Base URL API
String baseUrl = BaseUrl().BASE_URL;

class CompleteRegistrationDataPageActivity extends StatefulWidget {
  final String title;
  final String userID;
  final String email;
  final String firstName;
  final String lastName;

  const CompleteRegistrationDataPageActivity({
    Key? key,
    required this.title,
    required this.userID,
    required this.email,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  @override
  State<CompleteRegistrationDataPageActivity> createState() =>
      _CompleteRegistrationDataPageActivityState();
}




class _CompleteRegistrationDataPageActivityState
    extends State<CompleteRegistrationDataPageActivity>
    with TickerProviderStateMixin 
 {
  // 🔹 Variables d’état
  String errorMessage = "";
  String relationshipID = "0";
  String churchOfAttendanceID = "0";
  String governorateID = "0";
  String userID = "";
  String myLanguage = "en";
  String mobileToken = "";
  bool isFamilyAccount = false;
  int registerState = 0;
  int selectedGenderRadioTile = 0;
  int selectedDeaconRadioTile = 0;
  bool showDeaconRadioButtonState = false;
  bool deaconState = true;
  bool showGenderState = false;
  bool showRelationShipState = false;
  bool showChurchOfAttendanceState = false;
  bool showChurchOfAttendanceOthersState = false;
  bool governorateState = true;
  bool churchState = true;
  // 🔹 Variables liées à l'API
String userAccountID = "";          // ID utilisateur connecté
String branchID = "";               // ID de la branche, à récupérer ou laisser vide
bool isEditMode = false;            // true si modification, false si ajout
String existingAccountMemberID = ""; // rempli uniquement en mode édition

  bool relationshipState = true;

  List<Map<String, dynamic>> listDropRelationship = [];
  Color primaryDarkColor = Colors.blue;
  Color red700 = Colors.red[700]!;
  // 🔹 Listes de données
  List<Churchs> churchOfAttendanceList = [];
  List<Governorates> governoratesList = [];
  List<Map<String, dynamic>> listDropGender = [];
  List<Map<String, dynamic>> listDropChurchOfAttendance = [];
  List<Map<String, dynamic>> listDropGovernorates = [];
  List<PersonRelation> relationshipList = [];

  // 🔹 Controllers personnalisés
  final MyCustomControllerFullName customControllerFullName =
      MyCustomControllerFullName(fullNameController: TextEditingController());
  final MyCustomControllerID customControllerID =
      MyCustomControllerID(iDController: TextEditingController());
  final MyCustomControllerAddress customControllerAddress =
      MyCustomControllerAddress(addressController: TextEditingController());
  final MyCustomControllerChurchOfAttendance customControllerChurchOfAttendance =
      MyCustomControllerChurchOfAttendance(
          churchOfAttendanceController: TextEditingController());
  final MyCustomControllerMobile customControllerMobile =
      MyCustomControllerMobile(mobileController: TextEditingController());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

@override
void initState() {
  super.initState();

  isFamilyAccount = false;
  showRelationShipState = false;
  showDeaconRadioButtonState = false;

  userID = widget.userID;
  customControllerFullName.fullNameController.text =
      "${widget.firstName} ${widget.lastName}";

  // ❌ Ne jamais remplir avec userID
  // customControllerID.iDController.text = widget.userID;

  _init();
}



/// 🔹 Initialisation complète et rafraîchissement de l'écran
Future<void> _init() async {
  final prefs = await SharedPreferences.getInstance();

  myLanguage = prefs.getString('language') ?? "en";

  debugPrint("🔹 FullName pré-rempli: ${customControllerFullName.fullNameController.text}");

  // Token Firebase
  FirebaseMessaging.instance.getToken().then((String? token) {
    if (token != null && mounted) {
      setState(() => mobileToken = token);
      debugPrint("🔹 FCM Token récupéré: $token");
    }
  });

  // ✅ UI Personal uniquement
  setState(() {
    showRelationShipState = false;
    showDeaconRadioButtonState = false;
    showGenderState = true;
    governorateState = true;
    churchState = true;
  });

  // ✅ Charge juste les données supplémentaires nécessaires
  await getDataFromShared();
  await getGovernorates();

  debugPrint("✅ Initialisation terminée (FullName + NationalID) !");
}


/// 🔹 Fonction pour forcer le rafraîchissement des champs
void _refreshFields() {
  setState(() {
    userID = widget.userID;
    customControllerFullName.fullNameController.text =
        "${widget.firstName} ${widget.lastName}";

    // ❌ Supprime cette ligne :
    // customControllerID.iDController.text = widget.userID;

    // ✅ Laisse vide pour saisie manuelle
    // ou tu peux le remplir seulement si l’utilisateur l’a déjà saisi
    if (customControllerID.iDController.text.isEmpty) {
      customControllerID.iDController.text = "";
    }

    showRelationShipState = false;
    showDeaconRadioButtonState = false;
    showGenderState = true;
    governorateState = true;
    churchState = true;
  });

  debugPrint("🔄 FullName rafraîchi, NationalID laissé vide !");
}


/// 🔹 Relationship masqué pour Personal



/// 🔹 Relationship masqué pour Personal
Widget showRelationshipLayout(BuildContext context) {
  return const SizedBox.shrink(); // Jamais affiché
}

  Future<void> getDataFromShared() async {
    final prefs = await SharedPreferences.getInstance();
    myLanguage = prefs.getString('language') ?? "en";
    final accountType = prefs.getString("accountType");
    isFamilyAccount = accountType == "1";
    relationshipList = await getRelationships();
    await relationShipDropDownData();
  }

  Future<List<PersonRelation>> getRelationships() async {
    final uri = Uri.parse('$baseUrl/Family/GetPersonRelations/');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return personRelationFromJson(response.body.toString());
    } else {
      print("GetPersonRelations error: ${response.statusCode}");
      return [];
    }
  }

  Future<List<Governorates>> getGovernorates() async {
    final uri = Uri.parse('$baseUrl/Booking/GetGovernorates/');
    print('Requesting governorates from: $uri');
    
    final response = await http.get(uri);
    print('Governorates response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('Governorates response body: ${response.body}');
      governoratesList = governoratesFromJson(response.body.toString());
      print('Parsed ${governoratesList.length} governorates');
      await governorateDropDownData();
      return governoratesList;
    } else {
      print("GetGovernorates error: ${response.statusCode}");
      return [];
    }
  }

  Future<void> governorateDropDownData() async {
    listDropGovernorates.clear();
    print('Creating governorate dropdown with ${governoratesList.length} items');
    
    setState(() {
      listDropGovernorates.add({
        "id": "0",
        "nameAr": "اختر المحافظة",
        "nameEn": "Choose Governorate",
      });
      for (var gov in governoratesList) {
        listDropGovernorates.add({
          "id": gov.id,
          "nameAr": gov.nameAr,
          "nameEn": gov.nameEn,
        });
      }
    });
    
    print('Governorate dropdown created with ${listDropGovernorates.length} items');
  }

  Future<void> relationShipDropDownData() async {
    listDropRelationship.clear();
    setState(() {
      listDropRelationship.add({
        "id": "0",
        "genderTypeID": 0,
        "nameAr":
            AppLocalizations.of(context)?.chooseRelationship ?? "اختر صلة القرابة",
        "nameEn":
            AppLocalizations.of(context)?.chooseRelationship ?? "Choose relationship",
      });
      for (var rel in relationshipList) {
        listDropRelationship.add({
          "id": rel.id,
          "genderTypeID": rel.genderTypeID,
          "nameAr": rel.nameAr,
          "nameEn": rel.nameEn,
        });
      }
    });
  }

  /// 🔹 Build principal
  @override
Widget build(BuildContext context) {
  return AuthScaffold(
    backgroundColor: Colors.white,
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ---------- SECTION 1 : Personal Info ----------
            _buildSectionHeader(
              AppLocalizations.of(context)?.personalInformation ?? "Personal Information",
              Icons.person_outline,
            ),
            const SizedBox(height: 16),

            GlassCard(
              child: Column(
                children: [
                  MyCustomTextFieldFullName(customController: customControllerFullName),
                  const SizedBox(height: 20),
                  MyCustomTextFieldID(customController: customControllerID),
                  const SizedBox(height: 20),
                  MyCustomTextFieldMobile(customController: customControllerMobile),
                  const SizedBox(height: 20),
                  MyCustomTextFieldAddress(customController: customControllerAddress),
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// ---------- SECTION 2 : Additional Info ----------
            _buildSectionHeader(
              AppLocalizations.of(context)?.additionalInformation ?? "Additional Information",
              Icons.info_outline,
            ),
            const SizedBox(height: 16),

            GlassCard(
              child: Column(
                children: [
                  showGenderLayout(),
                  const SizedBox(height: 20),
                  showRelationshipLayout(context),
                  const SizedBox(height: 20),
                  showDeaconCheckboxLayout(),
                ],
              ),
            ),

            const SizedBox(height: 32),

            /// ---------- SECTION 3 : Location Info ----------
            _buildSectionHeader(
              AppLocalizations.of(context)?.locationInformation ?? "Location Information",
              Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),

            GlassCard(
              child: Column(
                children: [
                  showGovernoratesLayout(context),
                  const SizedBox(height: 20),
                  showChurchOfAttendanceLayout(),
                  const SizedBox(height: 10),
                  showChurchOfAttendanceOthers(),
                ],
              ),
            ),

            const SizedBox(height: 36),

            /// ---------- REGISTER BUTTON ----------
            AuthButton(
              text: AppLocalizations.of(context)?.save ?? "Save",
              loading: registerState == 1,
              onPressed: () => _handleRegistration(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}

/// ---------- Header des sections ----------
Widget _buildSectionHeader(String title, IconData icon) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryDarkColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primaryDarkColor, size: 20),
      ),
      const SizedBox(width: 12),
      Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
              color: Colors.white, // ✅ Couleur blanche

        ),
      ),
    ],
  );
}

  

  
  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// 🔹 Dropdown Relationship1
 
  /// 🔹 Deacon Radio Buttons
  Widget showDeaconCheckboxLayout() {
    if (!showDeaconRadioButtonState) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.deaconWithAstric,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Row(
            children: [
              Expanded(
                child: RadioListTile(
                  value: 1,
                  groupValue: selectedDeaconRadioTile,
                  title: Text(
                    AppLocalizations.of(context)!.yes,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  onChanged: (val) => setSelectedDeaconRadioTile(val ?? 0),
                  activeColor: primaryDarkColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              Expanded(
                child: RadioListTile(
                  value: 2,
                  groupValue: selectedDeaconRadioTile,
                  title: Text(
                    AppLocalizations.of(context)!.no,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  onChanged: (val) => setSelectedDeaconRadioTile(val ?? 0),
                  activeColor: primaryDarkColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
        ),
        if (!deaconState)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              AppLocalizations.of(context)!.pleaseChooseDeacon,
              style: TextStyle(fontSize: 12.0, color: red700),
            ),
          ),
      ],
    );
  }

  /// 🔹 Bouton Enregistrement
  Widget buildRegisterButtonWidget() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDarkColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        onPressed: () {
                    _handleRegistration();
        },
        child: registerState == 1
            ? const SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.save_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)?.save ?? "Save",
                    style: const TextStyle(
                      fontSize: 18.0, 
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void setSelectedDeaconRadioTile(int value) {
    setState(() => selectedDeaconRadioTile = value);
  }

  /// 🔹 Handle Registration Process
  Future<void> _handleRegistration() async {
  setState(() {
    errorMessage = "";
  });

  // 🔹 Validate form fields
  if (!_validateForm()) {
    return; // ⛔ Stop si le formulaire est invalide
  }

  // 🔹 Préparer les données
  final registrationData = _prepareRegistrationData();
  if (registrationData == null) {
    // ⛔ Stop si le NationalID est invalide
    return;
  }

  setState(() {
    registerState = 1; // Loading
  });

  try {
    await _submitRegistration(registrationData);
  } catch (e) {
    setState(() {
      errorMessage = "Registration failed: ${e.toString()}";
      registerState = 0;
    });
    _showErrorDialog(errorMessage);
  }
}
/// 🔹 Validate all form fields
bool _validateForm() {
  bool isValid = true;

  // Validate Name
  if (customControllerFullName.fullNameController.text.trim().isEmpty) {
    Fluttertoast.showToast(
      msg: myLanguage == "ar"
          ? "الرجاء إدخال الاسم بالكامل"
          : "Please enter your full name",
    );
    isValid = false;
  }
// Validation robuste pour National ID : exactement 14 chiffres

  final nationalID = customControllerID.iDController.text.trim();
if (!isNationalIDValid(nationalID)) {
  Fluttertoast.showToast(
    msg: myLanguage == "ar"
        ? "الرجاء إدخال رقم قومي صحيح"
        : "Please enter a valid National ID",
  );
  isValid = false;
}



  // Validate Mobile
  if (customControllerMobile.mobileController.text.trim().isEmpty) {
    Fluttertoast.showToast(
      msg: myLanguage == "ar"
          ? "الرجاء إدخال رقم الهاتف"
          : "Please enter your mobile number",
    );
    isValid = false;
  }

  // Validate Gender
  if (selectedGenderRadioTile == 0) {
    Fluttertoast.showToast(
      msg: myLanguage == "ar"
          ? "الرجاء اختيار النوع"
          : "Please select gender",
    );
    isValid = false;
  }

  // Validate Governorate
  if (governorateID == "0") {
    Fluttertoast.showToast(
      msg: myLanguage == "ar"
          ? "الرجاء اختيار المحافظة"
          : "Please select a governorate",
    );
    isValid = false;
  }

  // Validate Church
  if (churchOfAttendanceID == "0") {
    Fluttertoast.showToast(
      msg: myLanguage == "ar"
          ? "الرجاء اختيار الكنيسة"
          : "Please select a church",
    );
    isValid = false;
  }

  // Validate Address
  if (customControllerAddress.addressController.text.trim().isEmpty) {
    Fluttertoast.showToast(
      msg: myLanguage == "ar"
          ? "الرجاء إدخال العنوان"
          : "Please enter your address",
    );
    isValid = false;
  }

  return isValid;
}


  /// 🔹 Prepare registration data for API call
  Map<String, dynamic>? _prepareRegistrationData() {
  final nationalID = customControllerID.iDController.text.trim();

if (!isNationalIDValid(nationalID)) {
  Fluttertoast.showToast(
    msg: myLanguage == "ar"
        ? "الرجاء إدخال رقم قومي صحيح"
        : "Please enter a valid National ID",
  );
  return null;
}


  return {
    "Name": customControllerFullName.fullNameController.text.trim(),
    "relationID": isFamilyAccount ? relationshipID : "0",
    "Deacon": showDeaconRadioButtonState && selectedDeaconRadioTile == 1,
    "NationalID": nationalID,
    "Mobile": customControllerMobile.mobileController.text.trim(),
    "UserAccountID": widget.userID,  
    "GenderID": selectedGenderRadioTile.toString(),
    "Ismain": isFamilyAccount ? "1" : "0",
    "churchOfAttendance":
        churchOfAttendanceID == "-1" ? "" : churchOfAttendanceID,
    "Address": customControllerAddress.addressController.text.trim(),
    "BranchID": branchID,
    "GovernerateID": governorateID,
    "flag": isEditMode ? "2" : "1",
    "AccountMemberID": isEditMode ? existingAccountMemberID : "",
    "Token": mobileToken,
  };
}





  /// 🔹 Submit registration to API
  /// 🔹 Envoie des données d’enregistrement à l’API
Future<void> _submitRegistration(Map<String, dynamic> data) async {
  try {
    // 🔹 Flag : 1 = Add, 2 = Edit
    data["flag"] = isEditMode ? "2" : "1";
    data["AccountMemberID"] = isEditMode ? existingAccountMemberID : "";

    // Créer l'URI avec les paramètres GET (query)
    final uri = Uri.parse('$baseUrl/Family/AddEditFamilyMember')
        .replace(queryParameters: data.map((k, v) => MapEntry(k, v.toString())));

    debugPrint('📤 Submitting registration to: $uri');

    final response = await http.post(uri);

    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    setState(() => registerState = 0);

    if (response.statusCode == 200) {
      // ✅ 1️⃣ Rafraîchir les champs après un ajout réussi
      debugPrint("✅ Ajout réussi, rafraîchissement des champs...");
      _refreshFields();

      // ✅ 2️⃣ Afficher un toast de succès
      Fluttertoast.showToast(
        msg: "Registration completed successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        textColor: Colors.green,
        fontSize: 16.0,
      );

      // ✅ 3️⃣ Naviguer vers la HomePage et vider la pile
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeActivity(false)),
        ModalRoute.withName('/Home'),
      );
    } else {
      throw Exception('Server returned status ${response.statusCode}');
    }
  } catch (e) {
    setState(() => registerState = 0);
    debugPrint('❌ Error in _submitRegistration: $e');

    Fluttertoast.showToast(
      msg: "Error submitting registration. Please try again.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.white,
      textColor: Colors.red,
      fontSize: 16.0,
    );
  }
}


  /// 🔹 Show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Text(
                "Success",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            "Registration completed successfully!",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDarkColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: Text(
                "OK",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 🔹 Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Text(
                "Error",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDarkColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "OK",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 🔹 Gender Radio Buttons
  Widget showGenderLayout() {
    if (!showGenderState) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.genderWithAstric ?? "Gender *",
          style: const TextStyle(
            fontSize: 16.0, 
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Row(
            children: [
              Expanded(
                child: RadioListTile(
                  value: 1,
                  groupValue: selectedGenderRadioTile,
                  title: Text(
                    AppLocalizations.of(context)?.male ?? "Male",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  onChanged: (val) => setState(() => selectedGenderRadioTile = val ?? 0),
                  activeColor: primaryDarkColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              Expanded(
                child: RadioListTile(
                  value: 2,
                  groupValue: selectedGenderRadioTile,
                  title: Text(
                    AppLocalizations.of(context)?.female ?? "Female",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  onChanged: (val) => setState(() => selectedGenderRadioTile = val ?? 0),
                  activeColor: primaryDarkColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget showGovernoratesLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalizations.of(context)!.governorate,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        if (listDropGovernorates.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: DropdownButton(
              value: governorateID,
              isExpanded: true,
              underline: Container(),
              icon: Icon(Icons.keyboard_arrow_down, color: primaryDarkColor),
              items: listDropGovernorates.map((Map map) {
                return DropdownMenuItem<String>(
                  value: map["id"].toString(),
                  child: Text(
                    myLanguage == "ar" ? map["nameAr"] : map["nameEn"],
                    style: TextStyle(
                      color: primaryDarkColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  governorateID = value!;
                  showChurchOfAttendanceState = false;
                  showChurchOfAttendanceOthersState = false;
                  churchOfAttendanceID = "0";
                  if (value != "0") {
                    getChurchWithGovernorate();
                  }
                  print("governorateID : $governorateID");
                });
              },
            ),
          ),
        if (listDropGovernorates.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryDarkColor),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Loading governorates...",
                  style: TextStyle(
                    color: primaryDarkColor,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        if (!governorateState)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              AppLocalizations.of(context)!.pleaseChooseGovernorate,
              style: TextStyle(
                fontSize: 12.0,
                color: red700,
              ),
            ),
          ),
      ],
    );
  }

  getChurchWithGovernorate() async {
    churchOfAttendanceList = await getChurchs(governorateID);
    await churchOfAttendanceDropDownData();
  }
  
Future<List<Churchs>> getChurchs(String governorateID) async {
  final uri = Uri.parse('$baseUrl/Booking/GetAllChurches/?GovernerateID=$governorateID');
  print('Request: $uri');

  final response = await http.get(uri);
  if (response.statusCode == 200) {
    print('Response: ${response.body}');
    return churchsFromJson(response.body.toString());
  } else {
    print('GetChurch error: ${response.statusCode}');
    return [];
  }
}
Future<void> churchOfAttendanceDropDownData() async {
  listDropChurchOfAttendance.clear();
  print('Creating church dropdown with ${churchOfAttendanceList.length} churches');

  if (churchOfAttendanceList.isNotEmpty) {
    setState(() {
      // Première option : choisir une église
      listDropChurchOfAttendance.add({
        "id": "0",
        "nameAr": "اختار كنيستك",
        "nameEn": "Choose your Church",
        "isDefualt": false
      });

      // Ajouter toutes les églises récupérées
      for (var church in churchOfAttendanceList) {
        listDropChurchOfAttendance.add({
          "id": church.id,
          "nameAr": church.nameAr,
          "nameEn": church.nameEn,
          "isDefualt": church.isDefualt
        });
      }

      // Dernière option : Autre
      listDropChurchOfAttendance.add({
        "id": "-1",
        "nameAr": "أخرى",
        "nameEn": "Others",
        "isDefualt": false
      });

      showChurchOfAttendanceState = true;
    });
    
    print('Church dropdown created with ${listDropChurchOfAttendance.length} items');
  } else {
    print('No churches found, not showing church dropdown');
  }
}

  Widget showChurchOfAttendanceLayout() {
    if (!showChurchOfAttendanceState) {
      return Container(); // Don't show until a governorate is selected
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalizations.of(context)!.churchOfAttendanceWithAstric,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        if (listDropChurchOfAttendance.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: DropdownButton(
              value: churchOfAttendanceID,
              isExpanded: true,
              underline: Container(),
              icon: Icon(Icons.keyboard_arrow_down, color: primaryDarkColor),
              items: listDropChurchOfAttendance.map((Map map) {
                return DropdownMenuItem<String>(
                  value: map["id"].toString(),
                  child: Text(
                    myLanguage == "ar" ? map["nameAr"] : map["nameEn"],
                    style: TextStyle(
                      color: primaryDarkColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  churchOfAttendanceID = value!;
                  if (churchOfAttendanceID == "-1") {
                    showChurchOfAttendanceOthersState = true;
                  } else {
                    showChurchOfAttendanceOthersState = false;
                  }
                  print("churchOfAttendanceID : $churchOfAttendanceID");
                });
              },
            ),
          ),
        if (listDropChurchOfAttendance.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryDarkColor),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Loading churches...",
                  style: TextStyle(
                    color: primaryDarkColor,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        if (!churchState)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              AppLocalizations.of(context)!.pleaseChooseChurch,
              style: TextStyle(
                fontSize: 12.0,
                color: red700,
              ),
            ),
          ),
      ],
    );
  }
  Widget showChurchOfAttendanceOthers() {
  if (!showChurchOfAttendanceOthersState) return Container();

  return Padding(
    padding: const EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
    child: SizedBox(
      width: double.infinity,
      child: MyCustomTextFieldChurchOfAttendance(
        customController: customControllerChurchOfAttendance,
      ),
    ),
  );
}
} // End of _CompleteRegistrationDataPageActivityState class


class MyCustomTextFieldFirstName extends StatelessWidget {
  final MyCustomControllerFirstName customController;

  const MyCustomTextFieldFirstName({
    Key? key, // ✅ Clé optionnelle
    required this.customController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: customController.firstNameController,
      enabled: customController.enable,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText:
            AppLocalizations.of(context)?.firstNameWithAstric ?? "First Name *",
        labelStyle: const TextStyle(color: Colors.black),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor),
        ),
      ),
      validator: (String? valueFirstName) {
        if (valueFirstName == null || valueFirstName.isEmpty) {
          return AppLocalizations.of(context)?.pleaseEnterYourFirstName ??
              "Please enter your first name";
        }
        return null;
      },
      cursorColor: accentColor,
      keyboardType: TextInputType.text,
      style: TextStyle(
        color: primaryDarkColor,
        fontSize: 20.0,
        fontFamily: 'cocon-next-arabic-regular',
      ),
    );
  }
}

class MyCustomControllerFirstName {
  final TextEditingController firstNameController;
  bool enable;

  MyCustomControllerFirstName(
      {required this.firstNameController, this.enable = true});
}

class MyCustomControllerLastName {
  final TextEditingController lastNameController;
  bool enable;

  MyCustomControllerLastName({
    required this.lastNameController,
    this.enable = true,
  });
}

class MyCustomTextFieldLastName extends StatelessWidget {
  final MyCustomControllerLastName customController;

  const MyCustomTextFieldLastName({
    Key? key,
    required this.customController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: customController.lastNameController,
      enabled: customController.enable,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)?.lastNameWithAstric ??
            "Last Name *",
        labelStyle: const TextStyle(color: Colors.black),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor),
        ),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)?.pleaseEnterYourLastName ??
              "Please enter your last name";
        }
        return null;
      },
      cursorColor: accentColor,
      keyboardType: TextInputType.text,
      style: TextStyle(
        color: primaryDarkColor,
        fontSize: 20.0,
        fontFamily: 'cocon-next-arabic-regular',
      ),
    );
  }
}



class MyCustomTextFieldFullName extends StatelessWidget {
  final MyCustomControllerFullName customController;

  const MyCustomTextFieldFullName({Key? key, required this.customController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: customController.fullNameController,
      enabled: customController.enable,
      style: const TextStyle(
        color: Colors.white, // ✅ Texte blanc
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: Colors.blueAccent,
      decoration: glassFieldDecoration(
        context,
        AppLocalizations.of(context)?.fullNameWithAstric ?? "Full Name *",
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)?.pleaseEnterYourFullName ?? "Please enter your full name";
        }
        return null;
      },
    );
  }
}

InputDecoration glassFieldDecoration(BuildContext context, String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: Colors.white, // ✅ Blanc pour la visibilité
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    filled: true,
    fillColor: Colors.white.withOpacity(0.15), // ✅ Fond blanc translucide
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}




class MyCustomControllerFullName {
  final TextEditingController fullNameController;
  bool enable;

  MyCustomControllerFullName(
      {required this.fullNameController, this.enable = true});
}

class MyCustomTextFieldID extends StatelessWidget {
  final MyCustomControllerID customController;

  const MyCustomTextFieldID({Key? key, required this.customController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: customController.iDController,
      enabled: customController.enable,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(14),
      ],
      style: const TextStyle(color: Colors.white, fontSize: 18),
      decoration: buildGlassInputDecoration(
        context,
        AppLocalizations.of(context)?.nationalIdWithAstric ?? "National ID *",
      ),
      validator: (String? valueID) {
        if (valueID == null || valueID.isEmpty) {
          return AppLocalizations.of(context)?.pleaseEnterYourNationalId ??
              "Please enter your National ID";
        } else if (!isNationalIDValid(valueID)) {
          return AppLocalizations.of(context)?.pleaseEnterCorrectNationalId ??
              "Please enter a correct National ID";
        }
        return null;
      },
    );
  }
}

bool isNationalIDValid(String value) {
  return RegExp(r'^\d{14}$').hasMatch(value);
}
  @override
Widget build(BuildContext context) {
  return TextFormField(
    controller: customControllerID.iDController, // ✅ Corrigé
    enabled: customControllerID.enable,
    textCapitalization: TextCapitalization.none,
    style: const TextStyle(color: Colors.white, fontSize: 18),
    cursorColor: Colors.blueAccent,
    decoration: buildGlassInputDecoration(
      context,
      AppLocalizations.of(context)?.nationalIdWithAstric ?? "National ID *",
    ),
    validator: (String? valueID) {
      if (valueID == null || valueID.isEmpty) {
        return AppLocalizations.of(context)?.pleaseEnterYourNationalId ??
            "Please enter your National ID";
      } else if (valueID.length != 14) {
        return AppLocalizations.of(context)?.pleaseEnterCorrectNationalId ??
            "Please enter a correct National ID";
      }
      return null;
    },
    keyboardType: TextInputType.number,
  );
}


class MyCustomControllerID {
  final TextEditingController iDController;
  bool enable;

  MyCustomControllerID({required this.iDController, this.enable = true});
}
MyCustomControllerID customControllerID =
    MyCustomControllerID(iDController: TextEditingController());

class MyCustomTextFieldMobile extends StatelessWidget {
  final MyCustomControllerMobile customController;

  const MyCustomTextFieldMobile({
    Key? key,
    required this.customController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: customController.mobileController,
      enabled: customController.enable,
      keyboardType: TextInputType.phone,
      textCapitalization: TextCapitalization.none,
      style: const TextStyle(
        color: Colors.white,          // ✅ Texte blanc
        fontSize: 18.0,
        fontFamily: 'cocon-next-arabic-regular',
      ),
      cursorColor: Colors.blueAccent, // ✅ Curseur bleu
      decoration: buildGlassInputDecoration(
        context,
        AppLocalizations.of(context)?.mobileWithAstric ?? "Mobile *",
      ),
      validator: (String? valueMobileNumber) {
        if (valueMobileNumber == null || valueMobileNumber.isEmpty) {
          return AppLocalizations.of(context)?.pleaseEnterYourMobile ??
              "Please enter your mobile number";
        } else if (valueMobileNumber.length < 10) {
          return AppLocalizations.of(context)?.pleaseEnterAValidMobileNumber ??
              "Please enter a valid mobile number";
        }
        return null;
      },
    );
  }
}

class MyCustomControllerMobile {
  final TextEditingController mobileController;
  bool enable;

  MyCustomControllerMobile(
      {required this.mobileController, this.enable = true});
}

class MyCustomTextFieldAddress extends StatelessWidget {
  final MyCustomControllerAddress customController;

  const MyCustomTextFieldAddress({
    Key? key,
    required this.customController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: customController.addressController,
      enabled: customController.enable,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      cursorColor: Colors.blueAccent,
      decoration: buildGlassInputDecoration(
        context,
        AppLocalizations.of(context)?.addressWithAstric ?? "Address *",
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)?.pleaseEnterYourAddress ??
              "Please enter your address";
        }
        return null;
      },
    );
  }
}

class MyCustomControllerAddress {
  final TextEditingController addressController;
  bool enable;

  MyCustomControllerAddress(
      {required this.addressController, this.enable = true});
}

class MyCustomTextFieldChurchOfAttendance extends StatelessWidget {
  final MyCustomControllerChurchOfAttendance customController;
  final String? churchOfAttendanceID;

  const MyCustomTextFieldChurchOfAttendance({
    Key? key,
    required this.customController,
    this.churchOfAttendanceID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: customController.churchOfAttendanceController,
      enabled: customController.enable,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      cursorColor: Colors.blueAccent,
      decoration: buildGlassInputDecoration(
        context,
        AppLocalizations.of(context)?.churchOfAttendanceWithAstric ??
            "Church of Attendance *",
      ),
      validator: (value) {
        if ((value == null || value.isEmpty) &&
            churchOfAttendanceID == "-1") {
          return AppLocalizations.of(context)?.pleaseEnterYourChurchOfAttendance ??
              "Please enter your church of attendance";
        }
        return null;
      },
    );
  }
}

/// 🔹 Décoration pour champs style "GlassCard"
InputDecoration buildGlassInputDecoration(BuildContext context, String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
    ),
    filled: true,
    fillColor: Colors.white.withOpacity(0.15), // ✅ Fond semi-transparent
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Colors.white, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Colors.red, width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

class MyCustomControllerChurchOfAttendance {
  final TextEditingController churchOfAttendanceController;
  bool enable;

  MyCustomControllerChurchOfAttendance(
      {required this.churchOfAttendanceController, this.enable = true});
}


class MyBullet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 5.0,
      width: 5.0,
      decoration: new BoxDecoration(
        color: primaryDarkColor,
        shape: BoxShape.circle,
      ),
    );
  }  
  
  
  }
