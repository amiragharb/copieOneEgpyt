import 'dart:async';
import 'dart:convert';

import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Home/homeActivity.dart';
import 'package:egpycopsversion4/Models/addBookingDetails.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meta/meta.dart';

import 'chooseBookingFamilyMembersActivity.dart';

String myLanguage = "";

BaseUrl BASE_URL = BaseUrl();
String baseUrl = BASE_URL.BASE_URL;
String bookNumber = "",
    courseDateAr = "",
    courseDateEn = "",
    courseTimeAr = "",
    courseTimeEn = "",
    churchRemarks = "",
    courseRemarks = "",
    churchNameAr = "",
    churchNameEn = "",
    governerateNameAr = "",
    governerateNameEn = "",
    courseTypeName = "";
int attendanceTypeIDAddBooking = 0;
String attendanceTypeNameArAddBooking = "", attendanceTypeNameEnAddBooking = "";
List<BookedPersonsList> bookedPersonsList = [];

class BookingSuccessActivity extends StatefulWidget {
  final String bookNumber;
  final String courseDateAr;
  final String courseDateEn;
  final String courseTimeAr;
  final String courseTimeEn;
  final String churchRemarks;
  final String courseRemarks;
  final String churchNameAr;
  final String churchNameEn;
  final String governerateNameAr;
  final String governerateNameEn;
  final String myLanguage;
  final String courseTypeName;
  final int attendanceTypeIDAddBooking;
  final String attendanceTypeNameArAddBooking;
  final String attendanceTypeNameEnAddBooking;
  final List<BookedPersonsList> bookedPersonsList;
  final Map<String, Object?> bookingInfo;

  const BookingSuccessActivity({
    Key? key,
    this.bookNumber = "",
    this.courseDateAr = "",
    this.courseDateEn = "",
    this.courseTimeAr = "",
    this.courseTimeEn = "",
    this.churchRemarks = "",
    this.courseRemarks = "",
    this.churchNameAr = "",
    this.churchNameEn = "",
    this.governerateNameAr = "",
    this.governerateNameEn = "",
    this.myLanguage = "en",
    this.courseTypeName = "",
    this.attendanceTypeIDAddBooking = 0,
    this.attendanceTypeNameArAddBooking = "",
    this.attendanceTypeNameEnAddBooking = "",
    this.bookedPersonsList = const [],
    required this.bookingInfo,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => BookingSuccessActivityState();
}


class BookingSuccessActivityState extends State<BookingSuccessActivity>
    with TickerProviderStateMixin {
  String mobileToken = "";

  var _formKey = GlobalKey<FormState>();
  int loginState = 0;
  late Animation _animationLogin;
  List<Map<String, dynamic>> listViewBookedPersons = [];
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initFirebaseToken();
    setShared(true);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        //getDataFromShared();
      }
    });
  }

  Future<void> _initFirebaseToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      mobileToken = token ?? "";
      debugPrint("Token: $mobileToken");
    } catch (e) {
      debugPrint("Error getting Firebase token: $e");
    }
  }

  setShared(bool isOpened) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("SuccessIsOpened", isOpened);
      debugPrint("attendanceTypeIDAddBooking $attendanceTypeIDAddBooking");
      debugPrint("attendanceTypeNameArAddBooking $attendanceTypeNameArAddBooking");
      debugPrint("attendanceTypeNameEnAddBooking $attendanceTypeNameEnAddBooking");

      personsListListViewData();
    } catch (e) {
      debugPrint("Error in setShared: $e");
    }
  }

  personsListListViewData() {
    if (!mounted) return;
    setState(() {
      listViewBookedPersons.clear();
      for (int i = 0; i < bookedPersonsList.length; i++) {
        listViewBookedPersons.add({
          "name": bookedPersonsList.elementAt(i).name ?? "",
          "nationalID": bookedPersonsList.elementAt(i).nationalID ?? "",
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    setShared(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Center(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 30.0,
                          right: 20.0,
                          left: 20.0,
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.bookedSuccessfully ?? "Booked Successfully",
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontFamily: 'cocon-next-arabic-regular',
                            color: Colors.green,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                        ),
                        child: SizedBox(
                          child: Image.asset(
                            'images/success.png',
                          ),
                          height: 70.0,
                          width: 70.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          right: 20.0,
                          left: 20.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)?.bookingNumber ?? "Booking Number",
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'cocon-next-arabic-regular',
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Text(
                                bookNumber,
                                style: const TextStyle(
                                  fontSize: 22.0,
                                  fontFamily: 'cocon-next-arabic-regular',
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          right: 20.0,
                          left: 20.0,
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.pleaseSaveBookingNumber ?? "Please save booking number",
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontFamily: 'cocon-next-arabic-regular',
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          right: 20.0,
                          left: 20.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)?.governorate ?? "Governorate",
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'cocon-next-arabic-regular',
                              ),
                            ),
                            const Text(
                              ': ',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'cocon-next-arabic-regular',
                              ),
                            ),
                            Expanded(
                              child: governorateNameChild(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          right: 20.0,
                          left: 20.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)?.church ?? "Church",
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'cocon-next-arabic-regular',
                              ),
                            ),
                            const Text(
                              ': ',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'cocon-next-arabic-regular',
                              ),
                            ),
                            Expanded(
                              child: churchNameChild(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          right: 20.0,
                          left: 20.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.bookingType ?? "Booking Type",
                              style: const TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                            ),
                            myLanguage == "en"
                                ? const Padding(
                                    padding: EdgeInsets.only(right: 5.0),
                                    child: Text(
                                      ":",
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                : const Padding(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: Text(
                                      ":",
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                            Expanded(
                              child: Text(
                                courseTypeName,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      attendanceTypeIDAddBooking == 0
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(
                                top: 10.0,
                                right: 20.0,
                                left: 20.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)?.attendanceType ?? "Attendance Type",
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  myLanguage == "en"
                                      ? const Padding(
                                          padding: EdgeInsets.only(right: 5.0),
                                          child: Text(
                                            ":",
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                        )
                                      : const Padding(
                                          padding: EdgeInsets.only(left: 5.0),
                                          child: Text(
                                            ":",
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                  Expanded(
                                    child: Text(
                                      myLanguage == "ar"
                                          ? attendanceTypeNameArAddBooking
                                          : attendanceTypeNameEnAddBooking,
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          right: 20.0,
                          left: 20.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)?.liturgyDate ?? "Liturgy Date",
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'cocon-next-arabic-regular',
                              ),
                            ),
                            const Text(
                              ': ',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'cocon-next-arabic-regular',
                              ),
                            ),
                            Expanded(
                              child: dateChild(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          right: 20.0,
                          left: 20.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)?.liturgyTime ?? "Liturgy Time",
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'cocon-next-arabic-regular',
                              ),
                            ),
                            const Text(
                              ': ',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'cocon-next-arabic-regular',
                              ),
                            ),
                            Expanded(
                              child: timeChild(),
                            ),
                          ],
                        ),
                      ),
                      attendanceTypeIDAddBooking != 1
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(
                                top: 10.0,
                                right: 20.0,
                                left: 20.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)?.familyMembers ?? "Family Members",
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          right: 20.0,
                          left: 20.0,
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: listViewBookedPersons.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      AppLocalizations.of(context)?.name ?? "Name",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'cocon-next-arabic-regular',
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                      child: Text(
                                        listViewBookedPersons[index]["name"] ?? "",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'cocon-next-arabic-regular',
                                          color: logoBlue,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)?.nationalId ?? "National ID",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'cocon-next-arabic-regular',
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                      child: Text(
                                        listViewBookedPersons[index]["nationalID"] ?? "",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'cocon-next-arabic-regular',
                                          color: greyColor,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      courseRemarks.isEmpty
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(
                                top: 10.0,
                                right: 20.0,
                                left: 20.0,
                              ),
                              child: Text(
                                courseRemarks,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: 'cocon-next-arabic-regular',
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                      churchRemarks.isEmpty
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(
                                top: 10.0,
                                right: 20.0,
                                left: 20.0,
                              ),
                              child: Text(
                                churchRemarks,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: 'cocon-next-arabic-regular',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                    ],
                  );
                }),
          ),
        ),
        bottomNavigationBar: Container(
          width: double.maxFinite,
          height: 55,
          color: primaryDarkColor,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: primaryDarkColor,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeActivity(false)),
                ModalRoute.withName("/Home"),
              );
            },
            child: Text(
              AppLocalizations.of(context)?.backToHome ?? "Back to Home",
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontFamily: 'cocon-next-arabic-regular',
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
      onWillPop: _onWillPop,
    );
  }

  Future<bool> _onWillPop() async {
    debugPrint("onWillPop");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeActivity(false)),
      ModalRoute.withName("/Home"),
    );
    return false; // Empêche le pop natif (ex: bouton retour Android)
  }

  Widget governorateNameChild() {
    if (myLanguage == "en") {
      return Text(
        governerateNameEn,
        style: const TextStyle(
          fontSize: 18.0,
          fontFamily: 'cocon-next-arabic-regular',
        ),
      );
    } else {
      return Text(
        governerateNameAr,
        style: const TextStyle(
          fontSize: 18.0,
          fontFamily: 'cocon-next-arabic-regular',
        ),
      );
    }
  }

  Widget churchNameChild() {
    if (myLanguage == "en") {
      return Text(
        churchNameEn,
        style: const TextStyle(
          fontSize: 18.0,
          fontFamily: 'cocon-next-arabic-regular',
        ),
      );
    } else {
      return Text(
        churchNameAr,
        style: const TextStyle(
          fontSize: 18.0,
          fontFamily: 'cocon-next-arabic-regular',
        ),
      );
    }
  }

  Widget timeChild() {
    if (myLanguage == "en") {
      return Text(
        courseTimeEn,
        style: const TextStyle(
            fontSize: 18.0,
            fontFamily: 'cocon-next-arabic-regular',
            color: Colors.green),
      );
    } else {
      return Text(
        courseTimeAr,
        style: const TextStyle(
            fontSize: 18.0,
            fontFamily: 'cocon-next-arabic-regular',
            color: Colors.green),
      );
    }
  }

  Widget dateChild() {
    if (myLanguage == "en") {
      return Text(
        courseDateEn,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.left,
        style: const TextStyle(
          fontSize: 18.0,
          fontFamily: 'cocon-next-arabic-regular',
          color: Colors.green,
        ),
      );
    } else {
      return Text(
        courseDateAr,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 18.0,
          fontFamily: 'cocon-next-arabic-regular',
          color: Colors.green,
        ),
      );
    }
  }

  Future<String> _checkInternetConnection() async {
    try {
      var result = await Connectivity().checkConnectivity();
      return result == ConnectivityResult.none ? "0" : "1";
    } catch (e) {
      debugPrint("Error checking connectivity: $e");
      return "0";
    }
  }
}