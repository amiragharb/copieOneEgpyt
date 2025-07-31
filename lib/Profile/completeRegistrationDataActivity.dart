import 'dart:convert';


import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Models/churchs.dart';
import 'package:egpycopsversion4/Models/governorates.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';


BaseUrl BASE_URL = new BaseUrl();
String baseUrl = BASE_URL.BASE_URL;
String myLanguage  = "";
String fullName = "",
    mobile = "",
    address = "",
    churchOfAttendance = "",
    nationalID = "";
String relationshipID = "0";
String churchOfAttendanceID = "0";
String governorateID = "0";
bool relationshipState = true;
String accountType = "";

bool isFamilyAccount=false;
String genderID = "0";
String userID = "";
bool checkBoxValue = false;
bool genderState = true;
bool deaconState = true;
bool governorateState = true;
bool churchState = true;
//Animation _animationLogin;

int registerState = 0;

//int selectedGenderRadioTile;
//int selectedDeaconRadioTile;

class CompleteRegistrationDataActivity extends StatefulWidget {
  CompleteRegistrationDataActivity(String accountType);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
 /* CompleteRegistrationDataActivity(String accountType) {
    print("accountType $accountType");
    if (accountType == "1") {
      isFamilyAccount = true;
    } else {
      isFamilyAccount = false;
    }
  }

  @override
  CompleteRegistrationDataActivityState createState() =>
      new CompleteRegistrationDataActivityState();
}

class CompleteRegistrationDataActivityState
    extends State<CompleteRegistrationDataActivity> {
  SpecificLocalizationDelegate _specificLocalizationDelegate;

  @override
  void initState() {
    super.initState();
    helper.onLocaleChanged = onLocaleChange;
    _specificLocalizationDelegate =
        SpecificLocalizationDelegate(new Locale(languageHome));
  }

  onLocaleChange(Locale locale) {
    setState(() {
      _specificLocalizationDelegate = new SpecificLocalizationDelegate(locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        new FallbackCupertinoLocalisationsDelegate(),
        //app-specific localization
        _specificLocalizationDelegate
      ],
      supportedLocales: [Locale('en'), Locale('ar')],
      locale: _specificLocalizationDelegate.overriddenLocale,
      debugShowCheckedModeBanner: false,
      builder: (BuildContext context, Widget child) {
        return new Builder(
          builder: (BuildContext context) {
            return new MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0,
              ),
              child: child,
            );
          },
        );
      },
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        accentColor: accentColor,
        fontFamily: 'cocon-next-arabic-regular',
      ),
      home: CompleteRegistrationDataPageActivity(title: 'EGY Copts'),
    );
  }
}

class CompleteRegistrationDataPageActivity extends StatefulWidget {
  CompleteRegistrationDataPageActivity({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _CompleteRegistrationDataPageActivityState createState() =>
      _CompleteRegistrationDataPageActivityState();
}

class _CompleteRegistrationDataPageActivityState
    extends State<CompleteRegistrationDataPageActivity>
    with TickerProviderStateMixin {
  String mobileToken;
  bool showDeaconRadioButtonState = false;
  bool showGenderState = false;
  bool showRelationShipState = false;
  bool showChurchOfAttendanceState = false;
  bool showChurchOfAttendanceOthersState = false;
  List<Churchs> churchOfAttendanceList = new List<Churchs>();
  List<Governorates> governoratesList = new List<Governorates>();

  MyCustomControllerFullName customControllerFullName =
      MyCustomControllerFullName(fullNameController: TextEditingController());

  MyCustomControllerID customControllerID =
      MyCustomControllerID(iDController: TextEditingController());

  MyCustomControllerAddress customControllerAddress =
      MyCustomControllerAddress(addressController: TextEditingController());
  SpecificLocalizationDelegate _specificLocalizationDelegate;

  MyCustomControllerChurchOfAttendance customControllerChurchOfAttendance =
      MyCustomControllerChurchOfAttendance(
          churchOfAttendanceController: TextEditingController());

  MyCustomControllerMobile customControllerMobile =
      MyCustomControllerMobile(mobileController: TextEditingController());

  var _formKey = GlobalKey<FormState>();

  List<Map> listDropGender = [];
  List<Map> listDropRelationship = [];
  List<Map> listDropChurchOfAttendance = [];
  List<Map> listDropGovernorates = [];
  List<PersonRelation> relationshipList = [];

  String errorMessage;

  Future<List<PersonRelation>> getRelationships() async {
    var response = await http.get('$baseUrl/Family/GetPersonRelations/');
    print('$baseUrl/Family/GetPersonRelations/');
    print(response.body);
    if (response.statusCode == 200) {
      print('GetPersonRelations= response.statusCode ${response.statusCode}');
      var personRelationObj = personRelationFromJson(response.body.toString());
      print('jsonResponse $personRelationObj');
      return personRelationObj;
    } else {
      print("GetPersonRelations error");
      print('GetPersonRelations= response.statusCode ${response.statusCode}');
      return null;
    }
  }

  relationShipDropDownData() async {

    listDropRelationship.clear();

    setState(() {
      listDropRelationship
        ..add({
          "id": "0",
          "genderTypeID": 0,
          "nameAr": AppLocalizations.of(context).chooseRelationship,
          "nameEn": AppLocalizations.of(context).chooseRelationship
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
    //   listDropRelationship
    //     ..add({"id": "1", "name": AppLocalizations.of(context).husband});
    //   listDropRelationship
    //     ..add({"id": "2", "name": AppLocalizations.of(context).wife});
    //   listDropRelationship
    //     ..add({"id": "3", "name": AppLocalizations.of(context).son});
    //   listDropRelationship
    //     ..add({"id": "4", "name": AppLocalizations.of(context).daughter});
    });
  }

  @override
  void initState() {
    super.initState();
    helper.onLocaleChanged = onLocaleChange;
    _specificLocalizationDelegate =
        SpecificLocalizationDelegate(new Locale(languageHome));
    FirebaseMessaging.instance.getToken().then((String token) {
      print("Token  " + token);
      mobileToken = token;
    });
    errorMessage = "";
    getDataFromShared();
  }

  void animateButton() {
    var controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animationLogin = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.forward();
    setState(() {
      registerState = 1;
    });
  }

  Widget buildRegisterButton() {
    if (registerState == 1) {
      return SizedBox(
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(
            value: null,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ));
    } else {
      return Text(
        AppLocalizations.of(context).save,
        style: TextStyle(
          fontSize: 18.0,
          fontFamily: 'cocon-next-arabic-regular',
          fontWeight: FontWeight.normal,
        ),
      );
    }
  }

  getDataFromShared() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    myLanguage = (prefs.getString('language') ?? "en");
    accountType = prefs.getString("accountType");

    userID = prefs.getString("userID");
    print('userID: $userID');
    String connectionResponse = await _checkInternetConnection();
    print("connectionResponse");
    print(connectionResponse);
    print("isFamilyAccount $isFamilyAccount");
    if (isFamilyAccount) {
      showGenderState = false;
      showRelationShipState = true;
      showDeaconRadioButtonState = false;
    } else {
      showGenderState = true;
      showRelationShipState = false;
      showDeaconRadioButtonState = false;
    }
    setState(() {
      genderID = "0";
      checkBoxValue = false;
      selectedGenderRadioTile = 0;
      selectedDeaconRadioTile = 0;

      genderState = true;
      deaconState = true;
      governorateState = true;

      showChurchOfAttendanceState = false;
      showChurchOfAttendanceOthersState = false;
      churchState = true;
    });


    relationshipList = await getRelationships();
    await relationShipDropDownData();

    governoratesList = await getGovernoratesByUserID();

    await governoratesDropDownData();
    churchOfAttendanceList = await getChurchs(governorateID);
    await churchOfAttendanceDropDownData();
  }

  onLocaleChange(Locale locale) {
    setState(() {
      _specificLocalizationDelegate = new SpecificLocalizationDelegate(locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.white),
        brightness: Brightness.dark,
        title: Padding(
          padding: const EdgeInsets.all(2.0),
          child: new Text(
            AppLocalizations.of(context).completeInformation,
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
          ),
        ),
        backgroundColor: primaryDarkColor,
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                  child: Container(
                    width: double.infinity,
                    child: MyCustomTextFieldFullName(
                      customController: customControllerFullName,
                    ),
                  ),
                ),
                showRelationshipLayout(),
                gender(),
                showDeaconCheckboxLayout(),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                  child: Container(
                    width: double.infinity,
                    child: MyCustomTextFieldID(
                      customController: customControllerID,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                  child: Container(
                    width: double.infinity,
                    child: MyCustomTextFieldMobile(
                      customController: customControllerMobile,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
                  child: Container(
                    width: double.infinity,
                    child: MyCustomTextFieldAddress(
                      customController: customControllerAddress,
                    ),
                  ),
                ),
                showGovernoratesLayout(),
                showChurchOfAttendanceLayout(),
                showChurchOfAttendanceOthers(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 20.0, bottom: 20.0, right: 20.0, left: 20.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50.0,
                      child: FlatButton(
                        child: buildRegisterButton(),
                        onPressed: () async {
                          if (isFamilyAccount) {
                            print("familyAccount");
                            setState(() {
                              genderState = true;
                            });
                            if (relationshipID == "0") {
                              print("relationshipID $relationshipID");

                              setState(() {
                                relationshipState = false;
                              });
                            } else {
                              print("relationshipID $relationshipID");

                              setState(() {
                                relationshipState = true;
                              });
                            }

                            for(int i =0 ; i<listDropRelationship.length; i++){
                              if(listDropRelationship[i]["id"].toString() == relationshipID.toString()){
                                if(listDropRelationship[i]["genderTypeID"]==1 && selectedDeaconRadioTile == 0){
                                  print("deaconState = false");
                                  setState(() { deaconState = false;});
                                }else {
                                  print("deaconState = true");
                                  setState(() {deaconState = true;});
                                }
                              }
                            }
                            // if ((relationshipID == "1" || relationshipID == "3" || relationshipID == "5" || relationshipID == "7")
                            //     && selectedDeaconRadioTile == 0) {
                            //   print("deaconState = false");
                            //   setState(() {deaconState = false;});
                            // } else {
                            //   print("deaconState = true");
                            //   setState(() {deaconState = true;});
                            // }
                          } else {
                            print("personalAccount");
                            setState(() {
                              relationshipState = true;
                            });
                            if (selectedGenderRadioTile == 0) {
                              print(
                                  "selectedGenderRadioTile = $selectedGenderRadioTile");

                              setState(() {
                                genderState = false;
                              });
                            } else {
                              print(
                                  "selectedGenderRadioTile = $selectedGenderRadioTile");

                              setState(() {
                                genderState = true;
                              });
                            }
                            if (selectedGenderRadioTile != 0 &&
                                selectedDeaconRadioTile == 0 &&
                                selectedGenderRadioTile != 2) {
                              setState(() {
                                deaconState = false;
                              });
                            } else {
                              setState(() {
                                deaconState = true;
                              });
                            }
                          }
                          if (governorateID == "0") {
                            print("governorateID = $governorateID");

                            setState(() {
                              governorateState = false;
                            });
                          } else {
                            print("governorateID = $governorateID");

                            setState(() {
                              governorateState = true;
                            });
                          }
                          if (churchOfAttendanceID == "0") {
                            print(
                                "churchOfAttendanceID = $churchOfAttendanceID");

                            setState(() {
                              churchState = false;
                            });
                          } else {
                            print(
                                "churchOfAttendanceID = $churchOfAttendanceID");

                            setState(() {
                              churchState = true;
                            });
                          }
                          print("genderState = $genderState");
                          print("deaconState = $deaconState");
                          print("governorateState = $governorateState");
                          print("churchState = $churchState");
                          print("relationshipState = $relationshipState");

                          if (genderState &&
                              deaconState &&
                              governorateState &&
                              churchState &&
                              relationshipState) {
                            print("validate");

                            if (_formKey.currentState.validate()) {
//                            if (accountTypeID == "2" && genderID != "0") {
                              String connectionResponse =
                                  await _checkInternetConnection();
                              print("connectionResponse");
                              print(connectionResponse);
                              if (connectionResponse == '1') {
                                if (registerState == 0 || registerState == 2) {
                                  animateButton();
                                }
                                customControllerMobile.enable = false;
                                customControllerFullName.enable = false;
                                customControllerID.enable = false;
                                customControllerAddress.enable = false;
                                customControllerChurchOfAttendance.enable =
                                    false;

                                fullName = customControllerFullName
                                    .fullNameController.text;
                                mobile = customControllerMobile
                                    .mobileController.text;
                                address = customControllerAddress
                                    .addressController.text;
                                churchOfAttendance =
                                    customControllerChurchOfAttendance
                                        .churchOfAttendanceController.text;
                                nationalID =
                                    customControllerID.iDController.text;
                                print("genderId: $selectedGenderRadioTile");
                                print("isDeacon $selectedDeaconRadioTile");
                                print("governorateID: $governorateID");
                                print("churchID: $churchOfAttendanceID");
                                print("churchOfAttendance $churchOfAttendance");

                                String responseNationalID =
                                    await checkNationalID(nationalID);
                                if (responseNationalID == '0') {
                                  String response = await addEditFamilyMember(
                                      fullName,
                                      nationalID,
                                      mobile,
                                      address,
                                      churchOfAttendance);
                                  if (response == '1') {
                                    setState(() {
                                      registerState = 2;
                                    });
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                HomeActivity(true)),
                                        ModalRoute.withName("/Home"));
                                  } else  if (response == '2'){
                                    setState(() {
                                      registerState = 2;
                                    });
                                    customControllerMobile.enable = true;
                                    customControllerFullName.enable = true;
                                    customControllerID.enable = true;
                                    customControllerAddress.enable = true;
                                    customControllerChurchOfAttendance.enable =
                                    true;

                                    Fluttertoast.showToast(
                                        msg: errorMessage,
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.white,
                                        textColor: Colors.red,
                                        fontSize: 16.0);
                                  }else {
                                    setState(() {
                                      registerState = 2;
                                    });
                                    customControllerMobile.enable = true;
                                    customControllerFullName.enable = true;
                                    customControllerID.enable = true;
                                    customControllerAddress.enable = true;
                                    customControllerChurchOfAttendance.enable =
                                        true;

                                    Fluttertoast.showToast(
                                        msg: AppLocalizations.of(context)
                                            .errorConnectingWithServer,
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.white,
                                        textColor: Colors.red,
                                        fontSize: 16.0);
                                  }
                                }else if (responseNationalID == '2'){    setState(() {
                                  registerState = 2;
                                });
                                customControllerMobile.enable = true;
                                customControllerFullName.enable = true;
                                customControllerID.enable = true;
                                customControllerAddress.enable = true;
                                customControllerChurchOfAttendance.enable =
                                true;
                                Fluttertoast.showToast(
                                    msg: errorMessage,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.white,
                                    textColor: Colors.red,
                                    fontSize: 16.0);}
                                else if (responseNationalID == '1'){
                                  setState(() {
                                    registerState = 2;
                                  });
                                  customControllerMobile.enable = true;
                                  customControllerFullName.enable = true;
                                  customControllerID.enable = true;
                                  customControllerAddress.enable = true;
                                  customControllerChurchOfAttendance.enable =
                                  true;
                                  Fluttertoast.showToast(
                                      msg: AppLocalizations.of(context)
                                          .duplicatedNationalID,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.white,
                                      textColor: Colors.red,
                                      fontSize: 16.0);
                                } else {
                                setState(() {
                                  registerState = 2;
                                });
                                customControllerMobile.enable = true;
                                customControllerFullName.enable = true;
                                customControllerID.enable = true;
                                customControllerAddress.enable = true;
                                customControllerChurchOfAttendance.enable =
                                true;
                                Fluttertoast.showToast(
                                    msg: AppLocalizations.of(context)
                                        .errorConnectingWithServer,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.white,
                                    textColor: Colors.red,
                                    fontSize: 16.0);
                              }
                              } else {
                                Navigator.of(context).push(
                                  new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        NoInternetConnectionActivity(),
                                  ),
                                );
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: AppLocalizations.of(context)
                                      .pleaseCompleteAllInformation,
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.white,
                                  textColor: Colors.red,
                                  fontSize: 16.0);
                            }
                          } else {
                            print("no validate");
                            Fluttertoast.showToast(
                                msg: AppLocalizations.of(context)
                                    .pleaseCompleteAllInformation,
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.white,
                                textColor: Colors.red,
                                fontSize: 16.0);
                          }
                        },
                        textColor: Colors.white,
                        color: primaryDarkColor,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> checkNationalID(String nationalID) async {
    print('nationalID: to send to CheckNationalID $nationalID');
    var response = await http.get(
        '$baseUrl/Users/CheckNationalID/?NationalID=$nationalID&IsMainPerson=1');
    print(
        '$baseUrl/Users/CheckNationalID/?NationalID=$nationalID&IsMainPerson=1');
    print(response.body);
    if (response.statusCode == 200) {
      var addFamilyMemberObj = addFamilyMemberFromJson(response.body.toString());
      print('jsonResponse $addFamilyMemberObj');
      if(myLanguage == "ar"){
        errorMessage = addFamilyMemberObj.nameAr;
      }else{
        errorMessage = addFamilyMemberObj.nameEn;
      }
      if(addFamilyMemberObj.code=="0"){
        return "0";
      }else if (addFamilyMemberObj.code =="1"){
        return "1";
      }else if(addFamilyMemberObj.code =="2"){
        return "2";
      }else{
        return "error";
      }
    } else {
      return "error";
    }
  }

  Future<String> addEditFamilyMember(String fullName, String nationalID,
      String mobile, String address, String churchOfAttendance) async {
    print('EgyCoptsApp/api/Family/AddEditFamilyMember/?');
    print('Name=$fullName');
    print('relationID=${int.parse(relationshipID)}');
    bool isDeacon;
    if (selectedDeaconRadioTile == 1) {
      isDeacon = true;
    } else {
      isDeacon = false;
    }
    print('Deacon=$isDeacon');

    print('NationalID=$nationalID');
    print('Mobile=$mobile');
    print('UserAccountID=$userID');
    int genderToApi;
    if (!isFamilyAccount) {
      genderToApi = selectedGenderRadioTile;
    } else {
      if (relationshipID == "1" || relationshipID == "1") {
        genderToApi = 1;
      } else {
        genderToApi = 2;
      }
    }
    print('GenderID=${selectedGenderRadioTile + 1}');
    print('Ismain=1');
    print('churchOfAttendance=$churchOfAttendance');
    print('Address=$address');
    print('BranchID=$churchOfAttendanceID');
    print('flag=1');
    print('AccountMemberID=');
    print('Token=$mobileToken');
    var response = await http.post(
        '$baseUrl/Family/AddEditFamilyMember/?Name=$fullName&relationID=${int.parse(relationshipID)}&Deacon=$isDeacon&NationalID=$nationalID&Mobile=$mobile&UserAccountID=$userID&GenderID=$genderToApi&Ismain=1&churchOfAttendance=$churchOfAttendance&Address=$address&BranchID=$churchOfAttendanceID&GovernerateID=$governorateID&flag=1&AccountMemberID=&Token=$mobileToken');
    print(
        '$baseUrl/Family/AddEditFamilyMember/?Name=$fullName&relationID=${int.parse(relationshipID)}&Deacon=$isDeacon&NationalID=$nationalID&Mobile=$mobile&UserAccountID=$userID&GenderID=$genderToApi&Ismain=1&churchOfAttendance=$churchOfAttendance&Address=$address&BranchID=$churchOfAttendanceID&GovernerateID=$governorateID&flag=1&AccountMemberID=&Token=$mobileToken');
    print(response.body);
    if (response.statusCode == 200) {
      var addFamilyMemberObj = addFamilyMemberFromJson(response.body.toString());
      print('jsonResponse $addFamilyMemberObj');
      if(myLanguage == "ar"){
        errorMessage = addFamilyMemberObj.nameAr;
      }else{
        errorMessage = addFamilyMemberObj.nameEn;
      }
      if (addFamilyMemberObj.code =="1"){
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("hasMainAccount", true);
        return "1";
      }else if(addFamilyMemberObj.code =="2"){
        return "2";
      }else{
        return "error";
      }
    } else {
      return "error";
    }
  }

  Widget gender() {
    if (showGenderState) {
      if (genderState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Text(
                AppLocalizations.of(context).genderWithAstric,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: RadioListTile(
                      value: 1,
                      groupValue: selectedGenderRadioTile,
                      title: Text(
                        AppLocalizations.of(context).male,
                        style: TextStyle(color: Colors.black),
                      ),
                      onChanged: (val) {
                        print('Gender Radio tile pressed $val');
                        if (val == 1) {
                          showDeaconRadioButtonState = true;
                        } else {
                          showDeaconRadioButtonState = false;
                        }
                        setSelectedGenderRadioTile(val);
                      },
                      activeColor: accentColor,
                    ),
                  ),
                  Flexible(
                    child: RadioListTile(
                      value: 2,
                      groupValue: selectedGenderRadioTile,
                      title: Text(
                        AppLocalizations.of(context).female,
                        style: TextStyle(color: Colors.black),
                      ),
                      onChanged: (val) async {
                        print('Gender Radio tile pressed $val');
                        if (val == 1) {
                          showDeaconRadioButtonState = true;
                        } else {
                          showDeaconRadioButtonState = false;
                          setSelectedDeaconRadioTile(0);
                        }
                        setSelectedGenderRadioTile(val);
                      },
                      activeColor: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20),
              child: Text(
                AppLocalizations.of(context).genderWithAstric,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: RadioListTile(
                      value: 1,
                      groupValue: selectedGenderRadioTile,
                      title: Text(
                        AppLocalizations.of(context).male,
                        style: TextStyle(color: Colors.black),
                      ),
                      onChanged: (val) {
                        print('Gender Radio tile pressed $val');
                        if (val == 1) {
                          showDeaconRadioButtonState = true;
                        } else {
                          showDeaconRadioButtonState = false;
                        }
                        setSelectedGenderRadioTile(val);
                      },
                      activeColor: accentColor,
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: RadioListTile(
                      value: 2,
                      groupValue: selectedGenderRadioTile,
                      title: Text(
                        AppLocalizations.of(context).female,
                        style: TextStyle(color: Colors.black),
                      ),
                      onChanged: (val) async {
                        print('Gender Radio tile pressed $val');
                        if (val == 1) {
                          showDeaconRadioButtonState = true;
                        } else {
                          showDeaconRadioButtonState = false;
                          setSelectedDeaconRadioTile(0);
                        }
                        setSelectedGenderRadioTile(val);
                      },
                      activeColor: accentColor,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Text(
                AppLocalizations.of(context).pleaseChooseGender,
                style: TextStyle(
                  fontSize: 14.0,
                  fontFamily: 'cocon-next-arabic-regular',
                  color: red700,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      }
    } else {
      return Container();
    }
  }

  setSelectedGenderRadioTile(int value) {
    setState(() {
      selectedGenderRadioTile = value;
    });
  }

  setSelectedDeaconRadioTile(int value) {
    setState(() {
      selectedDeaconRadioTile = value;
    });
  }

  Widget showDeaconCheckboxLayout() {
    if (showDeaconRadioButtonState) {
      if (deaconState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Text(
                AppLocalizations.of(context).deaconWithAstric,
                style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: 'cocon-next-arabic-regular',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: Row(
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: RadioListTile(
                      value: 1,
                      groupValue: selectedDeaconRadioTile,
                      title: Text(
                        AppLocalizations.of(context).yes,
                        style: TextStyle(color: Colors.black),
                      ),
                      onChanged: (val) {
                        print('Gender Radio tile pressed $val');
                        setSelectedDeaconRadioTile(val);
                      },
                      activeColor: accentColor,
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: RadioListTile(
                      dense: true,
                      value: 2,
                      groupValue: selectedDeaconRadioTile,
                      title: Text(
                        AppLocalizations.of(context).no,
                        style: TextStyle(color: Colors.black),
                      ),
                      onChanged: (val) async {
                        print('Gender Radio tile pressed $val');
                        setSelectedDeaconRadioTile(val);
                      },
                      activeColor: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
      else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Text(
                AppLocalizations.of(context).deaconWithAstric,
                style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: 'cocon-next-arabic-regular',
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: Row(
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: RadioListTile(
                      value: 1,
                      groupValue: selectedDeaconRadioTile,
                      title: Text(
                        AppLocalizations.of(context).yes,
                        style: TextStyle(color: Colors.black),
                      ),
                      onChanged: (val) {
                        print('Gender Radio tile pressed $val');
                        setSelectedDeaconRadioTile(val);
                      },
                      activeColor: accentColor,
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: RadioListTile(
                      dense: true,
                      value: 2,
                      groupValue: selectedDeaconRadioTile,
                      title: Text(
                        AppLocalizations.of(context).no,
                        style: TextStyle(color: Colors.black),
                      ),
                      onChanged: (val) async {
                        print('Gender Radio tile pressed $val');
                        setSelectedDeaconRadioTile(val);
                      },
                      activeColor: accentColor,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Text(
                AppLocalizations.of(context).pleaseChooseDeacon,
                style: TextStyle(
                  fontSize: 14.0,
                  fontFamily: 'cocon-next-arabic-regular',
                  color: red700,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      }
    } else {
      return Container();
    }
  }

  churchOfAttendanceDropDownData() async {
    listDropChurchOfAttendance.clear();
    if (churchOfAttendanceList.length > 0) {
      setState(() {
        listDropChurchOfAttendance
          ..add({
            "id": "0",
            "nameAr": "اختار كنيستك",
            "nameEn": "Choose your Church",
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
        listDropChurchOfAttendance
          ..add({
            "id": "-1",
            "nameAr": "أخرى",
            "nameEn": "Others",
            "isDefualt": false
          });
        showChurchOfAttendanceState = true;
      });
    }
  }

  governoratesDropDownData() async {
    listDropGovernorates.clear();
    setState(() {
      listDropGovernorates
        ..add({
          "id": "0",
          "nameAr": "اختار محافظتك",
          "nameEn": "Choose your Governorate",
          "isDefualt": false
        });

      for (int i = 0; i < governoratesList.length; i++) {
        listDropGovernorates
          ..add({
            "id": governoratesList.elementAt(i).id,
            "nameAr": governoratesList.elementAt(i).nameAr,
            "nameEn": governoratesList.elementAt(i).nameEn,
            "isDefualt": governoratesList.elementAt(i).isDefualt
          });
        if (governoratesList.elementAt(i).isDefualt) {
          governorateID = governoratesList.elementAt(i).id.toString();
        }
      }
    });
  }

//  Future<List<Governorates>> getGovernorates() async {
//    var response = await http.get('$baseUrl/Booking/GetGovernorates/');
//    print('$baseUrl/Booking/GetGovernorates/');
//    print(response.body);
//    if (response.statusCode == 200) {
//      print('GetGovernorates= response.statusCode ${response.statusCode}');
//      var governoratesObj = governoratesFromJson(response.body.toString());
//      print('jsonResponse $governoratesObj');
//      return governoratesObj;
//    } else {
//      print("GetGovernorates error");
//      print('GetGovernorates= response.statusCode ${response.statusCode}');
//      return null;
//    }
//  }
  Future<List<Governorates>> getGovernoratesByUserID() async {
    var response = await http
        .get('$baseUrl/Booking/GetGovernoratesByUserID/?UserAccountID=$userID');
    print('$baseUrl/Booking/GetGovernoratesByUserID/?UserAccountID=$userID');
    print(response.body);
    if (response.statusCode == 200) {
      print('GetGovernorates= response.statusCode ${response.statusCode}');
      var governoratesObj = governoratesFromJson(response.body.toString());
      print('jsonResponse $governoratesObj');
      return governoratesObj;
    } else {
      print("GetGovernorates error");
      print('GetGovernorates= response.statusCode ${response.statusCode}');
      return null;
    }
  }

  Future<List<Churchs>> getChurchs(String governorateID) async {
    var response = await http
        .get('$baseUrl/Booking/GetAllChurches/?GovernerateID=$governorateID');
    print('$baseUrl/Booking/GetAllChurches/?GovernerateID=$governorateID');
    print(response.body);
    if (response.statusCode == 200) {
      print('GetChurch= response.statusCode ${response.statusCode}');
      var churchsObj = churchsFromJson(response.body.toString());
      print('jsonResponse $churchsObj');
      return churchsObj;
    } else {
      print("GetChurch error");
      print('GetChurch= response.statusCode ${response.statusCode}');
      return null;
    }
  }

  Widget showRelationshipLayout() {
    if (showRelationShipState) {
      if (relationshipState) {
        return Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).relationshipWithAstric,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: new DropdownButton(
                    value: relationshipID,
                    isExpanded: true,
//                    hint: Text(
//                      AppLocalizations.of(context).relationshipWithAstric,
//                      style: TextStyle(
//                        color: greyColor,
//                        fontSize: 20.0,
//                        fontFamily: 'cocon-next-arabic-regular',
//                        fontWeight: FontWeight.normal,
//                      ),
//                    ),
                    //items: listDrop,
                    items: listDropRelationship.map((Map map) {
                      return DropdownMenuItem<String>(
                        value: map["id"].toString(),
                        child: SizedBox(
                          child: Text(
                            myLanguage == "ar" ? map["nameAr"] : map["nameEn"],
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              color: primaryDarkColor,
                              fontSize: 20.0,
                              fontFamily: 'cocon-next-arabic-regular',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        relationshipID = value;
                        for(int i =0 ; i<listDropRelationship.length; i++){
                          if(listDropRelationship[i]["id"].toString() == relationshipID.toString()){
                            if(listDropRelationship[i]["genderTypeID"]==1){
                              showDeaconRadioButtonState = true;
                            }else {
                              showDeaconRadioButtonState = false;
                            }
                          }
                        }
                        print("relationshipID : $relationshipID");
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
                  AppLocalizations.of(context).relationshipWithAstric,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new DropdownButton(
                        value: relationshipID,
                        isExpanded: true,
//                        hint: Text(
//                          AppLocalizations.of(context).relationshipWithAstric,
//                          style: TextStyle(
//                            color: greyColor,
//                            fontSize: 20.0,
//                            fontFamily: 'cocon-next-arabic-regular',
//                            fontWeight: FontWeight.normal,
//                          ),
//                        ),
                        //items: listDrop,
                        items: listDropRelationship.map((Map map) {
                          return DropdownMenuItem<String>(
                            value: map["id"].toString(),
                            child: SizedBox(
                              child: Text(
                                myLanguage == "ar" ? map["nameAr"] : map["nameEn"],
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                  color: primaryDarkColor,
                                  fontSize: 20.0,
                                  fontFamily: 'cocon-next-arabic-regular',
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            relationshipID = value;
                            // if (relationshipID == "0") {
                            // } else {}
                            for(int i =0 ; i<listDropRelationship.length; i++){
                              if(listDropRelationship[i]["id"].toString() == relationshipID.toString()){
                                if(listDropRelationship[i]["genderTypeID"]==1){
                                  showDeaconRadioButtonState = true;
                                }else {
                                  showDeaconRadioButtonState = false;
                                }
                              }
                            }
                            print("relationshipID : $relationshipID");
                          });
                        },
                      ),
                      Text(
                        AppLocalizations.of(context).pleaseChooseRelationship,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: red700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      return Container();
    }
  }

  Widget showGovernoratesLayout() {
    if (governorateState) {
      if (myLanguage == "en") {
        return Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).governorate,
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
                        governorateID = value;

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
                  AppLocalizations.of(context).governorate,
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
                        governorateID = value;

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
                  AppLocalizations.of(context).governorate,
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
                        governorateID = value;

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
                  AppLocalizations.of(context).pleaseChooseGovernorate,
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
                  AppLocalizations.of(context).governorate,
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
                        governorateID = value;

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
                  AppLocalizations.of(context).pleaseChooseGovernorate,
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
                    AppLocalizations.of(context).churchOfAttendanceWithAstric,
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
                          churchOfAttendanceID = value;
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
                    AppLocalizations.of(context).churchOfAttendanceWithAstric,
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
                          churchOfAttendanceID = value;
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
                    AppLocalizations.of(context).churchOfAttendanceWithAstric,
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
                          churchOfAttendanceID = value;
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
                    AppLocalizations.of(context).pleaseChooseChurch,
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
                    AppLocalizations.of(context).churchOfAttendanceWithAstric,
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
                          churchOfAttendanceID = value;
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
                    AppLocalizations.of(context).pleaseChooseChurch,
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
    if (showChurchOfAttendanceOthersState) {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
        child: Container(
          width: double.infinity,
          child: MyCustomTextFieldChurchOfAttendance(
            customController: customControllerChurchOfAttendance,
          ),
        ),
      );
    } else {
      return Container();
    }
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
}

class MyCustomTextFieldFirstName extends StatelessWidget {
  final MyCustomControllerFirstName customController;

  const MyCustomTextFieldFirstName({Key key, this.customController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      controller: customController.firstNameController,
      enabled: customController.enable,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).firstNameWithAstric,
        labelStyle: TextStyle(
          color: Colors.black,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor),
        ),
      ),
      validator: (String valueFirstName) {
        if (valueFirstName.isEmpty) {
          return AppLocalizations.of(context).pleaseEnterYourFirstName;
        }
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
      {@required this.firstNameController, this.enable = true});
}

class MyCustomTextFieldLastName extends StatelessWidget {
  final MyCustomControllerLastName customController;

  const MyCustomTextFieldLastName({Key key, this.customController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      controller: customController.lastNameController,
      enabled: customController.enable,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).lastNameWithAstric,
        labelStyle: TextStyle(
          color: Colors.black,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor),
        ),
      ),
      validator: (String valueLastName) {
        if (valueLastName.isEmpty) {
          return AppLocalizations.of(context).pleaseEnterYourLastName;
        }
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

class MyCustomControllerLastName {
  final TextEditingController lastNameController;
  bool enable;

  MyCustomControllerLastName(
      {@required this.lastNameController, this.enable = true});
}

class MyCustomTextFieldFullName extends StatelessWidget {
  final MyCustomControllerFullName customController;

  const MyCustomTextFieldFullName({Key key, this.customController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      controller: customController.fullNameController,
      enabled: customController.enable,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).fullNameWithAstric,
        labelStyle: TextStyle(
          color: Colors.black,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor),
        ),
      ),
      validator: (String valueFullName) {
        if (valueFullName.isEmpty) {
          return AppLocalizations.of(context).pleaseEnterYourFullName;
        }
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
      {@required this.fullNameController, this.enable = true});
}

class MyCustomTextFieldID extends StatelessWidget {
  final MyCustomControllerID customController;

  const MyCustomTextFieldID({Key key, this.customController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      controller: customController.iDController,
      enabled: customController.enable,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).nationalIdWithAstric,
        labelStyle: TextStyle(
          color: Colors.black,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor),
        ),
      ),
      validator: (String valueID) {
        if (valueID.isEmpty) {
          return AppLocalizations.of(context).pleaseEnterYourNationalId;
        } else if (valueID.length != 14) {
          return AppLocalizations.of(context).pleaseEnterCorrectNationalId;
        }
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

  MyCustomControllerID({@required this.iDController, this.enable = true});
}

class MyCustomTextFieldMobile extends StatelessWidget {
  final MyCustomControllerMobile customController;

  const MyCustomTextFieldMobile({Key key, this.customController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      controller: customController.mobileController,
      enabled: customController.enable,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).mobileWithAstric,
        labelStyle: TextStyle(
          color: Colors.black,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor),
        ),
      ),
      cursorColor: accentColor,
      keyboardType: TextInputType.phone,
      validator: (String valueMobileNumber) {
        if (valueMobileNumber.isEmpty) {
          return AppLocalizations.of(context).pleaseEnterYourMobile;
        } else if (valueMobileNumber.length < 10) {
          return AppLocalizations.of(context).pleaseEnterAValidMobileNumber;
        }
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
      {@required this.mobileController, this.enable = true});
}

class MyCustomTextFieldAddress extends StatelessWidget {
  final MyCustomControllerAddress customController;

  const MyCustomTextFieldAddress({Key key, this.customController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      controller: customController.addressController,
      enabled: customController.enable,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).addressWithAstric,
        labelStyle: TextStyle(
          color: Colors.black,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor),
        ),
      ),
      validator: (String valueAddress) {
        if (valueAddress.isEmpty) {
          return AppLocalizations.of(context).pleaseEnterYourAddress;
        }
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
      {@required this.addressController, this.enable = true});
}

class MyCustomTextFieldChurchOfAttendance extends StatelessWidget {
  final MyCustomControllerChurchOfAttendance customController;

  const MyCustomTextFieldChurchOfAttendance({Key key, this.customController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      controller: customController.churchOfAttendanceController,
      enabled: customController.enable,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).churchOfAttendanceWithAstric,
        labelStyle: TextStyle(
          color: Colors.black,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor),
        ),
      ),
      validator: (String valueChurchOfAttendance) {
        if (valueChurchOfAttendance.isEmpty && churchOfAttendanceID == "-1") {
          return AppLocalizations.of(context).pleaseEnterYourChurchOfAttendance;
        }
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
      {@required this.churchOfAttendanceController, this.enable = true});
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
    );*/
  }
