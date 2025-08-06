import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Home/homeActivity.dart';
import 'package:egpycopsversion4/Home/myBookingsFragment.dart';
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
  


  relationShipDropDownData() async {
    setState(() {
      listDropRelationship
        ..add({
          "id": "0",
          "genderTypeID": "0",
          "nameAr": AppLocalizations.of(context)?.chooseRelationship ?? "Choose Relationship",
"nameEn": AppLocalizations.of(context)?.chooseRelationship ?? "Choose Relationship"

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
  listDropGender = [
    {
      "id": "0",
      "name": AppLocalizations.of(context)?.male ?? "Male",
    },
    {
      "id": "1",
      "name": AppLocalizations.of(context)?.female ?? "Female",
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
  selectedDeaconRadioTile = isDeacon!;
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
  
// --- Surcharge du cycle de vie
@override
void didChangeDependencies() {
  super.didChangeDependencies();

  if (isAdd) {
    pageTitle =
        AppLocalizations.of(context)?.addFamilyMember ?? "Add Family Member";
  } else {
    pageTitle = (isMain == 1)
        ? (AppLocalizations.of(context)?.myProfile ?? "My Profile")
        : (AppLocalizations.of(context)?.editFamilyMember ?? "Edit Family Member");
  }

  accountTypeDropDownData();
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

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  myLanguage = prefs.getString('language') ?? "en";
  familyAccount = prefs.getString("accountType") ?? "";
  userID = prefs.getString("userID") ?? "";
  email = prefs.getString("email") ?? "";

  final connectionResponse = await _checkInternetConnection();
  print("connectionResponse: $connectionResponse");

  if (connectionResponse != '1') {
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => NoInternetConnectionActivity()),
      );
    }
    return;
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
  // Ton code ici
  return Scaffold(
    appBar: AppBar(
      title: Text(pageTitle),
      backgroundColor: primaryDarkColor,
    ),
    body: myFamilyList.isEmpty
      ? Center(child: CircularProgressIndicator())
      : ListView.builder(
          itemCount: myFamilyList.length,
          itemBuilder: (context, index) {
            final member = myFamilyList[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  member.accountMemberNameAr ?? '',
                  style: TextStyle(fontFamily: 'cocon-next-arabic-regular'),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('الرقم القومي: ${member.nationalIdNumber ?? ""}',
                        style: TextStyle(fontFamily: 'cocon-next-arabic-regular')),
                    Text('رقم الهاتف: ${member.mobile ?? ""}',
                        style: TextStyle(fontFamily: 'cocon-next-arabic-regular')),
                    Text('العلاقة: ${member.personRelationNameAr ?? ""}',
                        style: TextStyle(fontFamily: 'cocon-next-arabic-regular')),
                  ],
                ),
              ),
            );
          },
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

