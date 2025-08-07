import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Booking/courses.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Models/calendarCourses.dart';
import 'package:egpycopsversion4/Translation/localizations.dart' hide AppLocalizations;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:egpycopsversion4/l10n/app_localizations.dart';

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

    _events.clear();

    for (var course in coursesList) {
      for (int j = 0; j < (course.timeCount ?? 0); j++) {
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
                AppLocalizations.of(context)?.chooseHolyLiturgyDate2 ?? "Choose Holy Liturgy Date",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
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
      child: buildChild(context),
    ),
  );
}

Widget buildChild(BuildContext context) {
  // Fonction utilitaire pour vérifier s'il y a AU MOINS un event dans le calendrier
  bool hasAnyEvent() {
    return _events != null && _events.values.any((list) => list.isNotEmpty);
  }

  if (loadingState == 0) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)?.loadingCalendar ?? "Loading calendar...",
            style: TextStyle(
              color: primaryDarkColor.withOpacity(0.7),
              fontSize: 16,
              fontFamily: 'cocon-next-arabic-regular',
            ),
          ),
        ],
      ),
    );
  } else if (loadingState == 1) {
    // Si AUCUN event dans tout le calendrier : affiche "No available dates"
    if (_events == null || _events.isEmpty || !hasAnyEvent()) {
      return Center(
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
                Icons.event_busy,
                size: 48,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)?.noDateAvailable ?? "Sorry, No available dates",
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'cocon-next-arabic-regular',
                color: accentColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Sinon, il y a au moins un event dans _events → affiche le calendrier normal
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            padding: const EdgeInsets.all(20),
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
              ],
            ),
            child: Row(
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
                  child: Text(
                    myLanguage == "en" ? widget.churchNameEn : widget.churchNameAr,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'cocon-next-arabic-regular',
                      fontWeight: FontWeight.w600,
                      color: primaryDarkColor,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: (day) {
                final normalizedDay = DateTime.utc(day.year, day.month, day.day);
                return _events[normalizedDay] ?? [];
              },
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                final normalizedDay = DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
                final events = _events[normalizedDay] ?? [];

                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                if (events.isNotEmpty) {
                  final formatted = DateFormat('yyyy-MM-dd').format(selectedDay);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CoursesActivity(
                        formatted,
                        widget.churchOfAttendanceID,
                        widget.churchNameEn,
                        widget.churchNameAr,
                      ),
                    ),
                  );
                } else {
                  // Ici, on ne montre le toast QUE si le calendrier n'est pas vide globalement
                  Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)?.noSeatsAvailable ?? "No seats available",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.white,
                    textColor: accentColor,
                  );
                }
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: logoBlue,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                selectedDecoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                weekendTextStyle: TextStyle(color: primaryDarkColor.withOpacity(0.7)),
                defaultTextStyle: TextStyle(color: primaryDarkColor),
                outsideTextStyle: TextStyle(color: primaryDarkColor.withOpacity(0.3)),
                disabledTextStyle: TextStyle(color: primaryDarkColor.withOpacity(0.2)),
                markerDecoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: primaryDarkColor,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: primaryDarkColor,
                ),
                titleTextStyle: TextStyle(
                  color: primaryDarkColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'cocon-next-arabic-regular',
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: primaryDarkColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                weekendStyle: TextStyle(
                  color: primaryDarkColor.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
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
                      bottom: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: logoBlue,
                        ),
                        width: 8.0,
                        height: 8.0,
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
        ],
      ),
    );
  } else {
    return Center(
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
            AppLocalizations.of(context)?.errorConnectingWithServer ?? "Error loading calendar",
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
            onPressed: () => getSharedData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryDarkColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)?.pleaseTryAgain ?? "Try Again",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

}
