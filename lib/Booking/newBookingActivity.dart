import 'dart:async';

import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Booking/calendarOfBookings.dart';
import 'package:egpycopsversion4/Booking/chooseBookingFamilyMembersActivity.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Models/churchs.dart';
import 'package:egpycopsversion4/Models/courseDetails.dart';
import 'package:egpycopsversion4/Models/courses.dart';
import 'package:egpycopsversion4/Models/governorates.dart';
import 'package:egpycopsversion4/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:skeleton_text/skeleton_text.dart';

typedef void LocaleChangeCallback(Locale locale);

String accountType = "";

BaseUrl BASE_URL = new BaseUrl();
String baseUrl = BASE_URL.BASE_URL;
bool flagAddCourse=false;
int availableSeatsState = 0;
String myLanguage="";
int loadingState = 0;
int dateState = 0;
bool isDateChosen = false;
bool isChurchChosen = false;
String churchOfAttendanceID = "0";
String governorateID="";
String courseID = "0";
String churchNameAr ="",
    churchNameEn="",
    remAttendanceCount="",
    remAttendanceDeaconCount="",
    churchRemarks="",
    courseRemarks="",
    courseDateAr="",
    courseDateEn="",
    courseTimeAr="",
    courseTimeEn="",
    courseTypeName="";
int defaultGovernateID=0, defaultBranchID=0;
String branchNameAr="", branchNameEn="";
int attendanceTypeIDNewBooking=0;
String attendanceTypeNameArNewBooking="", attendanceTypeNameEnNewBooking="";

class NewBookingActivity extends StatefulWidget {
  final Map<String, dynamic>? selectedCourse;

  const NewBookingActivity([this.selectedCourse, Key? key]) : super(key: key);

  @override
  _NewBookingActivityState createState() => _NewBookingActivityState();
}

class _NewBookingActivityState extends State<NewBookingActivity>
 {
  List<Map> listDropChurchOfAttendance = [];
  List<Map> listDropGovernorates = [];
  List<Map> listDropCourses = [];
  String mobileToken="";

  List<Churchs> churchOfAttendanceList = [];
List<Governorates> governoratesList = [];
List<Course> coursesList = [];

  String userBranchID = "0";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when language changes
    _refreshLocalizedData();
  }

  void _refreshLocalizedData() {
    // Refresh dropdown data with new language
    if (mounted) {
      governoratesDropDownData();
      churchOfAttendanceDropDownData();
      coursesDropDownData();
    }
  }

  String getLocalizedText(String? arText, String? enText) {
    if (myLanguage == "ar") {
      return arText ?? enText ?? "";
    } else {
      return enText ?? arText ?? "";
    }
  }

  churchOfAttendanceDropDownData() async {
  print("[DEBUG] churchOfAttendanceDropDownData - start");
  final localizations = AppLocalizations.of(context);

  listDropChurchOfAttendance.clear();
  print("[DEBUG] churchOfAttendanceList length: ${churchOfAttendanceList.length}");
  // SUPPRIME cette ligne ! churchOfAttendanceList = (await getChurchs(governorateID))!;
  // print("[DEBUG] churchOfAttendanceList after getChurchs: $churchOfAttendanceList");

  if (churchOfAttendanceList.length > 0) {
    setState(() {
      listDropChurchOfAttendance
        ..add({
          "id": "0",
          "nameAr": "اختار الكنيسة",
          "nameEn": localizations?.church ?? "Choose Church",
          "isDefualt": false
        });

      String tempID = "";

      for (int i = 0; i < churchOfAttendanceList.length; i++) {
        print("[DEBUG] Add church id: ${churchOfAttendanceList[i].id}");
        listDropChurchOfAttendance.add({
          "id": churchOfAttendanceList.elementAt(i).id,
          "nameAr": churchOfAttendanceList.elementAt(i).nameAr,
          "nameEn": churchOfAttendanceList.elementAt(i).nameEn,
          "isDefualt": churchOfAttendanceList.elementAt(i).isDefualt
        });
        if(userBranchID == churchOfAttendanceList.elementAt(i).id.toString()){
          tempID = userBranchID;
        }
      }
      if(tempID.isEmpty){
        churchOfAttendanceID = "0";
      }else{
        churchOfAttendanceID = tempID;
      }
      print("[DEBUG] churchOfAttendanceID = $churchOfAttendanceID");
    });
  }
  print("[DEBUG] churchOfAttendanceDropDownData - end");
}

@override
void initState() {
  super.initState();
  print("[DEBUG] initState() called");
  getSharedData();
}

coursesDropDownData() async {
  print("[DEBUG] coursesDropDownData - START");
  listDropCourses.clear();
  print("[DEBUG] listDropCourses CLEARED");
  print("[DEBUG] coursesList.length = ${coursesList.length}");

  if (coursesList.length > 0) {
    setState(() {
      print("[DEBUG] setState: Adding default 'Choose date' item");
      listDropCourses.add({
        "id": "0",
        "nameAr": "اختار التاريخ",
        "nameEn": "Choose date",
        "isDefualt": false
      });

      for (int i = 0; i < coursesList.length; i++) {
        print("[DEBUG] Adding course: id=${coursesList[i].id}, nameAr=${coursesList[i].nameAr}, nameEn=${coursesList[i].nameEn}");
        listDropCourses.add({
          "id": coursesList[i].id,
          "nameAr": coursesList[i].nameAr,
          "nameEn": coursesList[i].nameEn,
          "isDefualt": coursesList[i].isDefualt
        });
      }
      print("[DEBUG] setState: Finished adding courses. listDropCourses.length=${listDropCourses.length}");
    });
  } else {
    setState(() {
      availableSeatsState = 2;
      print("[DEBUG] setState: coursesList is EMPTY, availableSeatsState=2");
    });
  }
  print("[DEBUG] coursesDropDownData - END");
}


  Future<void> governoratesDropDownData() async {
  print("[DEBUG] governoratesDropDownData - START");
  final localizations = AppLocalizations.of(context);
  
  listDropGovernorates.clear();
  print("[DEBUG] listDropGovernorates CLEARED");

  listDropGovernorates.add({
    "id": "0",
    "nameAr": "اختار المحافظة",
    "nameEn": localizations?.governorate ?? "Choose Governorate",
    "isDefualt": false,
  });
  print("[DEBUG] Added default governorate option");

  for (var gov in governoratesList) {
    print("[DEBUG] Adding governorate: id=${gov.id}, nameAr=${gov.nameAr}, isDefualt=${gov.isDefualt}");
    listDropGovernorates.add({
      "id": gov.id,
      "nameAr": gov.nameAr,
      "nameEn": gov.nameEn,
      "isDefualt": gov.isDefualt,
    });

    if (gov.isDefualt == true) {
      governorateID = gov.id.toString();
      print("[DEBUG] Default governorate detected: governorateID=$governorateID");
    }
  }

  setState(() {
    print("[DEBUG] setState called in governoratesDropDownData");
  }); // Mise à jour unique
  print("[DEBUG] governoratesDropDownData - END");
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
  debugPrint("[DEBUG] getGovernoratesByUserID - start");

  try {
    final url = '$baseUrl/Booking/GetGovernoratesByUserID/?UserAccountID=$userID';
    debugPrint("[DEBUG] GET $url");

    final response = await http.get(Uri.parse(url));

    debugPrint("[DEBUG] Response status: ${response.statusCode}");
    debugPrint("[DEBUG] Response body: ${response.body}");

    if (response.statusCode == 200) {
      debugPrint('[DEBUG] governoratesFromJson success');

      final governoratesList = governoratesFromJson(response.body);
      debugPrint('[DEBUG] governoratesList length: ${governoratesList.length}');

      return governoratesList;
    } else {
      debugPrint("[ERROR] getGovernoratesByUserID: HTTP error code ${response.statusCode}");
      Fluttertoast.showToast(msg: "Server error ${response.statusCode}. Please try again later.");
      return [];
    }
  } catch (e, stack) {
    debugPrint("[ERROR] getGovernoratesByUserID: Exception $e");
    debugPrint(stack.toString());

    Fluttertoast.showToast(msg: "Network error. Please check your connection.");
    return [];
  }
}




 Future<List<Churchs>?> getChurchs(String governorateID) async {
  print("[DEBUG] getChurchs() - START (governorateID: $governorateID)");
  final url = '$baseUrl/Booking/GetChurch/?GovernerateID=$governorateID';
  print("[DEBUG] GET $url");
  var response = await http.get(Uri.parse(url));
  print("[DEBUG] Response status: ${response.statusCode}");
  print("[DEBUG] Response body: ${response.body}");

  if (response.statusCode == 200) {
    var churchsObj = churchsFromJson(response.body.toString());
    print("[DEBUG] getChurchs: churchsObj = $churchsObj");
    return churchsObj;
  } else {
    print("[ERROR] getChurchs: HTTP error code ${response.statusCode}");
    return null;
   }
}


  Future<List<Course>?> getCourses(String churchID) async {
  print("[DEBUG] getCourses() - START (churchID: $churchID)");
  setState(() {
    flagAddCourse = true;
    print("[DEBUG] setState: flagAddCourse = true");
  });

  try {
    final url = '$baseUrl/Booking/GetCourses/?BranchID=$churchID';
    print("[DEBUG] GET $url");
    var response = await http.get(Uri.parse(url));
    print("[DEBUG] Response status: ${response.statusCode}");
    print("[DEBUG] Response body: ${response.body}");

    if (response.statusCode == 200) {
      if (response.body.toString() == "[]") {
        print("[DEBUG] getCourses: response empty list");
        setState(() {
          dateState = 0;
          isDateChosen = true;
          isChurchChosen = false;
          print("[DEBUG] setState: dateState=0, isDateChosen=true, isChurchChosen=false");
        });
      } else {
        print("[DEBUG] getCourses: response not empty");
        setState(() {
          dateState = 1;
          isChurchChosen = true;
          print("[DEBUG] setState: dateState=1, isChurchChosen=true");
        });
      }
      print('[DEBUG] getCourses: HTTP 200, parsing JSON');
      var coursesObj = courseFromJson(response.body.toString());
      print('[DEBUG] getCourses: Parsed courses: $coursesObj');
      print("[DEBUG] getCourses() - END SUCCESS");
      return coursesObj;
    } else {
      print("[ERROR] getCourses: HTTP error code ${response.statusCode}");
      setState(() {
        dateState = 0;
        isDateChosen = true;
        isChurchChosen = false;
        print("[DEBUG] setState: dateState=0, isDateChosen=true, isChurchChosen=false");
      });
      print("[DEBUG] getCourses() - END ERROR");
      return null;
    }
  } catch (e, stack) {
    print("[ERROR] getCourses: Exception $e");
    print(stack);
    setState(() {
      dateState = 0;
      isDateChosen = true;
      isChurchChosen = false;
      print("[DEBUG] setState: dateState=0, isDateChosen=true, isChurchChosen=false (exception)");
    });
    return null;
  }
}
Future<CourseDetails?> getCourseDetails(String courseID) async {
  print("[DEBUG] getCourseDetails() - START (courseID: $courseID)");
  try {
    final url = '$baseUrl/Booking/GetCourseDetails/?CourseID=$courseID&UserAccountID=$userID&token=$mobileToken';
    print("[DEBUG] GET $url");
    var response = await http.get(Uri.parse(url));
    print("[DEBUG] Response status: ${response.statusCode}");
    print("[DEBUG] Response body: ${response.body}");

    if (response.statusCode == 200) {
      print('[DEBUG] getCourseDetails: HTTP 200, parsing JSON');
      var courseDetailsObj = courseDetailsFromJson(response.body.toString());
      print('[DEBUG] getCourseDetails: Parsed object: $courseDetailsObj');
      setState(() {
        flagAddCourse = false;
        availableSeatsState = 1;
        remAttendanceCount = courseDetailsObj.remAttendanceCount.toString();
        remAttendanceDeaconCount = courseDetailsObj.remAttendanceDeaconCount.toString();
        churchRemarks = courseDetailsObj.churchRemarks.toString();
        churchNameEn = courseDetailsObj.churchNameEn.toString();
        churchNameAr = courseDetailsObj.churchNameAr.toString();
        courseRemarks = courseDetailsObj.courseRemarks.toString();
        courseDateAr = courseDetailsObj.courseDateAr.toString();
        courseDateEn = courseDetailsObj.courseDateEn.toString();
        courseTimeAr = courseDetailsObj.courseTimeAr.toString();
        courseTimeEn = courseDetailsObj.courseTimeEn.toString();
        courseTypeName = courseDetailsObj.courseTypeName.toString();
        print("[DEBUG] setState: course details variables set");
      });
      print("[DEBUG] getCourseDetails() - END SUCCESS");
      return courseDetailsObj;
    } else {
      print("[ERROR] getCourseDetails: HTTP error code ${response.statusCode}");
      print("[DEBUG] getCourseDetails() - END ERROR");
      return null;
    }
  } catch (e, stack) {
    print("[ERROR] getCourseDetails: Exception $e");
    print(stack);
    print("[DEBUG] getCourseDetails() - END EXCEPTION");
    return null;
  }
}

  @override
  void dispose() {
    super.dispose();
  }

  String userID = "";

 Future<void> getSharedData() async {
  print("[DEBUG] getSharedData() START");

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  myLanguage = prefs.getString('language') ?? "en";
  userID = prefs.getString("userID") ?? "";
  accountType = prefs.getString("accountType") ?? "0";

  defaultGovernateID = prefs.getInt("governateID") ?? 0;
  defaultBranchID = prefs.getInt("branchID") ?? 0;

  print("[DEBUG] prefs loaded: myLanguage=$myLanguage, userID=$userID, accountType=$accountType");

  // Charge governorates (tu peux logger ici aussi)
  governoratesList = await getGovernoratesByUserID();
  print("[DEBUG] governoratesList length: ${governoratesList.length}");

  if (governoratesList.isNotEmpty) {
    await governoratesDropDownData();
    setState(() {
      loadingState = 1;
      print("[DEBUG] loadingState SET TO 1");
    });
  } else {
    setState(() {
      loadingState = 2;
      print("[DEBUG] loadingState SET TO 2 (governoratesList empty)");
    });
  }
  print("[DEBUG] getSharedData() END, loadingState=$loadingState");
}

@override
Widget build(BuildContext context) {
  print("[DEBUG] build() called - loadingState=$loadingState");

  Widget childWidget = buildChild();
  print("[DEBUG] build() - buildChild() returned widget: ${childWidget.runtimeType}");

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
              primaryColor,
              logoBlue.withOpacity(0.8),
            ],
          ),
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
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white, size: 28),
          title: Column(
            children: [
              const SizedBox(height: 25),
              Text(
                AppLocalizations.of(context)?.newBooking ?? "New Booking",
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
            primaryDarkColor.withOpacity(0.03),
            Colors.white,
            primaryColor.withOpacity(0.02),
          ],
        ),
      ),
      child: childWidget,
    ),
  );
}



Widget buildChild() {
  print("[DEBUG] buildChild() called with loadingState=$loadingState");

  if (loadingState == 0) {
    print("[DEBUG] loadingState==0: Showing skeleton loader");
    return Container(
      padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
      child: Column(
        children: [
          // Modern shimmer header
          Container(
            margin: const EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                SkeletonAnimation(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SkeletonAnimation(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SkeletonAnimation(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  } else if (loadingState == 1) {
    print("[DEBUG] loadingState==1: Showing main booking form");
    return Container(
      padding: const EdgeInsets.only(top: 100),
      child: Form(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Welcome header
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryDarkColor.withOpacity(0.1),
                        accentColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryDarkColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryDarkColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.event_available,
                          color: primaryDarkColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.newBooking ?? "New Booking",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: primaryDarkColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Book your Holy Liturgy attendance",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                showGovernoratesLayout(),
                showChurchOfAttendanceLayout(context),
                showCourses(context),
                availableSeats(),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  } else if (loadingState == 2) {
    print("[DEBUG] loadingState==2: Showing error message");
    return Container(
      padding: const EdgeInsets.only(top: 120),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)?.errorConnectingWithServer ?? "Error connecting to server",
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'cocon-next-arabic-regular',
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  loadingState = 0;
                });
                getSharedData();
              },
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
  }

  print("[DEBUG] buildChild() - DEFAULT RETURN");
  return Container();
}

  Widget availableSeats() {
  print("[DEBUG] availableSeats() called, availableSeatsState = $availableSeatsState");

  if (availableSeatsState == 1) {
    int seats = int.parse(attendanceTypeIDNewBooking == 3 ? remAttendanceDeaconCount : remAttendanceCount);
    print("[DEBUG] seats = $seats, attendanceTypeIDNewBooking = $attendanceTypeIDNewBooking");
    print("[DEBUG] courseDateAr = $courseDateAr, courseDateEn = $courseDateEn");
    print("[DEBUG] attendanceTypeNameArNewBooking = $attendanceTypeNameArNewBooking, attendanceTypeNameEnNewBooking = $attendanceTypeNameEnNewBooking");
    print("[DEBUG] courseTimeAr = $courseTimeAr, courseTimeEn = $courseTimeEn");
    print("[DEBUG] courseRemarks = $courseRemarks, churchRemarks = $churchRemarks");

    // Determine seat availability status
    Color seatColor;
    IconData seatIcon;
    if (seats > 10) {
      seatColor = Colors.green;
      seatIcon = Icons.event_seat;
    } else if (seats > 1) {
      seatColor = Colors.orange;
      seatIcon = Icons.event_seat;
    } else {
      seatColor = Colors.red;
      seatIcon = Icons.event_busy;
    }

    Widget seatInfo = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: seatColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: seatColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            seatIcon,
            color: seatColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          if (seats > 10) ...[
            Text(
              AppLocalizations.of(context)?.thereAre ?? "There are",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'cocon-next-arabic-regular',
                color: seatColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              attendanceTypeIDNewBooking == 3 ? remAttendanceDeaconCount : remAttendanceCount,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'cocon-next-arabic-regular',
                color: seatColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              AppLocalizations.of(context)?.availableSeat ?? "Available seat",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'cocon-next-arabic-regular',
                color: seatColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else if (seats > 1) ...[
            Text(
              AppLocalizations.of(context)?.thereAre ?? "There are",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'cocon-next-arabic-regular',
                color: seatColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              attendanceTypeIDNewBooking == 3 ? remAttendanceDeaconCount : remAttendanceCount,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'cocon-next-arabic-regular',
                color: seatColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "Available Seats",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'cocon-next-arabic-regular',
                color: seatColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else ...[
            Text(
              AppLocalizations.of(context)?.thereIs ?? "There is",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'cocon-next-arabic-regular',
                color: seatColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              attendanceTypeIDNewBooking == 3 ? remAttendanceDeaconCount : remAttendanceCount,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'cocon-next-arabic-regular',
                color: seatColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "Seat",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'cocon-next-arabic-regular',
                color: seatColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Date Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryDarkColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: primaryDarkColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Liturgy Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryDarkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Date Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryDarkColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              myLanguage == "ar" ? courseDateAr : courseDateEn,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'cocon-next-arabic-regular',
                color: primaryDarkColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Attendance Type Section
          if (attendanceTypeIDNewBooking != 0) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)?.attendanceType ?? "Attendance Type",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryDarkColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (attendanceTypeIDNewBooking == 3 ? accentColor : logoBlue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (attendanceTypeIDNewBooking == 3 ? accentColor : logoBlue).withOpacity(0.3),
                ),
              ),
              child: Text(
                myLanguage == "ar" ? attendanceTypeNameArNewBooking : attendanceTypeNameEnNewBooking,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'cocon-next-arabic-regular',
                  color: attendanceTypeIDNewBooking == 3 ? accentColor : logoBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          
          // Time Section
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: logoBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time,
                  color: logoBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)?.time ?? "Time",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryDarkColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: logoBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              myLanguage == "en" ? courseTimeEn : courseTimeAr,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'cocon-next-arabic-regular',
                color: primaryDarkColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Seats Section
          const SizedBox(height: 20),
          seatInfo,
          
          // Remarks sections
          if (courseRemarks.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      courseRemarks,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'cocon-next-arabic-regular',
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (churchRemarks.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryDarkColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryDarkColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: primaryDarkColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      churchRemarks,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'cocon-next-arabic-regular',
                        color: primaryDarkColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Continue button
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green,
                  Colors.green.shade600,
                  Colors.teal,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChooseBookingFamilyMembersActivity(
                        attendanceTypeIDNewBooking == 3 ? remAttendanceDeaconCount : remAttendanceCount,
                        churchRemarks,
                        courseRemarks,
                        courseDateAr,
                        courseDateEn,
                        courseTimeAr,
                        courseTimeEn,
                        churchNameAr,
                        churchNameEn,
                        courseID,
                        courseTypeName,
                        attendanceTypeIDNewBooking,
                        attendanceTypeNameArNewBooking,
                        attendanceTypeNameEnNewBooking,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Continue to Family Selection",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  } else if (availableSeatsState == 2) {
    print("[DEBUG] availableSeatsState == 2: No seats available");
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.event_busy,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.noSeatsAvailable ?? "No seats available",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'cocon-next-arabic-regular',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  } else if (availableSeatsState == 3) {
    print("[DEBUG] availableSeatsState == 3: Loading spinner");
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryDarkColor),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              "Loading booking details...",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  } else {
    print("[DEBUG] availableSeatsState == $availableSeatsState: Empty Container");
    return Container();
  }
}

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
        width: 1.5,
        color: accentColor,
      ),
      borderRadius: BorderRadius.all(
          Radius.circular(15.0) //                 <--- border radius here
          ),
    );
  }

  Widget showGovernoratesLayout() {
  print("[DEBUG] showGovernoratesLayout() called, myLanguage = $myLanguage");
  print("[DEBUG] listDropGovernorates = $listDropGovernorates");
  print("[DEBUG] governorateID current = $governorateID");

  Widget buildDropdown(String nameKey) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: governorateID != "0" 
              ? primaryDarkColor.withOpacity(0.3)
              : Colors.grey.shade300,
          width: 1.5,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButton(
          value: governorateID,
          isExpanded: true,
          underline: const SizedBox(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryDarkColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: primaryDarkColor,
              size: 20,
            ),
          ),
          items: listDropGovernorates.map((Map map) {
            print("[DEBUG] DropdownMenuItem: id = ${map["id"]}, label = ${map[nameKey]}");
            return DropdownMenuItem<String>(
              value: map["id"].toString(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: map["id"].toString() == "0" 
                            ? Colors.grey.shade400
                            : primaryDarkColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        map[nameKey],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: map["id"].toString() == "0" 
                              ? Colors.grey.shade500
                              : primaryDarkColor,
                          fontSize: 16,
                          fontFamily: 'cocon-next-arabic-regular',
                          fontWeight: map["id"].toString() == "0" 
                              ? FontWeight.w400
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (value) async {
            print("[DEBUG] Dropdown changed, selected governorateID = $value");
            setState(() {
              governorateID = value!;
              print("[DEBUG] setState: governorateID = $governorateID, reset fields");
              availableSeatsState = 0;
              dateState = 0;
              churchOfAttendanceID = "0";
              courseID = "0";
              listDropCourses.clear();
              listDropChurchOfAttendance.clear();
              remAttendanceCount = "0";
              remAttendanceDeaconCount = "0";
              print("[DEBUG] After reset: availableSeatsState=$availableSeatsState, dateState=$dateState, churchOfAttendanceID=$churchOfAttendanceID, courseID=$courseID");
            });
            if (value != "0") {
              print("[DEBUG] Awaiting getChurchWithGovernorateID() for governorateID = $governorateID");
              await getChurchWithGovernorateID();
              print("[DEBUG] getChurchWithGovernorateID() terminé, churchOfAttendanceList = $churchOfAttendanceList");
            }
          },
        ),
      ),
    );
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryDarkColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_city,
                color: primaryDarkColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)?.governorate ?? "Governorate",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryDarkColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        myLanguage == "en"
            ? buildDropdown("nameEn")
            : buildDropdown("nameAr"),
      ],
    ),
  );
}


 getChurchWithGovernorateID() async {
  print("[DEBUG] getChurchWithGovernorateID() called with governorateID = $governorateID");
  setState(() {
    flagAddCourse = true;
  });
  try {
    var churchList = await getChurchs(governorateID);
    print("[DEBUG] getChurchWithGovernorateID: churchList = $churchList");
    if (churchList != null && churchList.isNotEmpty) {
      churchOfAttendanceList = churchList;
      await churchOfAttendanceDropDownData();
      print("[DEBUG] churchOfAttendanceDropDownData done, listDropChurchOfAttendance = $listDropChurchOfAttendance");
    } else {
      print("[DEBUG] churchList is null or empty");
      setState(() {
        churchOfAttendanceList = [];
        listDropChurchOfAttendance = [];
      });
    }
  } catch (e, s) {
    print("[ERROR] Exception in getChurchWithGovernorateID: $e\n$s");
  }
  print("[DEBUG] getChurchWithGovernorateID() end.");
}

getCoursesWithChurchID() async {
  print("[DEBUG] getCoursesWithChurchID() called with churchOfAttendanceID = $churchOfAttendanceID");

  for (int i = 0; i < churchOfAttendanceList.length; i++) {
    if (churchOfAttendanceID == churchOfAttendanceList.elementAt(i).id.toString()) {
      branchNameAr = churchOfAttendanceList.elementAt(i).nameAr!;
      branchNameEn = churchOfAttendanceList.elementAt(i).nameEn!;
      print("[DEBUG] branch found: branchNameAr = $branchNameAr, branchNameEn = $branchNameEn");
    }
  }
  try {
    var courses = await getCourses(churchOfAttendanceID);
    if (courses == null) {
      print("[ERROR] getCoursesWithChurchID: getCourses() returned null!");
      coursesList = [];
    } else {
      print("[DEBUG] getCoursesWithChurchID: getCourses() returned ${courses.length} items.");
      coursesList = courses;
    }
    await coursesDropDownData();
    print("[DEBUG] getCoursesWithChurchID: coursesDropDownData() called");
  } catch (e, stack) {
    print("[ERROR] Exception in getCoursesWithChurchID: $e");
    print(stack);
  }
  print("[DEBUG] getCoursesWithChurchID() end.");
}

getCourseDetailsWithCourseID() async {
  print("[DEBUG] getCourseDetailsWithCourseID() called with courseID = $courseID");
  try {
    await getCourseDetails(courseID);
    print("[DEBUG] getCourseDetailsWithCourseID: getCourseDetails() finished");
  } catch (e, stack) {
    print("[ERROR] Exception in getCourseDetailsWithCourseID: $e");
    print(stack);
  }
  print("[DEBUG] getCourseDetailsWithCourseID() end.");
}


  Widget showChurchOfAttendanceLayout(BuildContext context) {
  print("[DEBUG] showChurchOfAttendanceLayout() called, myLanguage = $myLanguage");
  print("[DEBUG] listDropChurchOfAttendance = $listDropChurchOfAttendance");
  print("[DEBUG] churchOfAttendanceID current = $churchOfAttendanceID");
  
  // Don't show if no governorate is selected
  if (governorateID == "0" || listDropChurchOfAttendance.isEmpty) {
    return Container();
  }

  Widget buildDropdown(String nameKey) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: churchOfAttendanceID != "0" 
              ? primaryDarkColor.withOpacity(0.3)
              : Colors.grey.shade300,
          width: 1.5,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButton(
          value: churchOfAttendanceID,
          isExpanded: true,
          underline: const SizedBox(),
          itemHeight: null,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryDarkColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: primaryDarkColor,
              size: 20,
            ),
          ),
          items: listDropChurchOfAttendance.map((Map map) {
            print("[DEBUG] DropdownMenuItem: id = ${map["id"]}, label = ${map[nameKey]}");
            return DropdownMenuItem<String>(
              value: map["id"].toString(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: map["id"].toString() == "0" 
                            ? Colors.grey.shade400
                            : accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        map[nameKey],
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          color: map["id"].toString() == "0" 
                              ? Colors.grey.shade500
                              : primaryDarkColor,
                          fontSize: 16,
                          fontFamily: 'cocon-next-arabic-regular',
                          fontWeight: map["id"].toString() == "0" 
                              ? FontWeight.w400
                              : FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (value) async {
            print("[DEBUG] Dropdown changed, selected churchOfAttendanceID = $value");
            setState(() {
              churchOfAttendanceID = value!;
              courseID = "0";
              availableSeatsState = 0;
              remAttendanceCount = "0";
              remAttendanceDeaconCount = "0";
            });

            if (value != "0") {
              print("[DEBUG] Non-zero selection: loading courses for church $churchOfAttendanceID");
              setState(() {
                dateState = 2;
                isDateChosen = false;
                isChurchChosen = false;
              });
              await getCoursesWithChurchID();
            } else {
              print("[DEBUG] Zero selection: reset all related fields");
              setState(() {
                remAttendanceCount = "0";
                remAttendanceDeaconCount = "0";
                isDateChosen = false;
                isChurchChosen = false;
                dateState = 0;
              });
            }
            print("[DEBUG] After change: churchOfAttendanceID=$churchOfAttendanceID, courseID=$courseID, availableSeatsState=$availableSeatsState, dateState=$dateState");
          },
        ),
      ),
    );
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.church,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)?.church ?? "Church",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryDarkColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        myLanguage == "en"
            ? buildDropdown("nameEn")
            : buildDropdown("nameAr"),
      ],
    ),
  );
}

 Widget showCourses(BuildContext context) {
  print("[DEBUG] showCourses() called, dateState = $dateState, flagAddCourse = $flagAddCourse, courseID = $courseID");

  // Don't show if no church is selected
  if (churchOfAttendanceID == "0") {
    return Container();
  }

  if (dateState == 0) {
    print("[DEBUG] showCourses: dateState == 0, returning empty Container");
    return Container();
  } else if (dateState == 2) {
    print("[DEBUG] showCourses: dateState == 2, showing CircularProgressIndicator");
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryDarkColor),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              "Loading liturgy dates...",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  } else {
    print("[DEBUG] showCourses: dateState != 0 && != 2, showing course selection UI");
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (!flagAddCourse) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: logoBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.event_note,
                        color: logoBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)?.bookingType ?? "Booking Type",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: primaryDarkColor,
                      ),
                    ),
                  ],
                ),
                // Edit button
                GestureDetector(
                  onTap: () {
                    print("[DEBUG] showCourses: Edit button tapped, navigating to CalendarOfBookingsActivity with churchOfAttendanceID = $churchOfAttendanceID, branchNameAr = $branchNameAr, branchNameEn = $branchNameEn");
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => CalendarOfBookingsActivity(
                          churchOfAttendanceID: churchOfAttendanceID,
                          churchNameAr: branchNameAr,
                          churchNameEn: branchNameEn,
                        ),
                      ),
                    ).then((value) {
                      print("[DEBUG] showCourses: CalendarOfBookingsActivity returned, courseID = $courseID");
                      if (courseID != "0") {
                        print("[DEBUG] showCourses: courseID != 0, reloading course details");
                        setState(() {
                          availableSeatsState = 3;
                          remAttendanceCount = "0";
                          remAttendanceDeaconCount = "0";
                        });
                        getCourseDetailsWithCourseID();
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: logoBlue.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                      color: logoBlue.withOpacity(0.05),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context)?.modify ?? "Modify",
                          style: TextStyle(
                            fontSize: 14,
                            color: logoBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.edit,
                          color: logoBlue,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          // Course type name (when not adding course)
          if (!flagAddCourse) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryDarkColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryDarkColor.withOpacity(0.1),
                ),
              ),
              child: Text(
                courseTypeName,
                style: TextStyle(
                  fontSize: 16,
                  color: primaryDarkColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)?.holyLiturgyDate ?? "Holy Liturgy Date",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryDarkColor,
                  ),
                ),
              ],
            ),
          ],

          // Choose Holy Liturgy Date Button
          if (flagAddCourse) ...[
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryDarkColor,
                      primaryColor,
                      logoBlue.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryDarkColor.withOpacity(0.3),
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
                      print("[DEBUG] showCourses: Choose Holy Liturgy Date button tapped. Navigating to CalendarOfBookingsActivity.");
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => CalendarOfBookingsActivity(
                            churchOfAttendanceID: churchOfAttendanceID,
                            churchNameAr: branchNameAr,
                            churchNameEn: branchNameEn,
                          ),
                        ),
                      ).then((value) {
                        print("[DEBUG] showCourses: CalendarOfBookingsActivity returned, courseID = $courseID");
                        if (courseID != "0") {
                          print("[DEBUG] showCourses: courseID != 0, reloading course details");
                          setState(() {
                            availableSeatsState = 3;
                            remAttendanceCount = "0";
                            remAttendanceDeaconCount = "0";
                          });
                          getCourseDetailsWithCourseID();
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)?.chooseHolyLiturgyDate ?? "Choose Holy Liturgy Date",
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'cocon-next-arabic-regular',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}}

class MyBullet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5.0,
      width: 5.0,
      decoration: BoxDecoration(
        color: primaryDarkColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
