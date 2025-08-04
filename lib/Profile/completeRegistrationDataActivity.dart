import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Models/churchs.dart';
import 'package:egpycopsversion4/Models/governorates.dart';
import 'package:egpycopsversion4/Models/personRelation.dart';
import 'package:egpycopsversion4/l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Base URL API
String baseUrl = BaseUrl().BASE_URL;

class CompleteRegistrationDataPageActivity extends StatefulWidget {
  final String title;

  const CompleteRegistrationDataPageActivity({
    Key? key,
    required this.title,
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
    _init();
  }

  /// 🔹 Initialisation des données et du token
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    myLanguage = prefs.getString('language') ?? "en";
    final accountType = prefs.getString("accountType");
    isFamilyAccount = accountType == "1";

    FirebaseMessaging.instance.getToken().then((String? token) {
      if (token != null) {
        setState(() {
          mobileToken = token;
        });
      }
    });

    // Initialize form states
    setState(() {
      showRelationShipState = isFamilyAccount;
      showGenderState = true;
      governorateState = true;
      churchState = true;
    });

    await getDataFromShared();
    await getGovernorates(); // Load governorates for all account types
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppLocalizations.of(context)?.completeInformation ?? "Complete Information",
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: primaryDarkColor,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildSectionHeader("Personal Information", Icons.person_outline),
              const SizedBox(height: 16),
              
              // Personal Info Card
              _buildCard([
                MyCustomTextFieldFullName(customController: customControllerFullName),
                const SizedBox(height: 20),
                MyCustomTextFieldID(customController: customControllerID),
                const SizedBox(height: 20),
                MyCustomTextFieldMobile(customController: customControllerMobile),
                const SizedBox(height: 20),
                MyCustomTextFieldAddress(customController: customControllerAddress),
              ]),
              
              const SizedBox(height: 24),
              
              // Additional Information Section
              _buildSectionHeader("Additional Information", Icons.info_outline),
              const SizedBox(height: 16),
              
              // Additional Info Card
              _buildCard([
                showGenderLayout(),
                const SizedBox(height: 20),
                showRelationshipLayout(context),
                const SizedBox(height: 20),
                showDeaconCheckboxLayout(),
              ]),
              
              const SizedBox(height: 24),
              
              // Location Information Section
              _buildSectionHeader("Location Information", Icons.location_on_outlined),
              const SizedBox(height: 16),
              
              // Location Info Card
              _buildCard([
                showGovernoratesLayout(context),
                const SizedBox(height: 20),
                showChurchOfAttendanceLayout(),
                const SizedBox(height: 10),
                showChurchOfAttendanceOthers(),
              ]),
              
              const SizedBox(height: 32),
              
              // Register Button
              buildRegisterButtonWidget(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryDarkColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: primaryDarkColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
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

  /// 🔹 Dropdown Relationship
  Widget showRelationshipLayout(BuildContext context) {
    if (!showRelationShipState) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.relationshipWithAstric ?? "Relationship *",
          style: const TextStyle(
            fontSize: 16.0, 
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: DropdownButton<String>(
            value: relationshipID,
            isExpanded: true,
            underline: Container(),
            icon: Icon(Icons.keyboard_arrow_down, color: primaryDarkColor),
            items: listDropRelationship.map((map) {
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
            onChanged: (String? value) {
              setState(() {
                relationshipID = value ?? "0";
                final selectedItem = listDropRelationship.firstWhere(
                  (item) => item["id"].toString() == relationshipID,
                  orElse: () => {},
                );
                showDeaconRadioButtonState = (selectedItem["genderTypeID"] == 1);
              });
            },
          ),
        ),
        if (!relationshipState)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              AppLocalizations.of(context)?.pleaseChooseRelationship ??
                  "Please choose a relationship",
              style: TextStyle(fontSize: 12.0, color: red700),
            ),
          ),
      ],
    );
  }

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
    // Reset error message
    setState(() {
      errorMessage = "";
    });

    // Validate form fields
    if (!_validateForm()) {
      return;
    }

    // Set loading state
    setState(() {
      registerState = 1;
    });

    try {
      // Prepare registration data
      final registrationData = _prepareRegistrationData();
      
      // Call registration API
      await _submitRegistration(registrationData);
      
    } catch (e) {
      setState(() {
        errorMessage = "Registration failed: ${e.toString()}";
        registerState = 0;
      });
      
      // Show error to user
      _showErrorDialog(errorMessage);
    }
  }

  /// 🔹 Validate all form fields
  bool _validateForm() {
    bool isValid = true;
    
    // Validate form using GlobalKey
    if (!_formKey.currentState!.validate()) {
      isValid = false;
    }

    // Validate gender selection
    if (selectedGenderRadioTile == 0) {
      setState(() {
        // Add gender validation error handling if needed
      });
      isValid = false;
    }

    // Validate relationship for family accounts
    if (isFamilyAccount && relationshipID == "0") {
      setState(() {
        relationshipState = false;
      });
      isValid = false;
    } else {
      setState(() {
        relationshipState = true;
      });
    }

    // Validate deacon selection if required
    if (showDeaconRadioButtonState && selectedDeaconRadioTile == 0) {
      setState(() {
        deaconState = false;
      });
      isValid = false;
    } else {
      setState(() {
        deaconState = true;
      });
    }

    // Validate governorate selection
    if (governorateID == "0") {
      setState(() {
        governorateState = false;
      });
      isValid = false;
    } else {
      setState(() {
        governorateState = true;
      });
    }

    // Validate church selection
    if (churchOfAttendanceID == "0") {
      setState(() {
        churchState = false;
      });
      isValid = false;
    } else {
      setState(() {
        churchState = true;
      });
    }

    // If "Others" is selected for church, validate the text field
    if (churchOfAttendanceID == "-1" && 
        customControllerChurchOfAttendance.churchOfAttendanceController.text.isEmpty) {
      setState(() {
        churchState = false;
      });
      isValid = false;
    }

    return isValid;
  }

  /// 🔹 Prepare registration data for API call
  Map<String, dynamic> _prepareRegistrationData() {
    return {
      "fullName": customControllerFullName.fullNameController.text.trim(),
      "nationalId": customControllerID.iDController.text.trim(),
      "mobile": customControllerMobile.mobileController.text.trim(),
      "address": customControllerAddress.addressController.text.trim(),
      "genderTypeId": selectedGenderRadioTile,
      "relationshipId": isFamilyAccount ? relationshipID : "0",
      "isDeacon": showDeaconRadioButtonState ? (selectedDeaconRadioTile == 1) : false,
      "governorateId": governorateID,
      "churchId": churchOfAttendanceID == "-1" ? "0" : churchOfAttendanceID,
      "customChurch": churchOfAttendanceID == "-1" 
          ? customControllerChurchOfAttendance.churchOfAttendanceController.text.trim() 
          : "",
      "mobileToken": mobileToken,
      "language": myLanguage,
    };
  }

  /// 🔹 Submit registration to API
  Future<void> _submitRegistration(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl/User/CompleteRegistration');
      print('Submitting registration to: $uri');
      print('Registration data: $data');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      if (response.statusCode == 200) {
        // Registration successful
        setState(() {
          registerState = 0;
        });
        
        _showSuccessDialog();
      } else {
        throw Exception('Server returned status ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        registerState = 0;
      });
      throw e;
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

  const MyCustomTextFieldFullName({
    Key? key,
    required this.customController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: customController.fullNameController,
      enabled: customController.enable,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)?.fullNameWithAstric ?? "Full Name *",
        labelStyle: const TextStyle(color: Colors.black),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor),
        ),
      ),
      validator: (String? valueFullName) {
        if (valueFullName == null || valueFullName.isEmpty) {
          return AppLocalizations.of(context)?.pleaseEnterYourFullName ??
              "Please enter your full name";
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

class MyCustomControllerFullName {
  final TextEditingController fullNameController;
  bool enable;

  MyCustomControllerFullName(
      {required this.fullNameController, this.enable = true});
}

class MyCustomTextFieldID extends StatelessWidget {
  final MyCustomControllerID customController;

  const MyCustomTextFieldID({
    Key? key, // ✅ Clé optionnelle
    required this.customController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: customController.iDController,
      enabled: customController.enable,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText:
            AppLocalizations.of(context)?.nationalIdWithAstric ?? "National ID *",
        labelStyle: const TextStyle(color: Colors.black),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor),
        ),
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
      cursorColor: accentColor,
      keyboardType: TextInputType.number,
      style: TextStyle(
        color: primaryDarkColor,
        fontSize: 20.0,
        fontFamily: 'cocon-next-arabic-regular',
      ),
    );
  }
}

class MyCustomControllerID {
  final TextEditingController iDController;
  bool enable;

  MyCustomControllerID({required this.iDController, this.enable = true});
}

class MyCustomTextFieldMobile extends StatelessWidget {
  final MyCustomControllerMobile customController;

  const MyCustomTextFieldMobile({
    Key? key, // ✅ Clé optionnelle maintenant
    required this.customController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: customController.mobileController,
      enabled: customController.enable,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText:
            AppLocalizations.of(context)?.mobileWithAstric ?? "Mobile *",
        labelStyle: const TextStyle(color: Colors.black),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor),
        ),
      ),
      cursorColor: accentColor,
      keyboardType: TextInputType.phone,
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
      style: TextStyle(
        color: primaryDarkColor,
        fontSize: 20.0,
        fontFamily: 'cocon-next-arabic-regular',
      ),
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
    Key? key, // ✅ Clé optionnelle
    required this.customController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: customController.addressController,
      enabled: customController.enable,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText:
            AppLocalizations.of(context)?.addressWithAstric ?? "Address *",
        labelStyle: const TextStyle(color: Colors.black),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor),
        ),
      ),
      validator: (String? valueAddress) {
        if (valueAddress == null || valueAddress.isEmpty) {
          return AppLocalizations.of(context)?.pleaseEnterYourAddress ??
              "Please enter your address";
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
    Key? key, // ✅ Optionnel maintenant
    required this.customController,
    this.churchOfAttendanceID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: customController.churchOfAttendanceController,
      enabled: customController.enable,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)?.churchOfAttendanceWithAstric ??
            "Church of Attendance *",
        labelStyle: const TextStyle(color: Colors.black),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor),
        ),
      ),
      validator: (String? valueChurchOfAttendance) {
        if ((valueChurchOfAttendance == null || valueChurchOfAttendance.isEmpty) &&
            churchOfAttendanceID == "-1") {
          return AppLocalizations.of(context)?.pleaseEnterYourChurchOfAttendance ??
              "Please enter your church of attendance";
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
