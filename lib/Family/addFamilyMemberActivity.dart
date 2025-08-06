import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Models/addFamilyMember.dart';
import 'package:egpycopsversion4/Models/churchs.dart';
import 'package:egpycopsversion4/Models/familyMember.dart';
import 'package:egpycopsversion4/Models/governorates.dart';
import 'package:egpycopsversion4/Models/personRelation.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    churchid = branchIDConstructor.isEmpty ? "0" : branchIDConstructor.toString();
    governorateid = governorateIDConstructor.isEmpty ? "0" : governorateIDConstructor.toString();
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
  


  relationShipDropDownData() async {
    final localizations = AppLocalizations.of(context);
    
    setState(() {
      listDropRelationship
        ..add({
          "id": "0",
          "genderTypeID": "0",
          "nameAr": localizations?.chooseRelationship ?? "Choose Relationship",
          "nameEn": localizations?.chooseRelationship ?? "Choose Relationship"
        });
    });

    setState(() {
      for (int i = 0; i < relationshipList.length; i++) {
        listDropRelationship
          ..add({
            "id": relationshipList.elementAt(i).id?.toString() ?? "0",
            "genderTypeID": relationshipList.elementAt(i).genderTypeID?.toString() ?? "0",
            "nameAr": relationshipList.elementAt(i).nameAr ?? "",
            "nameEn": relationshipList.elementAt(i).nameEn ?? ""
          });
      }
    });
  }

  genderDropDownData() async {
    final localizations = AppLocalizations.of(context);
    
    setState(() {
      listDropGender = [
        {
          "id": "0",
          "name": localizations?.male ?? "Male",
        },
        {
          "id": "1",
          "name": localizations?.female ?? "Female",
        },
      ];
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
  selectedDeaconRadioTile = isDeacon ?? 0;
  memberID = memberIDFromCon;
  churchOfAttendanceID = churchid;
  governorateID = governorateid;
  loadingState = 0;
  mobile = mobileGlobal;

  // 🔹 Exécuter après la 1ère frame pour garantir que Localizations est prêt
  WidgetsBinding.instance.addPostFrameCallback((_) {
    getDataFromShared();
  });
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

 // --- Récupère la liste des relations
Future<List<PersonRelation>?> getRelationships() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/Family/GetRelationships/'));
    if (response.statusCode == 200) {
      return personRelationFromJson(response.body);
    }
  } catch (e) {
    print('Error getting relationships: $e');
  }
  return null;
}

// --- Prépare la liste des gouvernorats pour le dropdown
Future<void> governoratesDropDownData() async {
  setState(() {
    listDropGovernorates.clear();
    listDropGovernorates.add({
      "id": "0",
      "nameAr": "اختار المحافظة",
      "nameEn": "Choose Governorate",
      "isDefualt": false
    });

    for (var governorate in governoratesList) {
      listDropGovernorates.add({
        "id": governorate.id?.toString() ?? "0",
        "nameAr": governorate.nameAr ?? "",
        "nameEn": governorate.nameEn ?? "",
        "isDefualt": governorate.isDefualt ?? false,
      });

      if (governorate.isDefualt == true) {
        governorateID = governorate.id?.toString() ?? "0";
      }
    }
  });
}

// --- Prépare la liste des églises pour le dropdown
Future<void> churchOfAttendanceDropDownData() async {
  setState(() {
    listDropChurchOfAttendance.clear();
    listDropChurchOfAttendance.add({
      "id": "0",
      "nameAr": "اختار الكنيسة",
      "nameEn": "Choose Church",
      "isDefualt": false
    });

    for (int i = 0; i < churchOfAttendanceList.length; i++) {
      listDropChurchOfAttendance.add({
        "id": churchOfAttendanceList[i].id?.toString() ?? "0",
        "nameAr": churchOfAttendanceList[i].nameAr ?? "",
        "nameEn": churchOfAttendanceList[i].nameEn ?? "",
        "isDefualt": churchOfAttendanceList[i].isDefualt ?? false
      });
    }
  });
}

// --- Vérifie l'ID national
Future<String> checkNationalID(String nationalID) async {
  print('nationalID: to send to CheckNationalID $nationalID');
  final response = await http.get(
      Uri.parse('$baseUrl/Users/CheckNationalID/?NationalID=$nationalID&IsMainPerson=$isMain'));
  print('$baseUrl/Users/CheckNationalID/?NationalID=$nationalID&IsMainPerson=$isMain');
  print(response.body);
  if (response.statusCode == 200) {
    var addFamilyMemberObj = addFamilyMemberFromJson(response.body.toString());
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

// --- Ajoute/édite un membre de la famille
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
  bool isDeacon = selectedDeaconRadioTile == 1;
  print('Deacon=$isDeacon');

  print('NationalID=$nationalID');
  print('Mobile=$mobile');
  print('UserAccountID=$userID');
  int flagAdd = isAdd ? 1 : 2;
  if (isAdd) {
    memberID = "";
  }

  print('flag=$flagAdd');
  print('AccountMemberID=$memberID');
  print('Token=$mobileToken');
  final response = await http.post(
      Uri.parse('$baseUrl/Family/AddEditFamilyMember/?Name=$fullName&relationID=${int.parse(relationshipID)}&Deacon=$isDeacon&NationalID=$nationalID&Mobile=$mobile&UserAccountID=$userID&GenderID=$gender&Ismain=$isMain&churchOfAttendance=$churchOfAttendance&Address=$address&BranchID=$churchOfAttendanceID&GovernerateID=$governorateID&flag=$flagAdd&AccountMemberID=$memberID&Token=$mobileToken'));
  print('$baseUrl/Family/AddEditFamilyMember/?Name=$fullName&relationID=${int.parse(relationshipID)}&Deacon=$isDeacon&NationalID=$nationalID&Mobile=$mobile&UserAccountID=$userID&GenderID=$gender&Ismain=$isMain&churchOfAttendance=$churchOfAttendance&Address=$address&BranchID=$churchOfAttendanceID&GovernerateID=$governorateID&flag=$flagAdd&AccountMemberID=$memberID&Token=$mobileToken');
  print(response.body);

  if (response.statusCode == 200) {
    var addFamilyMemberObj = addFamilyMemberFromJson(response.body.toString());
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

// --- Surcharge du cycle de vie
@override
void didChangeDependencies() {
  super.didChangeDependencies();

  final localizations = AppLocalizations.of(context);
  
  if (isAdd) {
    pageTitle = localizations?.addFamilyMember ?? "Add Family Member";
  } else {
    pageTitle = (isMain == 1)
        ? (localizations?.myProfile ?? "My Profile")
        : (localizations?.editFamilyMember ?? "Edit Family Member");
  }

  accountTypeDropDownData();
}

@override
void didUpdateWidget(AddFamilyMemberActivity oldWidget) {
  super.didUpdateWidget(oldWidget);
  
  // Refresh the UI when the widget updates (e.g., language change)
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      _refreshLocalizedData();
    }
  });
}

// Refresh localized data when language changes
void _refreshLocalizedData() {
  final localizations = AppLocalizations.of(context);
  
  if (isAdd) {
    pageTitle = localizations?.addFamilyMember ?? "Add Family Member";
  } else {
    pageTitle = (isMain == 1)
        ? (localizations?.myProfile ?? "My Profile")
        : (localizations?.editFamilyMember ?? "Edit Family Member");
  }
  
  // Refresh dropdown data with new language
  accountTypeDropDownData();
  genderDropDownData();
  relationShipDropDownData();
  
  setState(() {
    // Trigger UI rebuild
  });
}

// --- Dropdown pour le type de compte
Future<void> accountTypeDropDownData() async {
  final localizations = AppLocalizations.of(context);
  if (localizations == null) return;
  if (!mounted) return;

  setState(() {
    listDropAccountType = [
      {"id": "0", "name": localizations.family},
      {"id": "1", "name": localizations.personal},
    ];
  });
}

// --- Récupère toutes les données du SharedPreferences et prépare l'UI
Future<void> getDataFromShared() async {
  saveState = 0;
  
  if (!mounted) return;
  
  setState(() {
    loadingState = 0; // Set loading state
  });

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  myLanguage = prefs.getString('language') ?? "en";
  familyAccount = prefs.getString("accountType") ?? "";
  userID = prefs.getString("userID") ?? "";
  email = prefs.getString("email") ?? "";

  final connectionResponse = await _checkInternetConnection();
  print("connectionResponse: $connectionResponse");

  if (connectionResponse != '1') {
    if (mounted) {
      setState(() {
        loadingState = 1; // Set loaded state
      });
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => NoInternetConnectionActivity()),
      );
    }
    return;
  }

  // Load user's profile data if this is being used as profile page
  if (isMain == 1 && !isAdd) {
    await _loadUserProfileData();
  }

  if (isPersonal) {
    myFamilyList = (await getMyFamily()) ?? [];
    if (myFamilyList.isNotEmpty) {
      myFamilyListViewData();
    }
  }

  if (churchOfAttendanceID.isEmpty) {
    churchOfAttendanceID = "-1";
    edited = true;
  } else {
    edited = false;
  }

  showChurchOfAttendanceOthersState = (churchOfAttendance?.isNotEmpty ?? false);

  customControllerName.nameController.text = name;
  customControllerMobile.mobileController.text = mobile;
  customControllerID.iDController.text = nationalID;
  customControllerAddress.addressController.text = address ?? "";
  customControllerChurchOfAttendance.text = churchOfAttendance ?? "";

  if (!mounted) return;

  setState(() {
    accountTypeID = "0";
    checkBoxValue = false;
    genderState = true;
    accountTypeState = true;
    showChurchOfAttendanceState = false;
    relationshipState = true;

    if (familyAccount == "1") {
      showRelationShipState = true;
      showGenderState = false;
      showDeaconRadioButtonState =
          ["1", "3", "5", "7"].contains(relationshipID);
    } else {
      showRelationShipState = false;
      showGenderState = true;
      showDeaconRadioButtonState = (selectedGenderRadioTile == 1);
    }
  });

  await accountTypeDropDownData();
  await genderDropDownData();
  governoratesList = (await getGovernoratesByUserID()) ?? [];
  await governoratesDropDownData();
  churchOfAttendanceList = (await getChurchs(governorateID)) ?? [];
  await churchOfAttendanceDropDownData();
  relationshipList = (await getRelationships()) ?? [];
  await relationShipDropDownData();

  if (mounted) {
    setState(() {
      loadingState = 1; // Set loaded state
    });
  }
}

// Load user's profile data from the API
Future<void> _loadUserProfileData() async {
  try {
    // Ensure we have a token before making the API call
    if (mobileToken == null) {
      debugPrint('⚠️ No Firebase token available, getting token first...');
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        mobileToken = token;
        debugPrint('✅ Firebase token retrieved: ${token.substring(0, 20)}...');
      } else {
        debugPrint('❌ Failed to get Firebase token');
        return;
      }
    }
    
    final url = '$baseUrl/Family/GetFamilyMembers/?UserID=$userID&Token=$mobileToken';
    debugPrint('🔍 Loading profile from: $url');
    var response = await http.get(Uri.parse(url));
    
    debugPrint('📱 Profile API Status: ${response.statusCode}');
    debugPrint('📱 Profile API Response: ${response.body}');
    
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      var familyMembers = familyMemberFromJson(response.body.toString());
      debugPrint('👥 Total family members found: ${familyMembers.length}');
      
      // Find the main person (user's profile)
      FamilyMember? userProfile;
      for (var member in familyMembers) {
        debugPrint('👤 Member: ${member.accountMemberNameAr}, IsMain: ${member.isMainPerson}');
        debugPrint('   📞 Mobile: ${member.mobile}');
        debugPrint('   🆔 NationalID: ${member.nationalIdNumber}');
        debugPrint('   🏠 Address: ${member.address}');
        debugPrint('   ⚧ Gender: ${member.genderTypeId}');
        debugPrint('   ⛪ Church: ${member.churchOfAttendance}');
        
        if (member.isMainPerson == true) {
          userProfile = member;
          debugPrint('✅ Found main person profile!');
          break;
        }
      }
      
      if (userProfile != null) {
        debugPrint('🔄 Setting profile data...');
        setState(() {
          name = userProfile!.accountMemberNameAr ?? "";
          nationalID = userProfile.nationalIdNumber ?? "";
          mobile = userProfile.mobile ?? "";
          address = userProfile.address ?? "";
          
          debugPrint('📝 Set name: $name');
          debugPrint('📝 Set nationalID: $nationalID');
          debugPrint('📝 Set mobile: $mobile');
          debugPrint('📝 Set address: $address');
          
          // Convert bool to int for isDeacon (0 for false, 1 for true)
          selectedDeaconRadioTile = (userProfile.isDeacon == true) ? 1 : 0;
          
          // Convert String genderTypeId to int
          if (userProfile.genderTypeId != null) {
            selectedGenderRadioTile = int.tryParse(userProfile.genderTypeId!) ?? 0;
          } else {
            selectedGenderRadioTile = 0;
          }
          
          // Set the relationship ID if available
          if (userProfile.personRelationId != null) {
            relationshipID = userProfile.personRelationId!;
          }
          
          // Set governorate ID if available
          if (userProfile.governorateID != null) {
            governorateID = userProfile.governorateID!;
          }
          
          // Set church of attendance if available
          if (userProfile.churchOfAttendance != null) {
            churchOfAttendance = userProfile.churchOfAttendance!;
          }
          
          // Update the member ID for editing
          memberID = userProfile.userAccountMemberId ?? "";
        });
        
        print("Loaded user profile: $name, $nationalID, $mobile");
      }
    }
  } catch (e) {
    print("Error loading user profile data: $e");
  }
}

// --- Met à jour la liste de la famille affichée (pour le ListView)
void myFamilyListViewData() {
  setState(() {
    listViewMyFamily.clear();
    for (int i = 0; i < myFamilyList.length; i++) {
      listViewMyFamily.add({
        "userAccountMemberId": myFamilyList[i].userAccountMemberId,
        "userAccountId": myFamilyList[i].userAccountId,
        "accountMemberNameAr": myFamilyList[i].accountMemberNameAr,
        "genderTypeId": myFamilyList[i].genderTypeId,
        "genderTypeNameAr": myFamilyList[i].genderTypeNameAr,
        "genderTypeNameEn": myFamilyList[i].genderTypeNameEn,
        "isDeacon": myFamilyList[i].isDeacon,
        "nationalIdNumber": myFamilyList[i].nationalIdNumber,
        "mobile": myFamilyList[i].mobile,
        "personRelationId": myFamilyList[i].personRelationId,
        "personRelationNameAr": myFamilyList[i].personRelationNameAr,
        "personRelationNameEn": myFamilyList[i].personRelationNameEn,
        "isMainPerson": myFamilyList[i].isMainPerson,
      });
    }
  });
}
@override
Widget build(BuildContext context) {
  final localizations = AppLocalizations.of(context);
  
  return Scaffold(
    appBar: AppBar(
      title: Text(pageTitle),
      backgroundColor: primaryDarkColor,
      foregroundColor: Colors.white,
    ),
    body: loadingState == 0 
      ? Center(child: CircularProgressIndicator())
      : Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name Field
                  TextFormField(
                    controller: customControllerName.nameController,
                    decoration: InputDecoration(
                      labelText: localizations?.fullNameWithAstric ?? "Full Name*",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizations?.pleaseEnterYourFullName ?? "Please enter your name";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      name = value;
                    },
                  ),
                  SizedBox(height: 16),
                  
                  // National ID Field
                  TextFormField(
                    controller: customControllerID.iDController,
                    decoration: InputDecoration(
                      labelText: localizations?.nationalIdWithAstric ?? "National ID*",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizations?.pleaseEnterYourNationalId ?? "Please enter your National ID";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      nationalID = value;
                    },
                  ),
                  SizedBox(height: 16),
                  
                  // Mobile Field
                  TextFormField(
                    controller: customControllerMobile.mobileController,
                    decoration: InputDecoration(
                      labelText: localizations?.mobileWithAstric ?? "Mobile*",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return localizations?.pleaseEnterYourMobile ?? "Please enter your mobile";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      mobile = value;
                    },
                  ),
                  SizedBox(height: 16),
                  
                  // Address Field
                  TextFormField(
                    controller: customControllerAddress.addressController,
                    decoration: InputDecoration(
                      labelText: localizations?.addressWithAstric ?? "Address*",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      address = value;
                    },
                  ),
                  SizedBox(height: 16),
                  
                  // Church of Attendance Field (if applicable)
                  if (showChurchOfAttendanceOthersState)
                    TextFormField(
                      controller: customControllerChurchOfAttendance,
                      decoration: InputDecoration(
                        labelText: localizations?.churchOfAttendanceWithAstric ?? "Church of Attendance*",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) {
                        churchOfAttendance = value;
                      },
                    ),
                  
                  if (showChurchOfAttendanceOthersState) SizedBox(height: 16),
                  
                  // Gender Selection (for personal accounts)
                  if (showGenderState && listDropGender.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations?.genderWithAstric ?? "Gender*",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...listDropGender.map((gender) {
                          return RadioListTile<int>(
                            title: Text(gender['name']),
                            value: int.parse(gender['id']),
                            groupValue: selectedGenderRadioTile,
                            onChanged: (value) {
                              setState(() {
                                selectedGenderRadioTile = value;
                                showDeaconRadioButtonState = (value == 1); // Show deacon options for males
                              });
                            },
                          );
                        }).toList(),
                        SizedBox(height: 16),
                      ],
                    ),
                  
                  // Relationship Selection (for family accounts)
                  if (showRelationShipState && listDropRelationship.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations?.relationshipWithAstric ?? "Relationship*",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: relationshipID == "0" ? null : relationshipID,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: listDropRelationship.map((relationship) {
                            return DropdownMenuItem<String>(
                              value: relationship['id'],
                              child: Text(
                                myLanguage == "ar" 
                                  ? relationship['nameAr'] 
                                  : relationship['nameEn']
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              relationshipID = value ?? "0";
                              // Update deacon visibility based on relationship
                              showDeaconRadioButtonState = ["1", "3", "5", "7"].contains(relationshipID);
                            });
                          },
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  
                  // Deacon Selection
                  if (showDeaconRadioButtonState)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations?.deaconWithAstric ?? "Deacon*",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        RadioListTile<int>(
                          title: Text(localizations?.yes ?? "Yes"),
                          value: 1,
                          groupValue: selectedDeaconRadioTile,
                          onChanged: (value) {
                            setState(() {
                              selectedDeaconRadioTile = value!;
                            });
                          },
                        ),
                        RadioListTile<int>(
                          title: Text(localizations?.no ?? "No"),
                          value: 0,
                          groupValue: selectedDeaconRadioTile,
                          onChanged: (value) {
                            setState(() {
                              selectedDeaconRadioTile = value!;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  
                  // Governorate Dropdown
                  if (listDropGovernorates.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations?.governorate ?? "Governorate",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: governorateID == "0" ? null : governorateID,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: listDropGovernorates.map((governorate) {
                            return DropdownMenuItem<String>(
                              value: governorate['id'],
                              child: Text(
                                myLanguage == "ar" 
                                  ? governorate['nameAr'] 
                                  : governorate['nameEn']
                              ),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            setState(() {
                              governorateID = value ?? "0";
                            });
                            // Load churches for selected governorate
                            if (governorateID != "0") {
                              churchOfAttendanceList = await getChurchs(governorateID) ?? [];
                              await churchOfAttendanceDropDownData();
                            }
                          },
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  
                  // Church Dropdown
                  if (listDropChurchOfAttendance.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations?.church ?? "Church",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: churchOfAttendanceID == "0" ? null : churchOfAttendanceID,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: listDropChurchOfAttendance.map((church) {
                            return DropdownMenuItem<String>(
                              value: church['id'],
                              child: Text(
                                myLanguage == "ar" 
                                  ? church['nameAr'] 
                                  : church['nameEn']
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              churchOfAttendanceID = value ?? "0";
                            });
                          },
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  
                  // Error Message
                  if (errorMessage != null && errorMessage!.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  
                  // Save Button
                  ElevatedButton(
                    onPressed: saveState == 1 ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          saveState = 1;
                          errorMessage = "";
                        });
                        
                        // Check National ID first
                        String checkResult = await checkNationalID(nationalID);
                        if (checkResult == "0") {
                          // Proceed with save
                          String result = await addEditFamilyMember(name, nationalID, mobile);
                          setState(() {
                            saveState = 0;
                          });
                          
                          if (result == "1") {
                            Fluttertoast.showToast(
                              msg: localizations?.addedSuccessfully ?? "Saved successfully",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                            Navigator.of(context).pop(true);
                          } else {
                            Fluttertoast.showToast(
                              msg: errorMessage ?? (localizations?.errorConnectingWithServer ?? "An error occurred"),
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                          }
                        } else {
                          setState(() {
                            saveState = 0;
                          });
                          Fluttertoast.showToast(
                            msg: errorMessage ?? (localizations?.errorConnectingWithServer ?? "An error occurred"),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDarkColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: saveState == 1 
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(localizations?.pleaseWait ?? "Please wait...")
                          ],
                        )
                      : Text(
                          localizations?.save ?? "Save",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                  ),
                ],
              ),
            ),
          ),
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

