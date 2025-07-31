import 'dart:async';

import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Booking/newBookingActivity.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Models/booking.dart';
import 'package:egpycopsversion4/Models/editBookingDetails.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Translation/localizations.dart' hide AppLocalizations;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:egpycopsversion4/l10n/app_localizations.dart';
import 'package:egpycopsversion4/Booking/newBookingActivity.dart';

import '../Booking/editBooking.dart';

BaseUrl BASE_URL = BaseUrl();
String baseUrl = BASE_URL.BASE_URL;
String myLanguage = "en";

String remAttendanceCount = "";
String remAttendanceDeaconCount = "";
String churchRemarks = "";
String courseRemarks = "";
String courseDateAr = "";
String courseDateEn = "";
String courseTimeAr = "";
String courseTimeEn = "";
String churchNameAr = "";
String churchNameEn = "";
String registrationNumber = "";
String courseTypeName = "";
String coupleID = "";
String attendanceTypeNameEn = "";
String attendanceTypeNameAr = "";
int attendanceTypeID = 0;
bool allowEdit = false;
List<EditFamilyMember> myFamilyList = [];

int attendanceType = 1;

class MyBookingsFragment extends StatefulWidget {
  const MyBookingsFragment({Key? key}) : super(key: key);

  @override
  _MyBookingsFragmentState createState() => _MyBookingsFragmentState();
}

class _MyBookingsFragmentState extends State<MyBookingsFragment> {
  List<Booking> myBookingsList = [];
  List<Map<String, dynamic>> listViewMyBookings = [];
  final ScrollController _scrollController = ScrollController();
  int loadingState = 0;
  String? userID = "";
  String? mobileToken;

  @override
  void initState() {
    super.initState();
    _initFirebaseToken();
    loadingState = 0;
    getDataFromShared();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // Pagination logic here if needed
      }
    });
  }

  Future<void> _initFirebaseToken() async {
    try {
      mobileToken = await FirebaseMessaging.instance.getToken();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Error getting Firebase token: $e");
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

  Future<void> getDataFromShared() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      myLanguage = (prefs.getString('language') ?? "en");
      userID = prefs.getString("userID") ?? "";
      if (mounted) setState(() => loadingState = 0);

      String connectionResponse = await _checkInternetConnection();
      if (connectionResponse == '1') {
        myBookingsList = await getMyBookings();
        if (mounted && loadingState == 1 && myBookingsList.isNotEmpty) {
          myBookingsListViewData();
        }
      } else {
        if (!mounted) return;
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => NoInternetConnectionActivity()))
            .then((value) async {
          myBookingsList = await getMyBookings();
          if (mounted && loadingState == 1 && myBookingsList.isNotEmpty) {
            myBookingsListViewData();
          }
        });
      }
    } catch (e) {
      debugPrint("Error in getDataFromShared: $e");
      if (mounted) setState(() => loadingState = 2);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void myBookingsListViewData() {
    if (!mounted) return;
    setState(() {
      listViewMyBookings.clear();
      for (final b in myBookingsList) {
        listViewMyBookings.add({
          "courseDateOfBook": b.courseDateOfBook ?? "",
          "courseDateAr": b.courseDateAr ?? "",
          "courseDateEn": b.courseDateEn ?? "",
          "branchNameEn": b.branchNameEn ?? "",
          "courseTimeAr": b.courseTimeAr ?? "",
          "courseTimeEn": b.courseTimeEn ?? "",
          "churchNameAr": b.churchNameAr ?? "",
          "churchNameEn": b.churchNameEn ?? "",
          "courseNameAr": b.courseNameAr ?? "",
          "courseTypeName": b.courseTypeName ?? "",
          "courseNameEn": b.courseNameEn ?? "",
          "coupleId": b.coupleId ?? "",
          "remAttendanceCount": b.remAttendanceCount ?? "",
          "registrationNumber": b.registrationNumber ?? "",
          "attendanceTypeID": b.attendanceTypeID ?? 0,
          "attendanceTypeNameEn": b.attendanceTypeNameEn ?? "",
          "attendanceTypeNameAr": b.attendanceTypeNameAr ?? "",
        });
      }
    });
  }

  Future<List<Booking>> getMyBookings() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      userID = prefs.getString("userID") ?? "";
      if (mobileToken == null || mobileToken!.isEmpty) {
        mobileToken = await FirebaseMessaging.instance.getToken();
      }
      final uri = Uri.parse('$baseUrl/Booking/GetMyBookings/?UserAccountID=$userID&Token=${mobileToken ?? ""}');
      final response = await http.get(uri);

      if (!mounted) return [];
      if (response.statusCode == 200) {
        if (response.body.toString() == "[]") {
          setState(() => loadingState = 3);
          return [];
        } else {
          setState(() => loadingState = 1);
          var myBookingsObj = bookingFromJson(response.body.toString());
          return myBookingsObj;
        }
      } else {
        setState(() => loadingState = 2);
        return [];
      }
    } catch (e) {
      debugPrint("Error in getMyBookings: $e");
      if (mounted) setState(() => loadingState = 2);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
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
               onPressed: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => NewBookingActivity(),
    ),
  );
},

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    const SizedBox(width: 8.0),
                    Text(
                      AppLocalizations.of(context)?.newBooking ?? "New Booking",
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontFamily: 'cocon-next-arabic-regular',
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              AppLocalizations.of(context)?.myBookings ?? "My Bookings",
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'cocon-next-arabic-regular',
                fontWeight: FontWeight.normal,
                color: primaryDarkColor,
              ),
              maxLines: 1,
            ),
          ),
          Expanded(child: buildChild()),
        ],
      ),
    );
  }

  Widget buildChild() {
    if (loadingState == 0) {
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(14.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white70),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonAnimation(
                          child: Container(
                            height: 15,
                            width: MediaQuery.of(context).size.width * 0.7,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        SkeletonAnimation(
                          child: Container(
                            width: 110,
                            height: 13,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        SkeletonAnimation(
                          child: Container(
                            width: 80,
                            height: 13,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        SkeletonAnimation(
                          child: Container(
                            width: 80,
                            height: 13,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else if (loadingState == 1) {
      return ListView.builder(
        controller: _scrollController,
        itemCount: listViewMyBookings.length,
        itemBuilder: (context, index) {
          if (index >= listViewMyBookings.length) return Container();
          
          final booking = listViewMyBookings[index];
          return GestureDetector(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      myLanguage == "en"
                          ? (booking["churchNameEn"] ?? "")
                          : (booking["churchNameAr"] ?? ""),
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'cocon-next-arabic-regular',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)?.bookingNumber ?? "Booking Number",
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'cocon-next-arabic-regular',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              ":",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'cocon-next-arabic-regular',
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          Text(
                            booking["registrationNumber"] ?? "",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'cocon-next-arabic-regular',
                              fontWeight: FontWeight.normal,
                              color: logoBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
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
                              booking["courseTypeName"] ?? "",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: logoBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    (booking["attendanceTypeID"] == 0)
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
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
                                        ? (booking["attendanceTypeNameAr"] ?? "")
                                        : (booking["attendanceTypeNameEn"] ?? ""),
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: (booking["attendanceTypeID"] == 1 || booking["attendanceTypeID"] == 2)
                                          ? logoBlue
                                          : accentColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                    Text(
                      myLanguage == "en"
                          ? (booking["courseNameEn"] ?? "")
                          : (booking["courseNameAr"] ?? ""),
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'cocon-next-arabic-regular',
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () async {
              try {
                String connectionResponse = await _checkInternetConnection();
                if (connectionResponse == '1') {
                  String response = await getBookingDetails(booking["coupleId"] ?? "");
                  if (!mounted) return;
                  if (response == '1') {
                    if (!allowEdit) {
                      Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)?.sorryYouCannotEditThisBooking ?? "Sorry, you cannot edit this booking",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.white,
                        textColor: Colors.red,
                        fontSize: 16.0,
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditBookingActivity(
                            remAttendanceCount.isEmpty ? "0" : remAttendanceCount,
                            churchRemarks,
                            courseRemarks,
                            courseDateAr,
                            courseDateEn,
                            courseTimeAr,
                            courseTimeEn,
                            churchNameAr,
                            churchNameEn,
                            coupleID,
                            myFamilyList,
                            registrationNumber,
                            courseTypeName,
                            attendanceTypeID,
                            attendanceTypeNameAr,
                            attendanceTypeNameEn,
                          ),
                        ),
                      ).then((value) async {
                        if (!mounted) return;
                        loadingState = 0;
                        myBookingsList.clear();
                        listViewMyBookings.clear();
                        myBookingsList = await getMyBookings();
                        if (mounted && loadingState == 1 && myBookingsList.isNotEmpty) {
                          myBookingsListViewData();
                        }
                      });
                    }
                  } else {
                    Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)?.errorConnectingWithServer ?? "Error connecting with server",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.white,
                      textColor: Colors.red,
                      fontSize: 16.0,
                    );
                  }
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => NoInternetConnectionActivity(),
                    ),
                  );
                }
              } catch (e) {
                debugPrint("Error in onTap: $e");
                if (mounted) {
                  Fluttertoast.showToast(
                    msg: "An error occurred",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.white,
                    textColor: Colors.red,
                    fontSize: 16.0,
                  );
                }
              }
            },
          );
        },
      );
    } else if (loadingState == 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Text(
            AppLocalizations.of(context)?.errorConnectingWithServer ?? "Error connecting with server",
            style: const TextStyle(
              fontSize: 20.0,
              fontFamily: 'cocon-next-arabic-regular',
              color: Colors.grey,
            ),
          ),
        ),
      );
    } else if (loadingState == 3) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image(
                image: const ExactAssetImage('images/online_booking.png'),
                color: Colors.grey,
                width: 60,
                height: 60,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(context)?.noBookingFound ?? "No booking found",
                style: const TextStyle(
                  fontSize: 20.0,
                  fontFamily: 'cocon-next-arabic-regular',
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Future<void> showLoadingDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<String> getBookingDetails(String bookingID) async {
    try {
      // Show the loading dialog
      await showLoadingDialog(context);

      final uri = Uri.parse(
        '$baseUrl/Booking/GetBookingDetails/?CoupleID=$bookingID&UserAccountID=$userID&Token=${mobileToken ?? ""}',
      );
      final response = await http.get(uri);

      // Hide the loading dialog
      if (mounted) Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final body = response.body;
        final editBookingDetailsList = editBookingDetailsFromJson(body);

        if (editBookingDetailsList.isNotEmpty) {
          final details = editBookingDetailsList.first;

          setState(() {
            remAttendanceCount = details.remAttendanceCount?.toString() ?? "0";
            remAttendanceDeaconCount = details.remAttendanceDeaconCount?.toString() ?? "0";
            churchRemarks = details.churchRemarks ?? '';
            courseRemarks = details.courseRemarks ?? '';
            courseDateAr = details.courseDateAr ?? '';
            courseDateEn = details.courseDateEn ?? '';
            courseTimeAr = details.courseTimeAr ?? '';
            courseTimeEn = details.courseTimeEn ?? '';
            churchNameAr = details.churchNameAr ?? '';
            churchNameEn = details.churchNameEn ?? '';
            coupleID = details.coupleId?.toString() ?? '';
            myFamilyList = details.listOfmember ?? [];
            allowEdit = details.allowEdit ?? false;
            registrationNumber = details.registrationNumber ?? '';
            courseTypeName = details.courseTypeName ?? '';
            attendanceTypeID = details.attendanceTypeID ?? 0;
            attendanceTypeNameEn = details.attendanceTypeNameEn ?? '';
            attendanceTypeNameAr = details.attendanceTypeNameAr ?? '';
          });

          return "1";
        } else {
          debugPrint("Empty booking details list.");
          return "0";
        }
      } else {
        debugPrint("Failed to fetch booking details: ${response.statusCode}");
        return "0";
      }
    } catch (e) {
      debugPrint("Error in getBookingDetails: $e");
      if (mounted) Navigator.of(context).pop(); // Hide loading dialog
      return "0";
    }
  }
}