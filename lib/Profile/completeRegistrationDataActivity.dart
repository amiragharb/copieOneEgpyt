import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Booking/newBookingActivity.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Family/addFamilyMemberActivity.dart' hide myLanguage;
import 'package:egpycopsversion4/Home/homeActivity.dart' hide userID;
import 'package:egpycopsversion4/Models/addFamilyMember.dart';
import 'package:egpycopsversion4/Models/churchs.dart';
import 'package:egpycopsversion4/Models/governorates.dart';
import 'package:egpycopsversion4/Models/personRelation.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Translation/localizations.dart' hide AppLocalizations;
import 'package:egpycopsversion4/l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

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

    await getDataFromShared();
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
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppLocalizations.of(context)?.completeInformation ?? "Complete Information",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
        ),
        backgroundColor: primaryDarkColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              showRelationshipLayout(context),
              const SizedBox(height: 20),
              showDeaconCheckboxLayout(),
              const SizedBox(height: 40),
              buildRegisterButtonWidget(),
            ],
          ),
        ),
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
          style: const TextStyle(fontSize: 20.0, color: Colors.black),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: relationshipID,
          isExpanded: true,
          items: listDropRelationship.map((map) {
            return DropdownMenuItem<String>(
              value: map["id"].toString(),
              child: Text(
                myLanguage == "ar" ? map["nameAr"] : map["nameEn"],
                style: TextStyle(
                  color: primaryDarkColor,
                  fontSize: 20.0,
                  fontFamily: 'cocon-next-arabic-regular',
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
        if (!relationshipState)
          Text(
            AppLocalizations.of(context)?.pleaseChooseRelationship ??
                "Please choose a relationship",
            style: TextStyle(fontSize: 12.0, color: red700),
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
            fontSize: 20.0,
            fontFamily: 'cocon-next-arabic-regular',
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        Row(
          children: [
            Flexible(
              child: RadioListTile(
                value: 1,
                groupValue: selectedDeaconRadioTile,
                title: Text(AppLocalizations.of(context)!.yes),
                onChanged: (val) => setSelectedDeaconRadioTile(val ?? 0),
                activeColor: accentColor,
              ),
            ),
            Flexible(
              child: RadioListTile(
                value: 2,
                groupValue: selectedDeaconRadioTile,
                title: Text(AppLocalizations.of(context)!.no),
                onChanged: (val) => setSelectedDeaconRadioTile(val ?? 0),
                activeColor: accentColor,
              ),
            ),
          ],
        ),
        if (!deaconState)
          Text(
            AppLocalizations.of(context)!.pleaseChooseDeacon,
            style: TextStyle(fontSize: 14.0, color: red700),
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
          // 🔹 Logique d’enregistrement ici
        },
        child: registerState == 1
            ? const SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                AppLocalizations.of(context)?.save ?? "Save",
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
              ),
      ),
    );
  }

  void setSelectedDeaconRadioTile(int value) {
    setState(() => selectedDeaconRadioTile = value);
  }


  Widget showGovernoratesLayout( BuildContext context) 
  {
    if (governorateState) {
      if (myLanguage == "en") 
      {
       
        return Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.governorate,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: new DropdownButton(
                    value: governorateID,
                    isExpanded: true,
                    items: listDropGovernorates.map((Map map) {
                      return DropdownMenuItem<String>(
                        value: map["id"].toString(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 5.0, right: 5.0),
                              child: new MyBullet(),
                            ),
                            Expanded(
                              child: Text(
                                map["nameEn"],
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  color: primaryDarkColor,
                                  fontSize: 20.0,
                                  fontFamily: 'cocon-next-arabic-regular',
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        governorateID = value!;

                        showChurchOfAttendanceState = false;
                        showChurchOfAttendanceOthersState = false;
                        churchOfAttendanceID = "0";
                        if (value != 0) {
                          getChurchWithGovernorate();
                        }

                        print("governorateID : $governorateID");
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.governorate,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: new DropdownButton(
                    value: governorateID,
                    isExpanded: true,
                    items: listDropGovernorates.map((Map map) {
                      return DropdownMenuItem<String>(
                        value: map["id"].toString(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 5.0, right: 5.0),
                              child: new MyBullet(),
                            ),
                            Expanded(
                              child: Text(
                                map["nameAr"],
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  color: primaryDarkColor,
                                  fontSize: 20.0,
                                  fontFamily: 'cocon-next-arabic-regular',
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        governorateID = value!;

                        showChurchOfAttendanceState = false;
                        showChurchOfAttendanceOthersState = false;
                        churchOfAttendanceID = "0";
                        if (value != 0) {
                          getChurchWithGovernorate();
                        }

                        print("governorateID : $governorateID");
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      if (myLanguage == "en") {
        return Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.governorate,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: new DropdownButton(
                    value: governorateID,
                    isExpanded: true,
                    items: listDropGovernorates.map((Map map) {
                      return DropdownMenuItem<String>(
                        value: map["id"].toString(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 5.0, right: 5.0),
                              child: new MyBullet(),
                            ),
                            Expanded(
                              child: Text(
                                map["nameEn"],
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  color: primaryDarkColor,
                                  fontSize: 20.0,
                                  fontFamily: 'cocon-next-arabic-regular',
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        governorateID = value!;

                        showChurchOfAttendanceState = false;
                        showChurchOfAttendanceOthersState = false;
                        churchOfAttendanceID = "0";
                        if (value != 0) {
                          getChurchWithGovernorate();
                        }

                        print("governorateID : $governorateID");
                      });
                    },
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.pleaseChooseGovernorate,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: red700,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.governorate,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: new DropdownButton(
                    value: governorateID,
                    isExpanded: true,
                    items: listDropGovernorates.map((Map map) {
                      return DropdownMenuItem<String>(
                        value: map["id"].toString(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 5.0, right: 5.0),
                              child: new MyBullet(),
                            ),
                            Expanded(
                              child: Text(
                                map["nameAr"],
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  color: primaryDarkColor,
                                  fontSize: 20.0,
                                  fontFamily: 'cocon-next-arabic-regular',
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        governorateID = value!;

                        showChurchOfAttendanceState = false;
                        showChurchOfAttendanceOthersState = false;
                        churchOfAttendanceID = "0";
                        if (value != 0) {
                          getChurchWithGovernorate();
                        }

                        print("governorateID : $governorateID");
                      });
                    },
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.pleaseChooseGovernorate,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: red700,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
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
  }
}

  Widget showChurchOfAttendanceLayout() {
    if (churchState) {
      if (myLanguage == "en") {
        if (showChurchOfAttendanceState) {
          return Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
            child: Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.churchOfAttendanceWithAstric,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: new DropdownButton(
                      value: churchOfAttendanceID,
                      isExpanded: true,
                      itemHeight: 90,
                      items: listDropChurchOfAttendance.map((Map map) {
                        return DropdownMenuItem<String>(
                          value: map["id"].toString(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 5.0, right: 5.0),
                                child: new MyBullet(),
                              ),
                              Expanded(
                                child: Text(
                                  map["nameEn"],
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    color: primaryDarkColor,
                                    fontSize: 20.0,
                                    fontFamily: 'cocon-next-arabic-regular',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
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
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      } else {
        if (showChurchOfAttendanceState) {
          return Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
            child: Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.churchOfAttendanceWithAstric,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: new DropdownButton(
                      value: churchOfAttendanceID,
                      itemHeight: 90,
                      isExpanded: true,
                      items: listDropChurchOfAttendance.map((Map map) {
                        return DropdownMenuItem<String>(
                          value: map["id"].toString(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 5.0, right: 5.0),
                                child: new MyBullet(),
                              ),
                              Expanded(
                                child: Text(
                                  map["nameAr"],
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    color: primaryDarkColor,
                                    fontSize: 20.0,
                                    fontFamily: 'cocon-next-arabic-regular',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
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
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      }
    } else {
      if (myLanguage == "en") {
        if (showChurchOfAttendanceState) {
          return Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
            child: Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.churchOfAttendanceWithAstric,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: new DropdownButton(
                      value: churchOfAttendanceID,
                      isExpanded: true,
                      itemHeight: 90,
                      items: listDropChurchOfAttendance.map((Map map) {
                        return DropdownMenuItem<String>(
                          value: map["id"].toString(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 5.0, right: 5.0),
                                child: new MyBullet(),
                              ),
                              Expanded(
                                child: Text(
                                  map["nameEn"],
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    color: primaryDarkColor,
                                    fontSize: 20.0,
                                    fontFamily: 'cocon-next-arabic-regular',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
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
                  Text(
                    AppLocalizations.of(context)!.pleaseChooseChurch,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: red700,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      } else {
        if (showChurchOfAttendanceState) {
          return Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
            child: Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.churchOfAttendanceWithAstric,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: new DropdownButton(
                      value: churchOfAttendanceID,
                      itemHeight: 90,
                      isExpanded: true,
                      items: listDropChurchOfAttendance.map((Map map) {
                        return DropdownMenuItem<String>(
                          value: map["id"].toString(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 5.0, right: 5.0),
                                child: new MyBullet(),
                              ),
                              Expanded(
                                child: Text(
                                  map["nameAr"],
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(
                                    color: primaryDarkColor,
                                    fontSize: 20.0,
                                    fontFamily: 'cocon-next-arabic-regular',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
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
                  Text(
                    AppLocalizations.of(context)!.pleaseChooseChurch,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: red700,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      }
    }
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


  Future<String> _checkInternetConnection() async {
    String connectionResult;
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      connectionResult = "0";
    } else {
      connectionResult = "1";
    }
    return connectionResult;
  }}


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
