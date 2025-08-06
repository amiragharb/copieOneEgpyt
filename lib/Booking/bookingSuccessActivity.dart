import 'dart:async';
import 'dart:convert';
import 'package:egpycopsversion4/l10n/app_localizations.dart';

import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Home/homeActivity.dart';
import 'package:egpycopsversion4/Models/addBookingDetails.dart';
import 'package:egpycopsversion4/Translation/localizations.dart' hide AppLocalizations;
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
  final Map<String, dynamic> bookingInfo;

  const BookingSuccessActivity({
    Key? key,
    required this.bookingInfo,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => BookingSuccessActivityState();
}

class BookingSuccessActivityState extends State<BookingSuccessActivity>
    with TickerProviderStateMixin {
  late String courseId = "";
  late String courseTypeName = "";
  late String courseDate = "";
  late String courseTime = "";
  late String churchName = "";

  String mobileToken = "";
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> listViewBookedPersons = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initFirebaseToken();
    setShared(true);
  }

  void _initializeData() {
    final info = widget.bookingInfo;

    courseId = (info["id"] ?? "").toString();
    courseTypeName = (info["courseTypeName"] ?? "").toString();
    courseDate = (info["courseDate"] ?? "").toString();
    courseTime = (info["courseTime"] ?? "").toString();
    churchName = (info["churchName"] ?? "").toString();

    governerateNameAr = (info["governerateNameAr"] ?? info["governerateName"] ?? "").toString();
    governerateNameEn = (info["governerateNameEn"] ?? info["governerateName"] ?? "").toString();
    churchNameAr = (info["churchNameAr"] ?? info["churchName"] ?? "").toString();
    churchNameEn = (info["churchNameEn"] ?? info["churchName"] ?? "").toString();
    courseDateAr = (info["courseDateAr"] ?? info["courseDate"] ?? "").toString();
    courseDateEn = (info["courseDateEn"] ?? info["courseDate"] ?? "").toString();
    courseTimeAr = (info["courseTimeAr"] ?? info["courseTime"] ?? "").toString();
    courseTimeEn = (info["courseTimeEn"] ?? info["courseTime"] ?? "").toString();
    churchRemarks = (info["churchRemarks"] ?? "").toString();
    courseRemarks = (info["courseRemarks"] ?? "").toString();
    bookNumber = (info["bookingNumber"] ?? info["bookNumber"] ?? "").toString();

    attendanceTypeIDAddBooking = info["attendanceTypeID"] ?? 0;
    attendanceTypeNameArAddBooking = (info["attendanceTypeNameAr"] ?? "").toString();
    attendanceTypeNameEnAddBooking = (info["attendanceTypeNameEn"] ?? "").toString();
  }

  Future<void> _initFirebaseToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (mounted) {
        setState(() {
          mobileToken = token ?? "";
        });
      }
    } catch (e) {
      debugPrint("Error getting Firebase token: $e");
    }
  }

  Future<void> setShared(bool isOpened) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("SuccessIsOpened", isOpened);
      personsListListViewData();
    } catch (e) {
      debugPrint("Error in setShared: $e");
    }
  }

  void personsListListViewData() {
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
    final bool isFamilyAccount = attendanceTypeIDAddBooking == 1;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _navigateToHome();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)?.bookingSuccess ?? "Booking Success",
            style: const TextStyle(
              fontFamily: 'cocon-next-arabic-regular',
            ),
          ),
          backgroundColor: primaryDarkColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateToHome,
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 30),
              Text(
                AppLocalizations.of(context)?.bookedSuccessfully ?? "Booked Successfully",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22.0,
                  fontFamily: 'cocon-next-arabic-regular',
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  height: 80,
                  width: 80,
                  child: Image.asset(
                    'images/success.png',
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 80,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (bookNumber.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.bookingNumber ?? "Booking Number",
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      bookNumber,
                      style: const TextStyle(
                        fontSize: 22.0,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(context)?.pleaseSaveBookingNumber ?? "Please save booking number",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16.0, color: Colors.red),
                ),
                const SizedBox(height: 20),
              ],

              _buildDetailRow(context, AppLocalizations.of(context)?.governorate ?? "Governorate",
                  myLanguage == "en" ? governerateNameEn : governerateNameAr),
              _buildDetailRow(context, AppLocalizations.of(context)?.church ?? "Church",
                  myLanguage == "en" ? churchNameEn : churchNameAr),
              _buildDetailRow(context, AppLocalizations.of(context)?.bookingType ?? "Booking Type",
                  courseTypeName),

              if (attendanceTypeIDAddBooking != 0)
                _buildDetailRow(
                    context,
                    AppLocalizations.of(context)?.attendanceType ?? "Attendance Type",
                    myLanguage == "en" ? attendanceTypeNameEnAddBooking : attendanceTypeNameArAddBooking),

              _buildDetailRow(context, AppLocalizations.of(context)?.liturgyDate ?? "Liturgy Date",
                  myLanguage == "en" ? courseDateEn : courseDateAr),
              _buildDetailRow(context, AppLocalizations.of(context)?.liturgyTime ?? "Liturgy Time",
                  myLanguage == "en" ? courseTimeEn : courseTimeAr),

              if (isFamilyAccount && listViewBookedPersons.isNotEmpty)
                ..._buildFamilyMembersSection(),

              if (courseRemarks.isNotEmpty || churchRemarks.isNotEmpty)
                ..._buildRemarksSection(),

              const SizedBox(height: 30),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            width: double.maxFinite,
            height: 60,
            margin: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDarkColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              onPressed: _navigateToHome,
              child: Text(
                AppLocalizations.of(context)?.backToHome ?? "Back to Home",
                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFamilyMembersSection() {
    return [
      const SizedBox(height: 16),
      Text(
        AppLocalizations.of(context)?.familyMembers ?? "Family Members",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      ListView.builder(
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: listViewBookedPersons.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildPersonDetailRow(
                  AppLocalizations.of(context)?.name ?? "Name",
                  listViewBookedPersons[index]["name"] ?? "",
                  Colors.blueAccent),
                const SizedBox(height: 8),
                _buildPersonDetailRow(
                  AppLocalizations.of(context)?.nationalId ?? "National ID",
                  listViewBookedPersons[index]["nationalID"] ?? "",
                  Colors.grey),
              ]),
            ),
          );
        },
      )
    ];
  }

  List<Widget> _buildRemarksSection() {
    return [
      const SizedBox(height: 16),
      if (courseRemarks.isNotEmpty)
        Text(courseRemarks, style: const TextStyle(fontSize: 16.0, color: Colors.red)),
      if (churchRemarks.isNotEmpty)
        Text(churchRemarks, style: const TextStyle(fontSize: 16.0, color: Colors.black)),
    ];
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600))),
        const Text(': ', style: TextStyle(fontSize: 16.0)),
        Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 16.0, color: Colors.green, fontWeight: FontWeight.w500))),
      ]),
    );
  }

  Widget _buildPersonDetailRow(String label, String value, Color valueColor) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
      const Text(': ', style: TextStyle(fontSize: 16)),
      Expanded(child: Text(value, style: TextStyle(fontSize: 16, color: valueColor, fontWeight: FontWeight.w500))),
    ]);
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeActivity(false)),
      ModalRoute.withName("/Home"),
    );
  }
}
