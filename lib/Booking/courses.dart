import 'dart:async';
import 'dart:convert';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Booking/bookingSuccessActivity.dart';
import 'package:egpycopsversion4/Booking/chooseBookingFamilyMembersActivity.dart';
import 'package:egpycopsversion4/Booking/newBookingActivity.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Models/addBookingDetails.dart';
import 'package:egpycopsversion4/Models/courseTime.dart';
import 'package:egpycopsversion4/Translation/localizations.dart' hide AppLocalizations;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:skeleton_text/skeleton_text.dart';
import 'package:egpycopsversion4/l10n/app_localizations.dart';

BaseUrl BASE_URL = BaseUrl();
String baseUrl = BASE_URL.BASE_URL;

// 🔹 Variables globales
String userID = "";
String mobileToken = "";
String myLanguage = "";
String chosenDate = "", branchID = "";
int loadingState = 0;
String churchNameEn = "", churchNameAr = "";

// 🔹 Variables Booking
String bookNumberAddBooking = "";
String courseDateArAddBooking = "";
String courseDateEnAddBooking = "";
String courseTimeArAddBooking = "";
String courseTimeEnAddBooking = "";
String churchRemarksAddBooking = "";
String courseRemarksAddBooking = "";
String churchNameArAddBooking = "";
String churchNameEnAddBooking = "";
String governerateNameArAddBooking = "";
String governerateNameEnAddBooking = "";
String firstAttendDate = "";
int attendanceTypeIDAddBooking = 0;
String attendanceTypeNameEnAddBooking = "";
String attendanceTypeNameArAddBooking = "";
String remainingCountFailure = "0";
String failureMessage = "";
List<dynamic> bookedPersonsList = [];

class CoursesActivity extends StatefulWidget {
  CoursesActivity(
      String chosenDateConstructor,
      String branchIDConstructor,
      String churchNameEnConstructor,
      String churchNameArConstructor) {
    chosenDate = chosenDateConstructor;
    branchID = branchIDConstructor;
    churchNameEn = churchNameEnConstructor;
    churchNameAr = churchNameArConstructor;
  }

  @override
  _CoursesActivityState createState() => _CoursesActivityState();
}

class _CoursesActivityState extends State<CoursesActivity> {
  List<CourseTime> coursesList = [];
  List<Map<String, dynamic>> listViewCourses = [];

  late BuildContext mContext;

  @override
  void initState() {
    super.initState();
    loadingState = 0;
    getSharedData();
  }

  Future<void> getSharedData() async {
    mobileToken = await FirebaseMessaging.instance.getToken() ?? "";
    print("Token: $mobileToken");

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    myLanguage = (prefs.getString('language') ?? "en");
    userID = prefs.getString("userID") ?? "";
    final accountType = prefs.getString("accountType") ?? "2"; // 1=Family, 2=Personal
    print("Account type: $accountType");

    final result = await getCourses();
    coursesList = result ?? [];
    if (loadingState == 1 && coursesList.isNotEmpty) {
      coursesListViewData();
    }
  }

  void coursesListViewData() {
    setState(() {
      listViewCourses.clear();
      for (var course in coursesList) {
        listViewCourses.add(course.toJson());
      }
    });
  }

  String convertArabicNumbersToLatin(String input) {
    final arabicNums = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < arabicNums.length; i++) {
      input = input.replaceAll(arabicNums[i], i.toString());
    }
    return input;
  }

  Future<List<CourseTime>> getCourses() async {
    String latinDate = convertArabicNumbersToLatin(chosenDate);

    final uri = Uri.parse(
        '$baseUrl/Booking/GetCourseTimeByDate/?BranchID=$branchID&CourseDate=$latinDate&UserAccountID=$userID&token=$mobileToken');
    print("Request URL: $uri");

    final response = await http.get(uri);
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      if (response.body == "[]" || response.body == "0") {
        setState(() => loadingState = 2);
        return [];
      } else {
        setState(() => loadingState = 1);
        return courseTimeFromJson(response.body);
      }
    } else {
      setState(() => loadingState = 2);
      return [];
    }
  }

  Future<void> makeBooking(Map<String, dynamic> course) async {
    final courseID = course['ID'] ?? course['id'];

    if (courseID == null) {
      print("❌ CourseID est invalide : null");
      Fluttertoast.showToast(
msg: AppLocalizations.of(context)?.errorConnectingWithServer ?? "Invalid CourseID",
      );
      return;
    }

    final successCode = await addBooking(userID, courseID.toString());

    if (successCode == "1") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingSuccessActivity(
            bookingInfo: {
              "BookNumber": bookNumberAddBooking,
              "CourseDateEn": courseDateEnAddBooking,
              "CourseDateAr": courseDateArAddBooking,
              "CourseTimeEn": courseTimeEnAddBooking,
              "CourseTimeAr": courseTimeArAddBooking,
              "ChurchNameEn": churchNameEnAddBooking,
              "ChurchNameAr": churchNameArAddBooking,
            },
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: failureMessage.isNotEmpty
            ? failureMessage
            : AppLocalizations.of(context)?.errorConnectingWithServer ?? "Booking failed",

      );
    }
  }

  Future<String?> addBooking(String chosenMembers, String? courseID) async {
    if (courseID == null || courseID.isEmpty || courseID == "null") {
      print("❌ CourseID est invalide : $courseID");
      Fluttertoast.showToast(
        msg: myLanguage == "ar"
            ? "معرف الدورة غير صالح"
            : AppLocalizations.of(context)?.errorConnectingWithServer ?? "Invalid Course ID"
,
      );
      return "0";
    }

    try {
      final url = Uri.parse(
        '$baseUrl/Booking/AddBooking/?'
        'listAccountMemberIDs=$chosenMembers'
        '&CourseID=$courseID'
        '&UserAccountID=$userID'
        '&AttendanceTypeID=$attendanceTypeIDAddBooking'
        '&Token=$mobileToken',
      );

      print("🌐 API Call URL: $url");

      final response = await http.post(url);
      print("📡 Response Status Code: ${response.statusCode}");
      print("📄 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final myAddBookingDetailsObj = addBookingDetailsFromJson(response.body);

        failureMessage = (myLanguage == "ar")
            ? (myAddBookingDetailsObj.errorMessageAr ?? "")
            : (myAddBookingDetailsObj.errorMessageEn ?? "");

        bookNumberAddBooking = myAddBookingDetailsObj.bookNumber ?? "";
        courseDateArAddBooking = myAddBookingDetailsObj.courseDateAr ?? "";
        courseDateEnAddBooking = myAddBookingDetailsObj.courseDateEn ?? "";
        courseTimeArAddBooking = myAddBookingDetailsObj.courseTimeAr ?? "";
        courseTimeEnAddBooking = myAddBookingDetailsObj.courseTimeEn ?? "";
        churchRemarksAddBooking = myAddBookingDetailsObj.churchRemarks ?? "";
        courseRemarksAddBooking = myAddBookingDetailsObj.courseRemarks ?? "";
        churchNameArAddBooking = myAddBookingDetailsObj.churchNameAr ?? "";
        churchNameEnAddBooking = myAddBookingDetailsObj.churchNameEn ?? "";
        governerateNameArAddBooking = myAddBookingDetailsObj.governerateNameAr ?? "";
        governerateNameEnAddBooking = myAddBookingDetailsObj.governerateNameEn ?? "";
        firstAttendDate = myAddBookingDetailsObj.firstAttendDate ?? "";
        attendanceTypeIDAddBooking = myAddBookingDetailsObj.attendanceTypeID ?? 0;
        attendanceTypeNameEnAddBooking = myAddBookingDetailsObj.attendanceTypeNameEn ?? "";
        attendanceTypeNameArAddBooking = myAddBookingDetailsObj.attendanceTypeNameAr ?? "";
        remainingCountFailure = myAddBookingDetailsObj.remAttendanceCount ?? "0";
        bookedPersonsList = myAddBookingDetailsObj.personList;

        return myAddBookingDetailsObj.sucessCode;
      } else {
        failureMessage = myLanguage == "ar"
            ? "فشل الحجز، يرجى المحاولة لاحقاً"
            : AppLocalizations.of(context)?.errorConnectingWithServer ?? "Booking failed, please try again later"
;
        return "0";
      }
    } catch (e) {
      print("❗️Error in addBooking(): $e");
      failureMessage = myLanguage == "ar"
          ? "حدث خطأ أثناء الاتصال بالخادم"
          : AppLocalizations.of(context)?.errorConnectingWithServer ?? "An error occurred while connecting to the server";
      return "0";
    }
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
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
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppLocalizations.of(context)?.chooseHolyLiturgyDate ??
              "Choose Holy Liturgy Date",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            fontFamily: 'cocon-next-arabic-regular',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: buildChild(),
    );
  }

  Widget buildChild() {
    if (loadingState == 0) {
      return _buildSkeletonList();
    } else if (loadingState == 1 && listViewCourses.isNotEmpty) {
      return _buildCoursesList();
    } else {
      return Center(
        child: Text(
          AppLocalizations.of(context)?.errorConnectingWithServer ??
              "Error connecting with server",
          style: const TextStyle(
            fontSize: 20.0,
            fontFamily: 'cocon-next-arabic-regular',
            color: Colors.grey,
          ),
        ),
      );
    }
  }

  Widget _buildSkeletonList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.all(14.0),
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      height: 15,
                      width: MediaQuery.of(context).size.width * 0.7,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 110,
                      height: 13,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesList() {
    return ListView.builder(
      itemCount: listViewCourses.length,
      itemBuilder: (BuildContext context, int index) {
        var course = listViewCourses[index];

        return GestureDetector(
          onTap: () async {
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            final accountType = prefs.getString("accountType") ?? "2";

            if (course['AvaliableAttendanceTypes'] != null &&
                course['AvaliableAttendanceTypes'].isNotEmpty) {
              attendanceTypeIDAddBooking = course['AvaliableAttendanceTypes'][0]['ID'] ?? 0;
              attendanceTypeNameArAddBooking = course['AvaliableAttendanceTypes'][0]['NameAr'] ?? "";
              attendanceTypeNameEnAddBooking = course['AvaliableAttendanceTypes'][0]['NameEn'] ?? "";
            } else {
              attendanceTypeIDAddBooking = 0;
              attendanceTypeNameArAddBooking = "";
              attendanceTypeNameEnAddBooking = "";
            }

            final courseID = course['ID'] ?? course['id'];

            if (courseID == null) {
              Fluttertoast.showToast(
msg: AppLocalizations.of(context)?.errorConnectingWithServer ?? "Invalid CourseID",
              );
              return;
            }

            if (accountType == "1") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChooseBookingFamilyMembersActivity(
                    (course['RemAttendanceCount'] ?? 0).toString(),
                    course['ChurchRemarks']?.toString() ?? "",
                    course['CourseRemarks']?.toString() ?? "",
                    course['CourseDateAr']?.toString() ?? "",
                    course['CourseDateEn']?.toString() ?? "",
                    course['CourseTimeAr']?.toString() ?? "",
                    course['CourseTimeEn']?.toString() ?? "",
                    course['ChurchNameAr']?.toString() ?? "",
                    course['ChurchNameEn']?.toString() ?? "",
                    courseID.toString(),
                    course['CourseTypeName']?.toString() ?? "",
                    attendanceTypeIDAddBooking,
                    attendanceTypeNameArAddBooking,
                    attendanceTypeNameEnAddBooking,
                  ),
                ),
              );
            } else {
              await makeBooking(course);
            }
          },
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: logoBlue, width: 1),
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    myLanguage == "en"
                        ? course["NameEn"] ?? ""
                        : course["NameAr"] ?? "",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'cocon-next-arabic-regular',
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    myLanguage == "en"
                        ? (course["CourseTimeEn"] ?? "")
                        : (course["CourseTimeAr"] ?? ""),
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'cocon-next-arabic-regular',
                      color: primaryDarkColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
