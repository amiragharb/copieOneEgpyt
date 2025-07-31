import 'dart:async';
import 'dart:io';

import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Booking/calendarOfBookings.dart';
import 'package:egpycopsversion4/Booking/chooseBookingFamilyMembersActivity.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Models/churchs.dart';
import 'package:egpycopsversion4/Models/courseDetails.dart';
import 'package:egpycopsversion4/Models/courses.dart';
import 'package:egpycopsversion4/Models/governorates.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  churchOfAttendanceDropDownData() async {
  print("[DEBUG] churchOfAttendanceDropDownData - start");
  final SharedPreferences prefs = await SharedPreferences.getInstance();

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
          "nameEn": "Choose Church",
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
  listDropGovernorates.clear();
  print("[DEBUG] listDropGovernorates CLEARED");

  listDropGovernorates.add({
    "id": "0",
    "nameAr": "اختار المحافظة",
    "nameEn": "Choose Governorate",
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
  governoratesList = await getGovernoratesByUserID() ?? [];
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
    appBar: AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      title: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(
          AppLocalizations.of(context)?.newBooking ?? "New Booking",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
        ),
      ),
      backgroundColor: primaryDarkColor,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    bottomNavigationBar: null, // <-- bouton supprimé
    body: childWidget,
  );
}



Widget buildChild() {
  print("[DEBUG] buildChild() called with loadingState=$loadingState");

  if (loadingState == 0) {
    print("[DEBUG] loadingState==0: Showing skeleton loader");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(14.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, bottom: 5.0),
                        child: SkeletonAnimation(
                          child: Container(
                            height: 15,
                            width: MediaQuery.of(context).size.width * 0.7,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 5.0),
                        child: SkeletonAnimation(
                          child: Container(
                            width: 110,
                            height: 13,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  } else if (loadingState == 1) {
    print("[DEBUG] loadingState==1: Showing main booking form");
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: double.infinity,
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                showGovernoratesLayout(),
                showChurchOfAttendanceLayout(context),
                showCourses(context),
                availableSeats(),
              ],
            ),
          ),
        ),
      ),
    );
  } else if (loadingState == 2) {
    print("[DEBUG] loadingState==2: Showing error message");
    return Center(
      child: Text(
        AppLocalizations.of(context)?.errorConnectingWithServer ?? "Error connecting to server",
        style: const TextStyle(
          fontSize: 20.0,
          fontFamily: 'cocon-next-arabic-regular',
          color: Colors.grey,
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

    Widget seatInfo;
    if (seats > 10) {
      print("[DEBUG] Case: seats > 10");
      seatInfo = IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Text(AppLocalizations.of(context)?.thereAre ?? "There are",
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: 'cocon-next-arabic-regular',
                  color: primaryDarkColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 8.0, bottom: 8.0, right: 5.0),
              child: Text(
                attendanceTypeIDNewBooking == 3 ? remAttendanceDeaconCount : remAttendanceCount,
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: 'cocon-next-arabic-regular',
                  color: Colors.green,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(AppLocalizations.of(context)?.availableSeat ?? "Available seat",
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
    } else if (seats > 1) {
      print("[DEBUG] Case: 2 <= seats <= 10");
      seatInfo = IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context)?.thereAre ?? "There are",
              style: TextStyle(
                fontSize: 18.0,
                fontFamily: 'cocon-next-arabic-regular',
                color: Colors.redAccent,
                fontWeight: FontWeight.normal,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: Text(
                attendanceTypeIDNewBooking == 3
                    ? remAttendanceDeaconCount
                    : remAttendanceCount,
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: 'cocon-next-arabic-regular',
                  color: Colors.redAccent,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Text(AppLocalizations.of(context)?.availableSeats ?? "Available Seats",
              style: TextStyle(
                fontSize: 18.0,
                fontFamily: 'cocon-next-arabic-regular',
                color: Colors.redAccent,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    } else {
      print("[DEBUG] Case: seats <= 1");
      seatInfo = IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context)?.thereIs ?? "There is",
              style: TextStyle(
                fontSize: 18.0,
                fontFamily: 'cocon-next-arabic-regular',
                color: Colors.redAccent,
                fontWeight: FontWeight.normal,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: Text(
                attendanceTypeIDNewBooking == 3
                    ? remAttendanceDeaconCount
                    : remAttendanceCount,
                style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: 'cocon-next-arabic-regular',
                  color: Colors.redAccent,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Text(AppLocalizations.of(context)?.availableSeatSingular ?? "Seat",
              style: TextStyle(
                fontSize: 18.0,
                fontFamily: 'cocon-next-arabic-regular',
                color: Colors.redAccent,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0, left: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // ... autres widgets inchangés ...
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Container(
                width: double.infinity,
                child: Text(
                  myLanguage == "ar" ? courseDateAr : courseDateEn,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'cocon-next-arabic-regular',
                    color: primaryDarkColor,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
            attendanceTypeIDNewBooking == 0 ? Container() : Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Container(
                width: double.infinity,
                child: Text(
                  AppLocalizations.of(context)?.attendanceType ?? "Attendance Type",
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            attendanceTypeIDNewBooking == 0 ? Container() : Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Container(
                width: double.infinity,
                child: Text(
                  myLanguage == "ar"
                      ? attendanceTypeNameArNewBooking
                      : attendanceTypeNameEnNewBooking,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'cocon-next-arabic-regular',
                    color: attendanceTypeIDNewBooking == 3 ? accentColor : logoBlue,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  AppLocalizations.of(context)?.time ?? "Time",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            myLanguage == "en"
                ? Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        courseTimeEn,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontFamily: 'cocon-next-arabic-regular',
                          color: primaryDarkColor,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Container(
                      width: double.infinity,
                      child: Text(
                        courseTimeAr,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontFamily: 'cocon-next-arabic-regular',
                          color: primaryDarkColor,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
            seatInfo,
            courseRemarks.isEmpty
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      courseRemarks,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: 'cocon-next-arabic-regular',
                        color: Colors.redAccent,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
            churchRemarks.isEmpty
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
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
      ),
    );
  } else if (availableSeatsState == 2) {
    print("[DEBUG] availableSeatsState == 2: No seats available");
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)?.noSeatsAvailable ?? "No seats available",
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
    );
  } else if (availableSeatsState == 3) {
    print("[DEBUG] availableSeatsState == 3: Loading spinner");
    return Center(
      child: CircularProgressIndicator(),
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
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: DropdownButton(
        value: governorateID,
        isExpanded: true,
        items: listDropGovernorates.map((Map map) {
          print("[DEBUG] DropdownMenuItem: id = ${map["id"]}, label = ${map[nameKey]}");
          return DropdownMenuItem<String>(
            value: map["id"].toString(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 5.0, right: 5.0),
                  child: MyBullet(),
                ),
                Expanded(
                  child: Text(
                    map[nameKey],
                    overflow: TextOverflow.ellipsis,
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
    await getChurchWithGovernorateID(); // <- ATTENDS la fin
    print("[DEBUG] getChurchWithGovernorateID() terminé, churchOfAttendanceList = $churchOfAttendanceList");
  }
},

      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
    child: Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalizations.of(context)?.governorate ?? "Governorate",
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          myLanguage == "en"
              ? buildDropdown("nameEn")
              : buildDropdown("nameAr"),
        ],
      ),
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
  // principal widget
  Widget buildDropdown(String nameKey) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: DropdownButton(
        value: churchOfAttendanceID,
        isExpanded: true,
        itemHeight: 95,
        items: listDropChurchOfAttendance.map((Map map) {
          print("[DEBUG] DropdownMenuItem: id = ${map["id"]}, label = ${map[nameKey]}");
          return DropdownMenuItem<String>(
            value: map["id"].toString(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, left: 5.0, right: 5.0),
                  child: MyBullet(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Text(
                      map[nameKey],
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        color: primaryDarkColor,
                        fontSize: 20.0,
                        fontFamily: 'cocon-next-arabic-regular',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) async { // <- async ici !
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
              dateState = 2; // show loading indicator
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
    );
  }

  // Return principal (inchangé)
  return Padding(
    padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
    child: Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalizations.of(context)?.church ?? "Church",
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          myLanguage == "en"
              ? buildDropdown("nameEn")
              : buildDropdown("nameAr"),
        ],
      ),
    ),
  );
}

 Widget showCourses(BuildContext context) {
  print("[DEBUG] showCourses() called, dateState = $dateState, flagAddCourse = $flagAddCourse, courseID = $courseID");

  if (dateState == 0) {
    print("[DEBUG] showCourses: dateState == 0, returning empty Container");
    return Container();
  } else if (dateState == 2) {
    print("[DEBUG] showCourses: dateState == 2, showing CircularProgressIndicator");
    return Center(child: CircularProgressIndicator());
  } else {
    print("[DEBUG] showCourses: dateState != 0 && != 2, showing course selection UI");
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                flagAddCourse
                    ? Container()
                    : Text(
                        AppLocalizations.of(context)?.bookingType ?? "Booking Type",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                !flagAddCourse
                    ? GestureDetector(
                        onTap: () {
                          print("[DEBUG] showCourses: Edit button tapped, navigating to CalendarOfBookingsActivity with churchOfAttendanceID = $churchOfAttendanceID, branchNameAr = $branchNameAr, branchNameEn = $branchNameEn");
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => CalendarOfBookingsActivity(
  churchOfAttendanceID: churchOfAttendanceID,
  churchNameAr: branchNameAr,
  churchNameEn: branchNameEn,
)

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
                          decoration: BoxDecoration(
                            border: Border.all(color: logoBlue),
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                                  child: Text(
                                    AppLocalizations.of(context)?.modify ?? "Modify",
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      color: logoBlue,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                                  child: Icon(
                                    Icons.edit,
                                    color: logoBlue,
                                    size: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
            flagAddCourse
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      courseTypeName ?? "",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: primaryDarkColor,
                      ),
                    ),
                  ),
            flagAddCourse
                ? Container()
                : Text(
                    AppLocalizations.of(context)?.holyLiturgyDate ?? "Holy Liturgy Date",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 0,
              ),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width - 100,
                  height: flagAddCourse ? 50.0 : 0,
                  child: flagAddCourse
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryDarkColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () {
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
                          child: Text(
                            AppLocalizations.of(context)?.chooseHolyLiturgyDate ?? "Choose Holy Liturgy Date",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: 'cocon-next-arabic-regular',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        )
                      : Container(),
                ),
              ),
            ),
          ],
        ),
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
