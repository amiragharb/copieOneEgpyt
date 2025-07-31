import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Models/editBooking.dart';
import 'package:egpycopsversion4/Models/editBookingDetails.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';
import 'package:egpycopsversion4/Utils/loader.dart' show Loader;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

typedef void LocaleChangeCallback(Locale locale);

String bookNumberAddBookin="",
    courseDateArAddBooking="",
    courseDateEnAddBooking="",
    courseTimeArAddBooking="",
    courseTimeEnAddBooking="";
String churchRemarksAddBooking ="", courseRemarksAddBooking="";
String churchNameArAddBooking="",
    churchNameEnAddBooking="",
    governerateNameArAddBooking="",
    governerateNameEnAddBooking ="";
String firstAttendDate ="";

BaseUrl BASE_URL = new BaseUrl();
String baseUrl = BASE_URL.BASE_URL;
String remAttendanceCount="",
    churchRemarks ="",
    courseRemarks="",
    courseDateAr="",
    courseDateEn="",
    courseTimeAr="",
    courseTimeEn="",
    churchNameAr="",
    churchNameEn="",
    coupleID="",
    courseTypeName="";
String remainingCountFailure="";
String myLanguage="";
int EditBookingState=0;
List<EditFamilyMember> myFamilyList = [];
String familyAccount = "";
String registrationNumber="";

int attendanceTypeID=0;
String attendanceTypeNameAr="";
String attendanceTypeNameEn="";
class EditBookingActivity extends StatefulWidget {
  EditBookingActivity(
      String remAttendanceCountConstructor,
      String churchRemarksConstructor,
      String courseRemarksConstructor,
      String courseDateArConstructor,
      String courseDateEnConstructor,
      String courseTimeArConstructor,
      String courseTimeEnConstructor,
      String churchNameArConstructor,
      String churchNameEnConstructor,
      String coupleIDConstructor,
      List<EditFamilyMember> myFamilyListConstructor,
      registrationNumberCon,
      courseTypeNameCon,
      int attendanceTypeIDCon,
      String attendanceTypeNameArCon,
      String attendanceTypeNameEnCon) {
    remAttendanceCount = remAttendanceCountConstructor;
    if (churchRemarksConstructor == null) {
      churchRemarks = "";
    } else {
      churchRemarks = churchRemarksConstructor;
    }
    if (courseRemarksConstructor == null) {
      courseRemarks = "";
    } else {
      courseRemarks = courseRemarksConstructor;
    }
    if (registrationNumberCon == null) {
      registrationNumber = "";
    } else {
      registrationNumber = registrationNumberCon;
    }
    courseDateAr = courseDateArConstructor;
    courseDateEn = courseDateEnConstructor;
    courseTimeAr = courseTimeArConstructor;
    courseTimeEn = courseTimeEnConstructor;
    churchNameAr = churchNameArConstructor;
    churchNameEn = churchNameEnConstructor;
    coupleID = coupleIDConstructor;
    myFamilyList = myFamilyListConstructor;
    courseTypeName = courseTypeNameCon;
    attendanceTypeID = attendanceTypeIDCon;
    attendanceTypeNameAr = attendanceTypeNameArCon;
    attendanceTypeNameEn = attendanceTypeNameEnCon;
  }

  @override
  _EditBookingState createState() => _EditBookingState();
}

class _EditBookingState extends State<EditBookingActivity> {
  List<Map> listViewMyFamily = [];
  ScrollController _scrollController = new ScrollController();
  int loadingState = 1;
  int pageNumber = 0;
  String userID = "";
  bool checkBoxValue = false;
  String mobileToken="";
  String failureMessage = "";
  late BuildContext mContext;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((String token) {
      print("Token  " + token);
      mobileToken = token;
    } as FutureOr<Null> Function(String? value));
    pageNumber = 0;
    remainingCountFailure = "0";
    EditBookingState = 0;
    loadingState = 1;
    getDataFromShared();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        //getDataFromShared();
      }
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

  getDataFromShared() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    myLanguage = (prefs.getString('language') ?? "en");
    familyAccount = prefs.getString("accountType")!;

    userID = prefs.getString("userID")!;
    setState(() {
      loadingState = 1;
      pageNumber = 0;
    });
    String connectionResponse = await _checkInternetConnection();
    print("connectionResponse");
    print(connectionResponse);
    myFamilyListViewData();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Widget buildSaveButton() {
    if (EditBookingState == 1) {
      return SizedBox(
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(
            value: null,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ));
    } else {
      return Text(
        AppLocalizations.of(context)!.save,
        style: TextStyle(
          fontSize: 18.0,
          fontFamily: 'cocon-next-arabic-regular',
          fontWeight: FontWeight.normal,
        ),
      );
    }
  }

  Widget bottomBar() {
    if (familyAccount == "1") {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 50.0,
       child: ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryDarkColor, // équivalent à "color:"
    foregroundColor: Colors.white,     // équivalent à "textColor:"
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  ),
  onPressed: () async {
    EditBooking();
  },
  child: buildSaveButton(),
),

      );
    } else {
  return ElevatedButton(
    onPressed: null, // désactive le bouton
    child: Text('Action désactivée'),
  );
}

  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    return Scaffold(
      bottomNavigationBar: bottomBar(),
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.white),
        title: Padding(
          padding: const EdgeInsets.all(2.0),
          child: new Text(
            AppLocalizations.of(context)!.editBooking,
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
          ),
        ),
        backgroundColor: primaryDarkColor, systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: buildChild(),
    );
  }

  myFamilyListViewData() {
    setState(() {
      if (attendanceTypeID == 3) {
        for (int i = 0; i < myFamilyList.length; i++) {
          setState(() {
  if ((attendanceTypeID ?? 0) == 3) {
    for (int i = 0; i < myFamilyList.length; i++) {
      if (myFamilyList[i].isDeacon == true) { // vérifie non-null
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
          "isChecked": myFamilyList[i].isSelectedInCourse,
        });
      }
    }
  } else {
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
        "isChecked": myFamilyList[i].isSelectedInCourse,
      });
    }
  }
});

        }
      }else {
        for (int i = 0; i < myFamilyList.length; i++) {
          listViewMyFamily
            ..add({
              "userAccountMemberId":
              myFamilyList
                  .elementAt(i)
                  .userAccountMemberId,
              "userAccountId": myFamilyList
                  .elementAt(i)
                  .userAccountId,
              "accountMemberNameAr":
              myFamilyList
                  .elementAt(i)
                  .accountMemberNameAr,
              "genderTypeId": myFamilyList
                  .elementAt(i)
                  .genderTypeId,
              "genderTypeNameAr": myFamilyList
                  .elementAt(i)
                  .genderTypeNameAr,
              "genderTypeNameEn": myFamilyList
                  .elementAt(i)
                  .genderTypeNameEn,
              "isDeacon": myFamilyList
                  .elementAt(i)
                  .isDeacon,
              "nationalIdNumber": myFamilyList
                  .elementAt(i)
                  .nationalIdNumber,
              "mobile": myFamilyList
                  .elementAt(i)
                  .mobile,
              "personRelationId": myFamilyList
                  .elementAt(i)
                  .personRelationId,
              "personRelationNameAr":
              myFamilyList
                  .elementAt(i)
                  .personRelationNameAr,
              "personRelationNameEn":
              myFamilyList
                  .elementAt(i)
                  .personRelationNameEn,
              "isMainPerson": myFamilyList
                  .elementAt(i)
                  .isMainPerson,
              "isChecked": myFamilyList
                  .elementAt(i)
                  .isSelectedInCourse,
            });
        }
      }
    });
  }

  EditBooking() async {
    String chosenMembers = "";
    for (int i = 0; i < listViewMyFamily.length; i++) {
      if (listViewMyFamily[i]["isChecked"]) {
        chosenMembers = chosenMembers +
            listViewMyFamily[i]["userAccountMemberId"].toString() +
            ",";
      }
    }

    if (chosenMembers.isEmpty) {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.pleaseChooseAtLeastFamilyMember,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.red,
          fontSize: 16.0);
    } else {
      setState(() {
        EditBookingState = 1;
      });
      chosenMembers = chosenMembers.substring(0, chosenMembers.length - 1);
      print("chosenMembers = $chosenMembers");
      String? editBookingResponse = await editBooking(chosenMembers, coupleID);
      if (editBookingResponse == "1") {
        setState(() {
          EditBookingState = 2;
        });
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.savedSuccessfully,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.green,
            fontSize: 16.0);
      } else if (editBookingResponse == "3") {
        setState(() {
          EditBookingState = 2;
        });
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.sorryYouCannotBookBefore +
                " " +
                firstAttendDate,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.red,
            fontSize: 16.0);
      }
      else if (editBookingResponse == "5") {
        setState(() {
          EditBookingState = 2;
        });

        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!
                .youAreNotRegisteredInThisChurchMembership,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.red,
            fontSize: 16.0);
      }
      else if (editBookingResponse == "6") {
        setState(() {
          EditBookingState = 2;
        });

        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!
                .chosenPersonIsNotaDeacon,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.red,
            fontSize: 16.0);
      }else if (editBookingResponse == "7") {
        setState(() {
          EditBookingState = 2;
        });

        Fluttertoast.showToast(
            msg: failureMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.red,
            fontSize: 16.0);
      } else if (editBookingResponse == "0") {
        setState(() {
          EditBookingState = 2;
        });
        if (int.parse(remainingCountFailure) > 10) {
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.thereAre +
                  " " +
                  remainingCountFailure +
                  " " +
                  AppLocalizations.of(context)!.availableSeat,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white,
              textColor: Colors.red,
              fontSize: 16.0);
        } else {
          if (int.parse(remainingCountFailure) > 1) {
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.thereAre +
                    " " +
                    remainingCountFailure +
                    " " +
                    AppLocalizations.of(context)!.availableSeats,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.red,
                fontSize: 16.0);
          } else {
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.thereIs +
                    " " +
                    remainingCountFailure +
                    " " +
                    AppLocalizations.of(context)!.availableSeatSingular,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.red,
                fontSize: 16.0);
          }
        }
      } else {
        setState(() {
          EditBookingState = 2;
        });
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.errorConnectingWithServer,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.red,
            fontSize: 16.0);
      }
    }
  }

  Future<String?> editBooking(String chosenMembers, String coupleID) async {
    var response = await http.post(
        '$baseUrl/Booking/EditBooking/?listAccountMemberIDs=$chosenMembers&CoupleID=$coupleID&UserAccountID=$userID&Token=$mobileToken' as Uri);
    print(
        '$baseUrl/Booking/EditBooking/?listAccountMemberIDs=$chosenMembers&CoupleID=$coupleID&UserAccountID=$userID&Token=$mobileToken');
    print("response body");
    print(response.body);
    print("response statusCode");
    print(response.statusCode);
    if (response.statusCode == 200) {
      var editBookingObj = editBookingFromJson(response.body.toString());
      print('jsonResponse $editBookingObj');
      firstAttendDate = editBookingObj.firstAttendDate!;
      remainingCountFailure = editBookingObj.remAttendanceCount!;
      if(myLanguage == "ar"){
        failureMessage = editBookingObj.errorMessageAr!;
      }else{
        failureMessage = editBookingObj.errorMessageEn!;
      }
      return editBookingObj.sucessCode;
    } else {
      return "0";
    }
  }

  Widget bookingType() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.bookingType,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Text(
                courseTypeName,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 18.0,
                  color: primaryDarkColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget attendanceTypeWidget() {
    return attendanceTypeID == 0 ? Container() :Padding(
      padding: const EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.attendanceType,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Text(
                myLanguage == "ar"
                    ? attendanceTypeNameAr
                    : attendanceTypeNameEn,
                style: TextStyle(
                  fontSize: 18.0,
                  color: attendanceTypeID == 1
                      ? logoBlue
                      : attendanceTypeID == 2
                      ? logoBlue
                      : accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget holyLiturgyDate() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.holyLiturgyDate,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: myLanguage == "en"
                  ? Text(
                      courseDateEn,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: primaryDarkColor,
                      ),
                    )
                  : Text(
                      courseDateAr,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: primaryDarkColor,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget liturgyTime() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.time,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: myLanguage == "en"
                  ? Text(
                      courseTimeEn,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: primaryDarkColor,
                      ),
                    )
                  : Text(
                      courseTimeAr,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: primaryDarkColor,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget church() {
      return Padding(
        padding: const EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.church,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: myLanguage == "en" ? Text(
                  churchNameEn,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: primaryDarkColor,
                  ),
                ) : Text(
                  churchNameAr,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: primaryDarkColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget availableSeats() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0, right: 15.0, left: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            int.parse(remAttendanceCount) > 10
                ? IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context)!.thereAre,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: 'cocon-next-arabic-regular',
                            color: primaryDarkColor,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                          child: Text(
                            remAttendanceCount,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: 'cocon-next-arabic-regular',
                              color: Colors.green,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.availableSeat,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: 'cocon-next-arabic-regular',
                            color: primaryDarkColor,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  )
                : int.parse(remAttendanceCount) > 1
                    ? IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)!.thereAre,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'cocon-next-arabic-regular',
                                color: Colors.redAccent,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Text(
                                remAttendanceCount,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: 'cocon-next-arabic-regular',
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.availableSeats,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'cocon-next-arabic-regular',
                                color: Colors.redAccent,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      )
                    : IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)!.thereIs,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'cocon-next-arabic-regular',
                                color: Colors.redAccent,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Text(
                                remAttendanceCount,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: 'cocon-next-arabic-regular',
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!
                                  .availableSeatSingular,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'cocon-next-arabic-regular',
                                color: Colors.redAccent,
                                fontWeight: FontWeight.normal,
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

  Widget bookingNumber() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalizations.of(context)!.bookingNumber,
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 5.0),
            child: Text(
              ":",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            registrationNumber,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'cocon-next-arabic-regular',
              fontWeight: FontWeight.normal,
              color: logoBlue,
            ),
          ),
        ],
      ),
    );
  }

 Widget buildChild() {
  if (loadingState == 0) {
    return Center(child: Loader());
  } else if (loadingState == 1) {
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Column(
        children: <Widget>[
          church(),
          bookingNumber(),
          bookingType(),
          attendanceTypeWidget(),
          holyLiturgyDate(),
          liturgyTime(),
          availableSeats(),
          if (courseRemarks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                courseRemarks,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontFamily: 'cocon-next-arabic-regular',
                  color: Colors.redAccent,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 5.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Text(
                        AppLocalizations.of(context)!.doYouWantToCancelThisBooking,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontFamily: 'cocon-next-arabic-regular',
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(
                            AppLocalizations.of(context)!.yes,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'cocon-next-arabic-regular',
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            AppLocalizations.of(context)!.no,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'cocon-next-arabic-regular',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    final connectionResponse = await _checkInternetConnection();
                    if (connectionResponse == '1') {
                      // TODO: remplacer ProgressDialog par une alternative Flutter moderne
                      final responseDeleteBooking = await deleteBooking();
                      if (responseDeleteBooking == '1') {
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!.cancelledSuccessfully,
                          backgroundColor: Colors.white,
                          textColor: Colors.green,
                        );
                        Navigator.pop(context);
                      } else {
                        Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!.errorConnectingWithServer,
                          backgroundColor: Colors.white,
                          textColor: Colors.red,
                        );
                      }
                    }
                  }
                },
                child: Text(
                  AppLocalizations.of(context)!.cancelBooking,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'cocon-next-arabic-regular',
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          if (familyAccount == "1")
            ListView.builder(
              controller: _scrollController,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: listViewMyFamily.length,
              itemBuilder: (context, index) {
                final member = listViewMyFamily[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                          value: member["isChecked"] == true,
                          activeColor: accentColor,
                          onChanged: (bool? newValue) {
                            setState(() {
                              member["isChecked"] = newValue ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                member["accountMemberNameAr"],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'cocon-next-arabic-regular',
                                  fontWeight: FontWeight.normal,
                                  color: logoBlue,
                                ),
                                maxLines: 1,
                              ),
                              Text(
                                myLanguage == "en"
                                    ? member["personRelationNameEn"]
                                    : member["personRelationNameAr"],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'cocon-next-arabic-regular',
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          if (churchRemarks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                churchRemarks,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: 'cocon-next-arabic-regular',
                  color: primaryDarkColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
        ],
      ),
    );
  } else if (loadingState == 2) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.errorConnectingWithServer,
        style: const TextStyle(
          fontSize: 20.0,
          fontFamily: 'cocon-next-arabic-regular',
          color: Colors.grey,
        ),
      ),
    );
  } else if (loadingState == 3) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.noMembersFound,
        style: const TextStyle(
          fontSize: 20.0,
          fontFamily: 'cocon-next-arabic-regular',
          color: Colors.grey,
        ),
      ),
    );
  } else {
    return const SizedBox.shrink(); // pour éviter d'avoir une fonction sans return
  }
}


  Future<String> deleteBooking() async {
    print('UserAccountID= $userID');
    print('bookingID= $coupleID');
    print('Token= $mobileToken');

    var response = await http.post(
        '$baseUrl/Booking/DeleteBooking/?CoupleID=$coupleID&UserAccountID=$userID&Token=$mobileToken' as Uri);
    print(
        '$baseUrl/Booking/DeleteBooking/?CoupleID=$coupleID&UserAccountID=$userID&Token=$mobileToken');
    print(response.body);
    if (response.statusCode == 200) {
      if (response.body.toString() == "1") {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        return "1";
      } else {
        return response.body;
      }
    } else {
      return response.body;
    }
  }
}
