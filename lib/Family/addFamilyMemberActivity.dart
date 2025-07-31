import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Home/homeActivity.dart';
import 'package:egpycopsversion4/Models/addFamilyMember.dart';
import 'package:egpycopsversion4/Models/churchs.dart';
import 'package:egpycopsversion4/Models/familyMember.dart';
import 'package:egpycopsversion4/Models/governorates.dart';
import 'package:egpycopsversion4/Models/personRelation.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_text/skeleton_text.dart';

String? myLanguage;

BaseUrl BASE_URL = BaseUrl();
String baseUrl = BASE_URL.BASE_URL;
String familyAccount = "";

String name = "", mobileGlobal = "", nationalIDGlobal = "";
String pageTitle = "";
String accountTypeID = "0";
String relationshipIDGlobal = "0";
String userID = "", email = "";
bool checkBoxValue = false;
bool genderState = true;
bool accountTypeState = true;
bool relationshipState = true;
bool isAddGlobal = true;
int saveState = 0;
int? isDeacon;
int? isMain;
int? selectedGenderRadioTile;
int? loadingState;
String errorMsg = "";

String? addressGlobal;
String? branchID;
String? churchOfAttendance;
String memberIDFromCon = "";
bool isPersonal = false;
bool deaconState = true;
bool governorateState = true;
bool churchState = true;
String churchid = "0";
String governorateid = "0";
bool edited = false; // Variable manquante ajoutée

class AddFamilyMemberActivity extends StatefulWidget {
  AddFamilyMemberActivity(
      bool isADD,
      String fullName,
      String relationshipId,
      int deacon,
      String nationalId,
      String mobileNumber,
      String accountMemberID,
      String addressConstructor,
      String branchIDConstructor,
      String governorateIDConstructor,
      String churchOfAttendancConstructore,
      int mainAccount,
      bool personalAccount) {
    isAddGlobal = isADD;
    name = fullName;
    relationshipIDGlobal = relationshipId;
    isDeacon = deacon;
    nationalIDGlobal = nationalId;
    mobileGlobal = mobileNumber;
    memberIDFromCon = accountMemberID;
    addressGlobal = addressConstructor;
    churchid = branchIDConstructor.isEmpty ? "0" : branchIDConstructor;
    governorateid = governorateIDConstructor.isEmpty ? "0" : governorateIDConstructor;
    churchOfAttendance = churchOfAttendancConstructore;
    isMain = mainAccount;
    isPersonal = personalAccount;
  }

  @override
  State<StatefulWidget> createState() {
    return AddFamilyMemberActivityState();
  }
}

class AddFamilyMemberActivityState extends State<AddFamilyMemberActivity>
    with TickerProviderStateMixin {
  String? mobileToken;
  bool showDeaconRadioButtonState = false;
  bool showRelationShipState = false;
  late Animation _animationLogin;

  late int selectedDeaconRadioTile;
  MyCustomControllerName customControllerName =
      MyCustomControllerName(nameController: TextEditingController());

  MyCustomControllerID customControllerID =
      MyCustomControllerID(iDController: TextEditingController());

  MyCustomControllerMobile customControllerMobile =
      MyCustomControllerMobile(mobileController: TextEditingController());
  String nationalID = "";
  MyCustomControllerAddress customControllerAddress =
      MyCustomControllerAddress(addressController: TextEditingController());
  late SpecificLocalizationDelegate _specificLocalizationDelegate;
  bool isAdd = true;
  String mobile = "";
  TextEditingController customControllerChurchOfAttendance = TextEditingController();
  String relationshipID = "0";
  String? address;

  var _formKey = GlobalKey<FormState>();
  bool showGenderState = false;
  String? errorMessage;

  List<PersonRelation> relationshipList = [];
  String memberID = "";

  List<Map> listDropAccountType = [];
  List<Map> listDropRelationship = [];
  List<Map> listDropGender = [];
  List<FamilyMember> myFamilyList = [];
  List<Map> listViewMyFamily = [];
  bool showChurchOfAttendanceState = false;
  bool showChurchOfAttendanceError = false;
  bool showGovernorateError = false;
  bool showChurchOfAttendanceOthersState = false;
  List<Churchs> churchOfAttendanceList = [];
  List<Governorates> governoratesList = [];
  String churchOfAttendanceID = "0";
  String governorateID = "0";
  List<Map> listDropChurchOfAttendance = [];
  List<Map> listDropGovernorates = [];

  accountTypeDropDownData() async {
    setState(() {
      listDropAccountType
        ..add({"id": "0", "name": AppLocalizations.of(context)!.family});
      listDropAccountType
        ..add({"id": "1", "name": AppLocalizations.of(context)!.personal});
    });
  }

  relationShipDropDownData() async {
    setState(() {
      listDropRelationship
        ..add({
          "id": "0",
          "genderTypeID": "0",
          "nameAr": AppLocalizations.of(context)!.chooseRelationship,
          "nameEn": AppLocalizations.of(context)!.chooseRelationship
        });
    });

    setState(() {
      for (int i = 0; i < relationshipList.length; i++) {
        listDropRelationship
          ..add({
            "id": relationshipList.elementAt(i).id,
            "genderTypeID": relationshipList.elementAt(i).genderTypeID,
            "nameAr": relationshipList.elementAt(i).nameAr,
            "nameEn": relationshipList.elementAt(i).nameEn
          });
      }
    });
  }

  genderDropDownData() async {
    setState(() {
      listDropGender
        ..add({"id": "0", "name": AppLocalizations.of(context)!.male});
      listDropGender
        ..add({"id": "1", "name": AppLocalizations.of(context)!.female});
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((String? token) {
      if (token != null) {
        print("Token  " + token);
        mobileToken = token;
      }
    });
    isAdd = isAddGlobal;
    address = addressGlobal;
    nationalID = nationalIDGlobal;
    relationshipID = relationshipIDGlobal;
    errorMessage = "";
    selectedDeaconRadioTile = isDeacon!;
    memberID = memberIDFromCon;
    churchOfAttendanceID = churchid;
    governorateID = governorateid;
    loadingState = 0;
    mobile = mobileGlobal;
    getDataFromShared();
  }

  Future<String> _checkInternetConnection() async {
    String connectionResult;
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      connectionResult = "0";
    } else {
      connectionResult = "1";
    }
    return connectionResult;
  }

  Future<List<FamilyMember>?> getMyFamily() async {
    // Implémentation de la méthode manquante
    try {
      var response = await http.get(Uri.parse('$baseUrl/Family/GetMyFamily/?UserAccountID=$userID&token=$mobileToken'));
      if (response.statusCode == 200) {
        return familyMemberFromJson(response.body);
      }
    } catch (e) {
      print('Error getting family: $e');
    }
    return null;
  }

  Future<List<Governorates>?> getGovernoratesByUserID() async {
    // Implémentation de la méthode manquante
    try {
      var response = await http.get(Uri.parse('$baseUrl/Booking/GetGovernoratesByUserID/?UserAccountID=$userID'));
      if (response.statusCode == 200) {
        return governoratesFromJson(response.body);
      }
    } catch (e) {
      print('Error getting governorates: $e');
    }
    return null;
  }

  Future<List<Churchs>?> getChurchs(String governorateID) async {
    // Implémentation de la méthode manquante
    try {
      var response = await http.get(Uri.parse('$baseUrl/Booking/GetChurch/?GovernerateID=$governorateID'));
      if (response.statusCode == 200) {
        return churchsFromJson(response.body);
      }
    } catch (e) {
      print('Error getting churches: $e');
    }
    return null;
  }

  Future<List<PersonRelation>?> getRelationships() async {
    // Implémentation de la méthode manquante
    try {
      var response = await http.get(Uri.parse('$baseUrl/Family/GetRelationships/'));
      if (response.statusCode == 200) {
        return personRelationFromJson(response.body);
      }
    } catch (e) {
      print('Error getting relationships: $e');
    }
    return null;
  }

  governoratesDropDownData() async {
    setState(() {
      listDropGovernorates.clear();
      listDropGovernorates
        ..add({
          "id": "0",
          "nameAr": "اختار المحافظة",
          "nameEn": "Choose Governorate",
          "isDefualt": false
        });

      for (var governorate in governoratesList) {
  listDropGovernorates.add({
    "id": governorate.id,
    "nameAr": governorate.nameAr,
    "nameEn": governorate.nameEn,
    "isDefualt": governorate.isDefualt ?? false, // Sécurité si null
  });

  if (governorate.isDefualt == true) {
    governorateID = governorate.id?.toString() ?? "0"; // Sécurité si id null
  }
}

    });
  }

  churchOfAttendanceDropDownData() async {
    setState(() {
      listDropChurchOfAttendance.clear();
      listDropChurchOfAttendance
        ..add({
          "id": "0",
          "nameAr": "اختار الكنيسة",
          "nameEn": "Choose Church",
          "isDefualt": false
        });

      for (int i = 0; i < churchOfAttendanceList.length; i++) {
        listDropChurchOfAttendance
          ..add({
            "id": churchOfAttendanceList.elementAt(i).id,
            "nameAr": churchOfAttendanceList.elementAt(i).nameAr,
            "nameEn": churchOfAttendanceList.elementAt(i).nameEn,
            "isDefualt": churchOfAttendanceList.elementAt(i).isDefualt
          });
      }
    });
  }

  Future<String> checkNationalID(String nationalID) async {
    print('nationalID: to send to CheckNationalID $nationalID');
    var response = await http.get(
        Uri.parse('$baseUrl/Users/CheckNationalID/?NationalID=$nationalID&IsMainPerson=$isMain'));
    print(
        '$baseUrl/Users/CheckNationalID/?NationalID=$nationalID&IsMainPerson=$isMain');
    print(response.body);
    if (response.statusCode == 200) {
      var addFamilyMemberObj =
          addFamilyMemberFromJson(response.body.toString());
      print('jsonResponse $addFamilyMemberObj');
      if (myLanguage == "ar") {
        errorMessage = addFamilyMemberObj.nameAr;
      } else {
        errorMessage = addFamilyMemberObj.nameEn;
      }
      if (addFamilyMemberObj.code == "0") {
        return "0";
      } else if (addFamilyMemberObj.code == "1") {
        return "1";
      } else if (addFamilyMemberObj.code == "2") {
        return "2";
      } else {
        return "error";
      }
    } else {
      return "error";
    }
  }

  Future<String> addEditFamilyMember(
      String fullName, String nationalID, String mobile) async {
    print('Name=$fullName');
    print('relationID=${int.parse(relationshipID)}');
    int? gender;
    if (!isPersonal) {
      if (int.parse(relationshipID) == 1 || int.parse(relationshipID) == 3) {
        gender = 1;
      } else {
        gender = 2;
      }
    } else {
      gender = selectedGenderRadioTile;
    }
    bool isDeacon = false;
    if (selectedDeaconRadioTile == 1) {
      isDeacon = true;
    } else {
      isDeacon = false;
    }
    print('Deacon=$isDeacon');

    print('NationalID=$nationalID');
    print('Mobile=$mobile');
    print('UserAccountID=$userID');
    int flagAdd;
    if (isAdd) {
      flagAdd = 1;
      memberID = "";
    } else {
      flagAdd = 2;
    }

    print('flag=$flagAdd');
    print('AccountMemberID=$memberID');
    print('Token=$mobileToken');
    var response = await http.post(
        Uri.parse('$baseUrl/Family/AddEditFamilyMember/?Name=$fullName&relationID=${int.parse(relationshipID)}&Deacon=$isDeacon&NationalID=$nationalID&Mobile=$mobile&UserAccountID=$userID&GenderID=$gender&Ismain=$isMain&churchOfAttendance=$churchOfAttendance&Address=$address&BranchID=$churchOfAttendanceID&GovernerateID=$governorateID&flag=$flagAdd&AccountMemberID=$memberID&Token=$mobileToken'));
    print(
        '$baseUrl/Family/AddEditFamilyMember/?Name=$fullName&relationID=${int.parse(relationshipID)}&Deacon=$isDeacon&NationalID=$nationalID&Mobile=$mobile&UserAccountID=$userID&GenderID=$gender&Ismain=$isMain&churchOfAttendance=$churchOfAttendance&Address=$address&BranchID=$churchOfAttendanceID&GovernerateID=$governorateID&flag=$flagAdd&AccountMemberID=$memberID&Token=$mobileToken');
    print(response.body);

    if (response.statusCode == 200) {
      var addFamilyMemberObj =
          addFamilyMemberFromJson(response.body.toString());
      print('jsonResponse $addFamilyMemberObj');
      if (myLanguage == "ar") {
        errorMessage = addFamilyMemberObj.nameAr;
      } else {
        errorMessage = addFamilyMemberObj.nameEn;
      }
      if (addFamilyMemberObj.code == "1") {
        return "1";
      } else if (addFamilyMemberObj.code == "2") {
        return "2";
      } else {
        return "error";
      }
    } else {
      return "error";
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isAdd) {
      pageTitle = AppLocalizations.of(context)!.addFamilyMember;
    } else {
      if (isMain == 1) {
        pageTitle = AppLocalizations.of(context)!.myProfile;
      } else {
        pageTitle = AppLocalizations.of(context)!.editFamilyMember;
      }
    }
  }

  getDataFromShared() async {
    if (isPersonal) {
      saveState = 0;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      myLanguage = (prefs.getString('language') ?? "en");
      familyAccount = prefs.getString("accountType") ?? "";

      userID = prefs.getString("userID") ?? "";
      email = prefs.getString("email") ?? "";
      String connectionResponse = await _checkInternetConnection();
      print("connectionResponse");
      print(connectionResponse);
      if (connectionResponse == '1') {
        myFamilyList = (await getMyFamily()) ?? [];
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => NoInternetConnectionActivity(),
          ),
        );
      }
      if (myFamilyList.isNotEmpty) {
        myFamilyListViewData();
        if (churchOfAttendanceID.isEmpty) {
          churchOfAttendanceID = "-1";
          edited = true;
        } else {
          edited = false;
        }
        if (churchOfAttendance!.isNotEmpty) {
          showChurchOfAttendanceOthersState = true;
        } else {
          showChurchOfAttendanceOthersState = false;
        }
        customControllerName.nameController.text = name;
        customControllerMobile.mobileController.text = mobile;
        customControllerID.iDController.text = nationalID;
        customControllerAddress.addressController.text = address!;
        print("churchOfAttendanceID getSharedData: $churchOfAttendanceID");
        print("churchOfAttendance getSharedData: $churchOfAttendance");
        customControllerChurchOfAttendance.text = churchOfAttendance!;
        setState(() {
          accountTypeID = "0";
          checkBoxValue = false;
          genderState = true;
          accountTypeState = true;
          showChurchOfAttendanceState = false;
          relationshipState = true;
        });
        await accountTypeDropDownData();
        await genderDropDownData();

        governoratesList = (await getGovernoratesByUserID()) ?? [];
        await governoratesDropDownData();
        churchOfAttendanceList = (await getChurchs(governorateID)) ?? [];
        await churchOfAttendanceDropDownData();
        relationshipList = (await getRelationships()) ?? [];
        await relationShipDropDownData();
        setState(() {
          if (familyAccount == "1") {
            showRelationShipState = true;
            showGenderState = false;
            if (relationshipID == "1" ||
                relationshipID == "3" ||
                relationshipID == "5" ||
                relationshipID == "7") {
              showDeaconRadioButtonState = true;
            } else {
              showDeaconRadioButtonState = false;
            }
          } else {
            showRelationShipState = false;
            showGenderState = true;
            if (selectedGenderRadioTile == 1) {
              showDeaconRadioButtonState = true;
            } else {
              showDeaconRadioButtonState = false;
            }
          }
        });
      }
    } else {
      saveState = 0;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      myLanguage = (prefs.getString('language') ?? "en");
      familyAccount = prefs.getString("accountType") ?? "";

      userID = prefs.getString("userID") ?? "";
      email = prefs.getString("email") ?? "";
      if (churchOfAttendanceID.isEmpty) {
        churchOfAttendanceID = "-1";
        edited = true;
      } else {
        edited = false;
      }
      if (churchOfAttendance!.isNotEmpty) {
        showChurchOfAttendanceOthersState = true;
      } else {
        showChurchOfAttendanceOthersState = false;
      }
      customControllerName.nameController.text = name;
      customControllerMobile.mobileController.text = mobile;
      customControllerID.iDController.text = nationalID;
      customControllerAddress.addressController.text = address!;
      customControllerChurchOfAttendance.text = churchOfAttendance!;

      String connectionResponse = await _checkInternetConnection();
      print("connectionResponse");
      print(connectionResponse);
      setState(() {
        accountTypeID = "0";
        if (relationshipID == "1" ||
            relationshipID == "3" ||
            relationshipID == "5" ||
            relationshipID == "7") {
          showDeaconRadioButtonState = true;
        } else {
          showDeaconRadioButtonState = false;
        }
        if (familyAccount == "1") {
          showRelationShipState = true;
        } else {
          showRelationShipState = false;
        }
        checkBoxValue = false;
        genderState = true;
        accountTypeState = true;
        showChurchOfAttendanceState = false;
        relationshipState = true;
      });
      await accountTypeDropDownData();
      await genderDropDownData();

      governoratesList = (await getGovernoratesByUserID()) ?? [];
      await governoratesDropDownData();
      churchOfAttendanceList = (await getChurchs(governorateID)) ?? [];
      await churchOfAttendanceDropDownData();
      relationshipList = (await getRelationships()) ?? [];
      await relationShipDropDownData();
    }
  }

  myFamilyListViewData() {
    setState(() {
      listViewMyFamily.clear();
      for (int i = 0; i < myFamilyList.length; i++) {
        listViewMyFamily.add({
          "userAccountMemberId": myFamilyList.elementAt(i).userAccountMemberId,
          "userAccountId": myFamilyList.elementAt(i).userAccountId,
          "accountMemberNameAr": myFamilyList.elementAt(i).accountMemberNameAr,
          "genderTypeId": myFamilyList.elementAt(i).genderTypeId,
          "genderTypeNameAr": myFamilyList.elementAt(i).genderTypeNameAr,
          "genderTypeNameEn": myFamilyList.elementAt(i).genderTypeNameEn,
          "isDeacon": myFamilyList.elementAt(i).isDeacon,
          "nationalIdNumber": myFamilyList.elementAt(i).nationalIdNumber,
          "mobile": myFamilyList.elementAt(i).mobile,
          "personRelationId": myFamilyList.elementAt(i).personRelationId,
          "personRelationNameAr": myFamilyList.elementAt(i).personRelationNameAr,
          "personRelationNameEn": myFamilyList.elementAt(i).personRelationNameEn,
          "isMainPerson": myFamilyList.elementAt(i).isMainPerson,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            pageTitle,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
          ),
        ),
        backgroundColor: primaryDarkColor,
      ),
      body: Container(
        child: Text("Interface utilisateur à implémenter"),
      ),
    );
  }
}

// Classes de contrôleurs personnalisés manquantes
class MyCustomControllerName {
  final TextEditingController nameController;
  MyCustomControllerName({required this.nameController});
}

class MyCustomControllerID {
  final TextEditingController iDController;
  MyCustomControllerID({required this.iDController});
}

class MyCustomControllerMobile {
  final TextEditingController mobileController;
  MyCustomControllerMobile({required this.mobileController});
}

class MyCustomControllerAddress {
  final TextEditingController addressController;
  MyCustomControllerAddress({required this.addressController});
}

class SpecificLocalizationDelegate {
  // Implémentation de base pour la délégation de localisation
  SpecificLocalizationDelegate(Locale locale);
}

