import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Models/booking.dart';
import 'package:egpycopsversion4/Models/editBookingDetails.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

BaseUrl BASE_URL = BaseUrl();
String baseUrl = BASE_URL.BASE_URL;
String? myLanguage;
String remAttendanceCount = "",
    churchRemarks = "",
    courseRemarks = "",
    courseDateAr = "",
    courseDateEn = "",
    courseTimeAr = "",
    courseTimeEn = "",
    churchNameAr = "",
    churchNameEn = "",
    registrationNumber = "",
    coupleID = "";
bool allowEdit = false;
List<EditFamilyMember> myFamilyList = [];

class NotificationsActivity extends StatefulWidget {
  NotificationsActivity();

  @override
  State<StatefulWidget> createState() {
    return NotificationsActivityState();
  }
}

class NotificationsActivityState extends State<NotificationsActivity>
    with TickerProviderStateMixin {
  List<Booking> myBookingsList = [];
  List<Map> listViewMyBookings = [];
  ScrollController _scrollController = ScrollController();
  int loadingState = 0;
  String userID = "";
  String? mobileToken;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((String? token) {
      if (token != null) {
        print("Token  " + token);
        mobileToken = token;
      }
    });
    loadingState = 0;
    getDataFromShared();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Handle load more if needed
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

    userID = prefs.getString("userID") ?? "";
    setState(() {
      loadingState = 0;
    });
    String connectionResponse = await _checkInternetConnection();
    print("connectionResponse: $connectionResponse");

    if (connectionResponse == '1') {
      myBookingsList = await getMyBookings() ?? [];
      if (loadingState == 1 && myBookingsList.isNotEmpty) {
        myBookingsListViewData();
      }
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => NoInternetConnectionActivity(),
        ),
      ).then((value) async {
        myBookingsList = await getMyBookings() ?? [];
        if (loadingState == 1 && myBookingsList.isNotEmpty) {
          myBookingsListViewData();
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryDarkColor,
                primaryDarkColor.withOpacity(0.8),
                accentColor.withOpacity(0.6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 4),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white, size: 28),
            title: Column(
              children: [
                const SizedBox(height: 25),
                Text(
                  AppLocalizations.of(context)!.notifications,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  height: 3,
                  width: 40,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildChild(),
          ],
        ),
      ),
    );
  }

  myBookingsListViewData() {
    setState(() {
      for (int i = 0; i < myBookingsList.length; i++) {
        listViewMyBookings.add({
          "courseDateOfBook": myBookingsList[i].courseDateOfBook,
          "courseDateAr": myBookingsList[i].courseDateAr,
          "courseDateEn": myBookingsList[i].courseDateEn,
          "branchNameEn": myBookingsList[i].branchNameEn,
          "courseTimeAr": myBookingsList[i].courseTimeAr,
          "courseTimeEn": myBookingsList[i].courseTimeEn,
          "churchNameAr": myBookingsList[i].churchNameAr,
          "churchNameEn": myBookingsList[i].churchNameEn,
          "courseNameAr": myBookingsList[i].courseNameAr,
          "courseNameEn": myBookingsList[i].courseNameEn,
          "coupleId": myBookingsList[i].coupleId,
          "remAttendanceCount": myBookingsList[i].remAttendanceCount,
          "registrationNumber": myBookingsList[i].registrationNumber,
          "attendanceTypeID": myBookingsList[i].attendanceTypeID,
          "attendanceTypeNameEn": myBookingsList[i].attendanceTypeNameEn,
          "attendanceTypeNameAr": myBookingsList[i].attendanceTypeNameAr,
        });
      }
    });
  }

  Future<List<Booking>?> getMyBookings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userID") ?? "";
    await FirebaseMessaging.instance.getToken().then((String? token) {
      if (token != null) {
        mobileToken = token;
      }
    });

    var response = await http.get(
        '$baseUrl/Booking/GetMyBookings/?UserAccountID=$userID&Token=$mobileToken' as Uri);
    if (response.statusCode == 200) {
      if (response.body.toString() == "[]") {
        setState(() {
          loadingState = 3;
        });
      } else {
        setState(() {
          loadingState = 1;
        });

        var myBookingsObj = bookingFromJson(response.body.toString());
        return myBookingsObj;
      }
    } else {
      setState(() {
        loadingState = 2;
      });
      return null;
    }
  }

  Widget buildChild() {
  if (loadingState == 0) {
    return Center(
      child: CircularProgressIndicator(),
    );
  } else if (loadingState == 1) {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: listViewMyBookings.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: Card(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.63,
                          child: Text(
                            "There is a notification for you sir",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'cocon-next-arabic-regular',
                              fontWeight: FontWeight.normal,
                              color: grey500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "12/4/2020",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'cocon-next-arabic-regular',
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            onTap: () async {
              // Handle on tap action
            },
          );
        },
      ),
    );
  } else if (loadingState == 2) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 30),
      child: Text(
        AppLocalizations.of(context)!.errorConnectingWithServer,
        style: TextStyle(fontSize: 20.0, fontFamily: 'cocon-next-arabic-regular', color: Colors.grey),
      ),
    );
  } else if (loadingState == 3) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 30),
      child: Text(
        AppLocalizations.of(context)!.noBookingFound,
        style: TextStyle(fontSize: 20.0, fontFamily: 'cocon-next-arabic-regular', color: Colors.grey),
      ),
    );
  }

  // Fallback return to prevent null return (ensure a Widget is always returned)
  return Container();  // This can be any default widget you prefer.
}


  Future<String> getBookingDetails(String bookingID) async {
  EasyLoading.show(status: 'Loading...'); // Show loading indicator

  var response = await http.get(
      '$baseUrl/Booking/GetBookingDetails/?CoupleID=$bookingID&UserAccountID=$userID&Token=$mobileToken' as Uri);

  if (response.statusCode == 200) {
    EasyLoading.dismiss(); // Hide loading indicator
    var editBookingDetailsObj = editBookingDetailsFromJson(response.body.toString());
    setState(() {
      remAttendanceCount = editBookingDetailsObj[0].remAttendanceCount!;
      churchRemarks = editBookingDetailsObj[0].churchRemarks!;
      courseRemarks = editBookingDetailsObj[0].courseRemarks!;
      courseDateAr = editBookingDetailsObj[0].courseDateAr!;
      courseDateEn = editBookingDetailsObj[0].courseDateEn!;
      courseTimeAr = editBookingDetailsObj[0].courseTimeAr!;
      courseTimeEn = editBookingDetailsObj[0].courseTimeEn!;
      churchNameAr = editBookingDetailsObj[0].churchNameAr!;
      churchNameEn = editBookingDetailsObj[0].churchNameEn!;
      coupleID = editBookingDetailsObj[0].coupleId!;
      myFamilyList = editBookingDetailsObj[0].listOfmember!;
      allowEdit = editBookingDetailsObj[0].allowEdit!;
      registrationNumber = editBookingDetailsObj[0].registrationNumber!;
    });
    return "1";
  } else {
    EasyLoading.dismiss(); // Hide loading indicator
    return "0";
  }
}

}
