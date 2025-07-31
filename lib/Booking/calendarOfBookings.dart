import 'dart:convert';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Booking/chooseBookingFamilyMembersActivity.dart';
import 'package:egpycopsversion4/Booking/courses.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Models/calendarCourses.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

class CalendarOfBookingsActivity extends StatefulWidget {
  final String churchOfAttendanceID;
  final String churchNameAr;
  final String churchNameEn;

  const CalendarOfBookingsActivity({
    Key? key,
    required this.churchOfAttendanceID,
    required this.churchNameAr,
    required this.churchNameEn,
  }) : super(key: key);

  @override
  _CalendarOfBookingsActivityState createState() => _CalendarOfBookingsActivityState();
}

class _CalendarOfBookingsActivityState extends State<CalendarOfBookingsActivity> {
  late Map<DateTime, List<dynamic>> _events;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences prefs;
  String myLanguage = "en";
  String mobileToken = "";
  int loadingState = 0;
  List<CalendarCourse> coursesList = [];
  String userID = "";
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String month = "";
  String year = "";

  @override
  void initState() {
    super.initState();
    _events = {};
    loadingState = 0;
    _focusedDay = DateTime.now();
    month = _focusedDay.month.toString();
    year = _focusedDay.year.toString();
    getSharedData();
  }

  Future<void> getSharedData() async {
    prefs = await SharedPreferences.getInstance();
    myLanguage = (prefs.getString('language') ?? "en");
    userID = prefs.getString("userID") ?? "";
    mobileToken = (await FirebaseMessaging.instance.getToken()) ?? "";

    coursesList = await getCourseByCalender();

    _events.clear(); // 🔹 Important : réinitialiser à chaque chargement

    for (var course in coursesList) {
      for (int j = 0; j < (course.timeCount ?? 0); j++) {
        // 🔹 Normalisation des dates en UTC sans heure
        final parsedDate = DateTime.parse("${course.courseDate}T00:00:00.000Z");
        final normalizedDate = DateTime.utc(parsedDate.year, parsedDate.month, parsedDate.day);

        _events.update(
          normalizedDate,
          (value) => value..add("1"),
          ifAbsent: () => ["1"],
        );
      }
    }
    setState(() {});
  }

  Future<List<CalendarCourse>> getCourseByCalender() async {
    final baseUrl = BaseUrl().BASE_URL;
    final uri = Uri.parse(
        '$baseUrl/Booking/GetCourseByCalender/?BranchID=${widget.churchOfAttendanceID}&Month=$month&Year=$year&UserAccountID=$userID&token=$mobileToken');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      loadingState = 1;
      return calendarCourseFromJson(response.body.toString());
    } else {
      loadingState = 2;
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            AppLocalizations.of(context)?.chooseHolyLiturgyDate2 ?? "Choose Holy Liturgy Date",
            style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.normal),
          ),
        ),
        backgroundColor: primaryDarkColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: buildChild(context),
    );
  }

  Widget buildChild(BuildContext context) {
    if (loadingState == 0) {
      return const Center(child: CircularProgressIndicator());
    } else if (loadingState == 1) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                myLanguage == "en" ? widget.churchNameEn : widget.churchNameAr,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'cocon-next-arabic-regular',
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: (day) {
                // 🔹 Normalisation du jour pour correspondre aux clés _events
                final normalizedDay = DateTime.utc(day.year, day.month, day.day);
                return _events[normalizedDay] ?? [];
              },
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;

                  final normalizedDay = DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
                  final events = _events[normalizedDay] ?? [];

                  if (events.isNotEmpty) {
                    final formatted = DateFormat('yyyy-MM-dd').format(selectedDay);
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (_) => CoursesActivity(
                                  formatted,
                                  widget.churchOfAttendanceID,
                                  widget.churchNameEn,
                                  widget.churchNameAr,
                                )))
                        .then((value) {
                      // Action après retour (si besoin)
                    });
                  } else {
                    Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)?.noSeatsAvailable ?? "No seats available",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.white,
                        textColor: Colors.red);
                  }
                });
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                weekendTextStyle: TextStyle(color: Colors.red),
              ),
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                month = focusedDay.month.toString();
                year = focusedDay.year.toString();
                getSharedData();
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 5,
                      right: 7,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            "${events.length}", // 🔹 Affiche le nombre réel d'événements
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Text(
          AppLocalizations.of(context)?.errorConnectingWithServer ?? "Error connecting with server",
          style: const TextStyle(
              fontSize: 20,
              fontFamily: 'cocon-next-arabic-regular',
              color: Colors.grey),
        ),
      );
    }
  }
}
