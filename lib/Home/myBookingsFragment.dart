import 'dart:async';

import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Booking/newBookingActivity.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Models/booking.dart';
import 'package:egpycopsversion4/Models/editBookingDetails.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:egpycopsversion4/l10n/app_localizations.dart';

import '../Booking/editBooking.dart';
import '../Booking/viewBookingDetails.dart';

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
      mobileToken = prefs.getString("mobileToken");
      
      // If no stored token, get from Firebase
      if (mobileToken == null || mobileToken!.isEmpty) {
        try {
          mobileToken = await FirebaseMessaging.instance.getToken();
          debugPrint("[DEBUG] Got Firebase token: ${mobileToken?.substring(0, 20)}...");
        } catch (e) {
          debugPrint("[ERROR] Failed to get Firebase token: $e");
          mobileToken = "";
        }
      }
      
      debugPrint("[DEBUG] Loaded user credentials: userID=$userID, mobileToken=${mobileToken?.isNotEmpty == true ? 'present' : 'missing'}");
      
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

      debugPrint("[DEBUG] GetMyBookings - Status Code: ${response.statusCode}");
      debugPrint("[DEBUG] GetMyBookings - Response Body: ${response.body}");

      if (!mounted) return [];
      if (response.statusCode == 200) {
        if (response.body.toString() == "[]") {
          debugPrint("[DEBUG] GetMyBookings - Empty array returned");
          setState(() => loadingState = 3);
          return [];
        } else {
          debugPrint("[DEBUG] GetMyBookings - Parsing booking data...");
          setState(() => loadingState = 1);
          var myBookingsObj = bookingFromJson(response.body.toString());
          debugPrint("[DEBUG] GetMyBookings - Parsed ${myBookingsObj.length} bookings");
          return myBookingsObj;
        }
      } else {
        debugPrint("[DEBUG] GetMyBookings - HTTP Error: ${response.statusCode}");
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryDarkColor.withOpacity(0.03),
              Colors.white,
              primaryColor.withOpacity(0.02),
            ],
          ),
        ),
        child: Column(
          children: [
            // Modern Header Section
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryDarkColor,
                    primaryColor,
                    logoBlue.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryDarkColor.withOpacity(0.25),
                    offset: const Offset(0, 8),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header title and icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.myBookings ?? "My Bookings",
                              style: const TextStyle(
                                fontSize: 24,
                                fontFamily: 'cocon-next-arabic-regular',
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Manage your liturgy reservations",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // New Booking Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => NewBookingActivity(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: logoBlue.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.add_circle_outline,
                                  color: logoBlue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                AppLocalizations.of(context)?.newBooking ?? "New Booking",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'cocon-next-arabic-regular',
                                  fontWeight: FontWeight.w600,
                                  color: primaryDarkColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: primaryDarkColor.withOpacity(0.6),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bookings List Section
            Expanded(child: buildChild()),
          ],
        ),
      ),
    );
  }

  Widget buildChild() {
    if (loadingState == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryDarkColor.withOpacity(0.08),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Church name skeleton
                  Row(
                    children: [
                      SkeletonAnimation(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: primaryColor.withOpacity(0.2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SkeletonAnimation(
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: primaryColor.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Booking details skeleton
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonAnimation(
                              child: Container(
                                width: 80,
                                height: 12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: logoBlue.withOpacity(0.2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SkeletonAnimation(
                              child: Container(
                                width: 120,
                                height: 16,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: logoBlue.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SkeletonAnimation(
                        child: Container(
                          width: 60,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: primaryDarkColor.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Date and time skeleton
                  SkeletonAnimation(
                    child: Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: primaryColor.withOpacity(0.2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else if (loadingState == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          itemCount: listViewMyBookings.length,
          itemBuilder: (context, index) {
            if (index >= listViewMyBookings.length) return Container();
            
            final booking = listViewMyBookings[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryColor.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryDarkColor.withOpacity(0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: primaryColor.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    try {
                      debugPrint("[DEBUG] Booking item clicked: ${booking["coupleId"]}");
                      debugPrint("[DEBUG] Current userID: $userID");
                      debugPrint("[DEBUG] Current mobileToken: ${mobileToken ?? 'null'}");
                      
                      String connectionResponse = await _checkInternetConnection();
                      debugPrint("[DEBUG] Internet connection: $connectionResponse");
                      
                      if (connectionResponse == '1') {
                        String response = await getBookingDetails(booking["coupleId"] ?? "");
                        debugPrint("[DEBUG] getBookingDetails response: $response");
                        
                        if (!mounted) return;
                        if (response == '1') {
                          // Always show details in view-only mode first
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ViewBookingDetailsActivity(
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
                                allowEdit,
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
                        } else {
                          Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)?.errorConnectingWithServer ?? "Error connecting with server",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.white,
                            textColor: accentColor,
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
                          textColor: accentColor,
                          fontSize: 16.0,
                        );
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with church name and status
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryDarkColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.church,
                                color: primaryDarkColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    myLanguage == "en"
                                        ? (booking["churchNameEn"] ?? "")
                                        : (booking["churchNameAr"] ?? ""),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'cocon-next-arabic-regular',
                                      fontWeight: FontWeight.w600,
                                      color: primaryDarkColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    booking["courseTypeName"] ?? "",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: logoBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "Active",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Booking number section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: logoBlue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: logoBlue.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.confirmation_number_outlined,
                                color: logoBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)?.bookingNumber ?? "Booking Number",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'cocon-next-arabic-regular',
                                  color: primaryDarkColor.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                ":",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: primaryDarkColor.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  booking["registrationNumber"] ?? "",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'cocon-next-arabic-regular',
                                    fontWeight: FontWeight.w700,
                                    color: logoBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),

                        // Attendance Type (if exists)
                         (booking["attendanceTypeID"] == 0)
                            ? Container()
                            : Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.15),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      color: primaryColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)?.attendanceType ?? "Attendance Type",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: primaryDarkColor.withOpacity(0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      ":",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: primaryDarkColor.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        myLanguage == "ar"
                                            ? (booking["attendanceTypeNameAr"] ?? "")
                                            : (booking["attendanceTypeNameEn"] ?? ""),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'cocon-next-arabic-regular',
                                          fontWeight: FontWeight.w600,
                                          color: (booking["attendanceTypeID"] == 1 || booking["attendanceTypeID"] == 2)
                                              ? logoBlue
                                              : primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        
                        // Date and time section
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.15),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: primaryColor,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Date",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: primaryDarkColor.withOpacity(0.6),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      myLanguage == "en"
                                          ? (booking["courseDateEn"] ?? "")
                                          : (booking["courseDateAr"] ?? ""),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'cocon-next-arabic-regular',
                                        fontWeight: FontWeight.w600,
                                        color: primaryDarkColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: logoBlue.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: logoBlue.withOpacity(0.15),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: logoBlue,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Time",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: primaryDarkColor.withOpacity(0.6),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      myLanguage == "en"
                                          ? (booking["courseTimeEn"] ?? "")
                                          : (booking["courseTimeAr"] ?? ""),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'cocon-next-arabic-regular',
                                        fontWeight: FontWeight.w600,
                                        color: primaryDarkColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Footer with action hint
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Tap to view details",
                              style: TextStyle(
                                fontSize: 12,
                                color: primaryColor.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: primaryColor.withOpacity(0.6),
                              size: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else if (loadingState == 2) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)?.errorConnectingWithServer ?? "Error connecting to server",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'cocon-next-arabic-regular',
                  color: primaryDarkColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => getDataFromShared(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDarkColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  "Try Again",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (loadingState == 3) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: logoBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.event_busy,
                  size: 48,
                  color: logoBlue,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)?.noBookingFound ?? "No bookings found",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'cocon-next-arabic-regular',
                  color: primaryDarkColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Create your first booking to get started",
                style: TextStyle(
                  fontSize: 14,
                  color: primaryColor.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Future<void> showLoadingDialog(BuildContext context) async {
    if (!mounted) return;
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false, // This helps prevent navigation conflicts
      builder: (BuildContext dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryDarkColor),
                ),
                const SizedBox(height: 16),
                Text(
                  "Loading booking details...",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'cocon-next-arabic-regular',
                    color: primaryDarkColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> getBookingDetails(String bookingID) async {
    bool dialogShown = false;
    try {
      debugPrint("[DEBUG] getBookingDetails called with bookingID: $bookingID");
      
      // Show the loading dialog and wait for it to be shown
      if (mounted) {
        showLoadingDialog(context);
        dialogShown = true;
        // Add a small delay to ensure dialog is fully shown
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final uri = Uri.parse(
        '$baseUrl/Booking/GetBookingDetails/?CoupleID=$bookingID&UserAccountID=$userID&Token=${mobileToken ?? ""}',
      );
      debugPrint("[DEBUG] API URL: $uri");
      
      final response = await http.get(uri);
      debugPrint("[DEBUG] Response status: ${response.statusCode}");
      debugPrint("[DEBUG] Response body: ${response.body}");

      // Hide the loading dialog safely
      if (mounted && dialogShown) {
        await _safelyDismissDialog();
        dialogShown = false;
      }

      if (response.statusCode == 200) {
        final body = response.body;
        
        if (body.isEmpty || body == "[]" || body == "null") {
          debugPrint("[DEBUG] Empty or null response");
          return "0";
        }
        
        try {
          final editBookingDetailsList = editBookingDetailsFromJson(body);
          debugPrint("[DEBUG] Parsed ${editBookingDetailsList.length} booking details");

          if (editBookingDetailsList.isNotEmpty) {
            final details = editBookingDetailsList.first;
            debugPrint("[DEBUG] First booking details: allowEdit=${details.allowEdit}");

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

            debugPrint("[DEBUG] Successfully updated booking details state");
            return "1";
          } else {
            debugPrint("[DEBUG] Empty booking details list.");
            return "0";
          }
        } catch (parseError) {
          debugPrint("[ERROR] JSON parsing error: $parseError");
          debugPrint("[ERROR] Raw response: $body");
          return "0";
        }
      } else {
        debugPrint("[ERROR] HTTP error: ${response.statusCode}");
        debugPrint("[ERROR] Response body: ${response.body}");
        return "0";
      }
    } catch (e, stackTrace) {
      debugPrint("[ERROR] Exception in getBookingDetails: $e");
      debugPrint("[ERROR] Stack trace: $stackTrace");
      if (mounted && dialogShown) {
        await _safelyDismissDialog();
      }
      return "0";
    }
  }

  // Safe dialog dismissal method to prevent navigation errors
  Future<void> _safelyDismissDialog() async {
    try {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint("[ERROR] Error dismissing dialog safely: $e");
      // If normal pop fails, try to remove the top route
      try {
        if (mounted) {
          Navigator.of(context).removeRoute(ModalRoute.of(context)!);
        }
      } catch (e2) {
        debugPrint("[ERROR] Error removing route: $e2");
      }
    }
  }
}