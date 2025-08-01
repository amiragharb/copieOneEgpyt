import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Booking/bookingSuccessActivity.dart' show BookingSuccessActivity;
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Models/addBookingDetails.dart';
import 'package:egpycopsversion4/Models/familyMember.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:skeleton_text/skeleton_text.dart';

typedef void LocaleChangeCallback(Locale locale);

// 🔐 Variables liées à la réservation
String bookNumberAddBooking = "";
String courseDateArAddBooking = "";
String courseDateEnAddBooking = "";
String courseTimeArAddBooking = "";
String courseTimeEnAddBooking = "";

String remainingCountFailure = '';
String courseTypeName = '';

// 🏛 Informations sur l'église et la gouvernorat
String churchRemarksAddBooking = '';
String courseRemarksAddBooking = '';
String churchNameArAddBooking = '';
String churchNameEnAddBooking = '';
String governerateNameArAddBooking = '';
String governerateNameEnAddBooking = '';

// 🌐 Base de l'API
final BaseUrl BASE_URL = BaseUrl();
final String baseUrl = BASE_URL.BASE_URL;

// 📅 Détails du cours sélectionné
String remAttendanceCount = '0';
String churchRemarks = '';
String courseRemarks = '';
String courseDateAr = '';
String courseDateEn = '';
String courseTimeAr = '';
String courseTimeEn = '';
String churchNameAr = '';
String churchNameEn = '';
String courseID = '';

// 🔤 Langue de l'utilisateur
String myLanguage = '';

// 🔄 État
int bookingState = 0;
String firstAttendDate = '';

// 👤 Compte utilisateur
String accountType = '';

// 🪪 Type de participation
int attendanceTypeID = 0;
String attendanceTypeNameAr = '';
String attendanceTypeNameEn = '';

// Type spécifique à la réservation
int attendanceTypeIDAddBooking = 0;
String? selectedChurch; 
String? selectedDate;
String? selectedTime;


String attendanceTypeNameArAddBooking= '', attendanceTypeNameEnAddBooking= '';
class ChooseBookingFamilyMembersActivity extends StatefulWidget {
  ChooseBookingFamilyMembersActivity(
    this.remAttendanceCount,
    this.churchRemarks,
    this.courseRemarks,
    this.courseDateAr,
    this.courseDateEn,
    this.courseTimeAr,
    this.courseTimeEn,
    this.churchNameAr,
    this.churchNameEn,
    this.courseID,
    this.courseTypeName,
    this.attendanceTypeID,
    this.attendanceTypeNameAr,
    this.attendanceTypeNameEn,
  );

  final String remAttendanceCount;
  final String churchRemarks;
  final String courseRemarks;
  final String courseDateAr;
  final String courseDateEn;
  final String courseTimeAr;
  final String courseTimeEn;
  final String churchNameAr;
  final String churchNameEn;
  final String courseID;
  final String courseTypeName;
  final int attendanceTypeID;
  final String attendanceTypeNameAr;
  final String attendanceTypeNameEn;

  @override
  _ChooseBookingFamilyMembersActivityState createState() => _ChooseBookingFamilyMembersActivityState();
}


class _ChooseBookingFamilyMembersActivityState
    extends State<ChooseBookingFamilyMembersActivity> {
  List<FamilyMember> myFamilyList = [];
List<Map<String, dynamic>> listViewMyFamily = [];
  ScrollController _scrollController = new ScrollController();
  int loadingState = 0;
  int pageNumber = 0;
  String userID = "";
String mobileToken = ""; // ✅ pas de late, initialisé par défaut
  String failureMessage = "";
  List<BookedPersonsList> bookedPersonsList = [];

@override
void initState() {
  super.initState();

  // Initialize booking data from widget parameters
  remAttendanceCount = widget.remAttendanceCount;
  churchRemarks = widget.churchRemarks;
  courseRemarks = widget.courseRemarks;
  courseDateAr = widget.courseDateAr;
  courseDateEn = widget.courseDateEn;
  courseTimeAr = widget.courseTimeAr;
  courseTimeEn = widget.courseTimeEn;
  churchNameAr = widget.churchNameAr;
  churchNameEn = widget.churchNameEn;
  courseID = widget.courseID;
  courseTypeName = widget.courseTypeName;
  attendanceTypeID = widget.attendanceTypeID;
  attendanceTypeNameAr = widget.attendanceTypeNameAr;
  attendanceTypeNameEn = widget.attendanceTypeNameEn;

  // Initialize attendance type for booking
  attendanceTypeIDAddBooking = widget.attendanceTypeID;
  attendanceTypeNameArAddBooking = widget.attendanceTypeNameAr;
  attendanceTypeNameEnAddBooking = widget.attendanceTypeNameEn;

  // On attend d'abord l'initialisation du token avant de charger les données
  Future.microtask(() async {
    await initToken();
    await getDataFromShared(); // Chargera mobileToken correctement initialisé
  });

  // Initialisation des états
  remainingCountFailure = "0";
  pageNumber = 0;
  bookingState = 0;
  loadingState = 0;

  _scrollController.addListener(() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Pagination si nécessaire
    }
  });
}

Future<void> initToken() async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    mobileToken = token ?? "";
    print("Token: ${mobileToken.isNotEmpty ? mobileToken : "null"}");

    // 🔹 Écoute si le token change
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      mobileToken = newToken;
      print("Token refreshed: $mobileToken");
    });
  } catch (e) {
    print("Error retrieving FCM token: $e");
    mobileToken = "";
  }
}




 Future<String> _checkInternetConnection() async {
  try {
    final result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.none ? "0" : "1";
  } catch (e) {
    // En cas d'erreur, on considère qu'il n'y a pas de connexion
    print("Error checking connectivity: $e");
    return "0";
  }
}


 Future<void> getDataFromShared() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    myLanguage = prefs.getString('language') ?? "en";
    accountType = prefs.getString("accountType") ?? "";
    userID = prefs.getString("userID") ?? "";

    setState(() {
      loadingState = 0;
      pageNumber = 0;
      showSaveButton = false;
    });

    // 🔹 Vérification de la connexion Internet
    final connectionResponse = await _checkInternetConnection();
    print("connectionResponse: $connectionResponse");

    if (connectionResponse == '1') {
      myFamilyList = await getMyFamily();
    } else {
      // 🔹 Navigation vers l'écran "No Internet"
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => NoInternetConnectionActivity(),
        ),
      );

      // 🔹 Retenter après le retour de l'écran "No Internet"
      myFamilyList = await getMyFamily();
    }

    // 🔹 Affichage de la liste si les données sont prêtes
    if (loadingState == 1 && myFamilyList.isNotEmpty) {
      myFamilyListViewData();
    }
  } catch (e) {
    print("Error in getDataFromShared: $e");
    // Optionnel : afficher un message d’erreur ou un toast
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
    backgroundColor: Colors.grey[50],
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
              color: primaryDarkColor.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.bookADate ?? "Book a Date",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Select family members",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${listViewMyFamily.where((m) => m['isChecked'] == true).length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    body: buildChild(),
    bottomNavigationBar: Container(
      color: Colors.transparent,
      child: SafeArea(
        child: bookbutton(),
      ),
    ),
  );
}


  void myFamilyListViewData() {
  setState(() {
    listViewMyFamily.clear(); // Important : réinitialise pour éviter les doublons

    for (final member in myFamilyList) {
      if (attendanceTypeID == 3 && !(member.isDeacon ?? false)) {
        continue; // Ignorer les membres non-diacre si type == 3
      }

      listViewMyFamily.add({
        "userAccountMemberId": member.userAccountMemberId,
        "userAccountId": member.userAccountId,
        "accountMemberNameAr": member.accountMemberNameAr,
        "genderTypeId": member.genderTypeId,
        "genderTypeNameAr": member.genderTypeNameAr,
        "genderTypeNameEn": member.genderTypeNameEn,
        "isDeacon": member.isDeacon,
        "nationalIdNumber": member.nationalIdNumber,
        "mobile": member.mobile,
        "personRelationId": member.personRelationId,
        "personRelationNameAr": member.personRelationNameAr,
        "personRelationNameEn": member.personRelationNameEn,
        "isMainPerson": member.isMainPerson,
        "isChecked": false,
      });
    }

    if (accountType == "2" && listViewMyFamily.isNotEmpty) {
      listViewMyFamily[0]["isChecked"] = true;
      showSaveButton = true;
    }
    
    // Update button state after populating the list
    chosenMemberCount();
  });
}


  Widget bookbutton() {
  return Container(
    margin: const EdgeInsets.all(16),
    child: Material(
      elevation: 12,
      shadowColor: primaryDarkColor.withOpacity(0.4),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: showSaveButton
              ? LinearGradient(
                  colors: [primaryDarkColor, primaryDarkColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.grey[400]!, Colors.grey[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: ElevatedButton(
          onPressed: showSaveButton ? () async => book() : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (bookingState == 1) ...[
                const SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Processing...",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event_available,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)?.confirmBooking ?? "Confirm Booking",
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}


  chosenMemberCount() {
    String chosenMembers = "";
    for (int i = 0; i < listViewMyFamily.length; i++) {
      if (listViewMyFamily[i]["isChecked"]) {
        chosenMembers = chosenMembers +
            listViewMyFamily[i]["userAccountMemberId"].toString() +
            ",";
      }
    }
    print("chosenMembers $chosenMembers");
    if (chosenMembers.isEmpty) {
      setState(() {
        showSaveButton = false;
      });
    } else {
      setState(() {
        showSaveButton = true;
      });
    }
  }

  bool showSaveButton = false;

  book() async {
    print("🚀 Starting book() function");
    print("attendanceTypeIDAddBooking $attendanceTypeIDAddBooking");
    print("attendanceTypeNameArAddBooking $attendanceTypeNameArAddBooking");
    print("attendanceTypeNameEnAddBooking $attendanceTypeNameEnAddBooking");
    
    String chosenMembers = "";
    print("chosenMembers $chosenMembers");

    for (int i = 0; i < listViewMyFamily.length; i++) {
      if (listViewMyFamily[i]["isChecked"]) {
        chosenMembers = chosenMembers +
            listViewMyFamily[i]["userAccountMemberId"].toString() +
            ",";
        print("chosenMembers $chosenMembers");
      }
    }
    print("chosenMembers $chosenMembers");

    if (chosenMembers.isEmpty) {
      Fluttertoast.showToast(
msg: AppLocalizations.of(context)?.pleaseChooseAtLeastFamilyMember 
     ?? "Please choose at least one family member",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.red,
          fontSize: 16.0);
    } else {
      setState(() {
        bookingState = 1;
      });
      chosenMembers = chosenMembers.substring(0, chosenMembers.length - 1);
      print("chosenMembers = $chosenMembers");
      String? addBookingResponse = await addBooking(chosenMembers, courseID);
      if (addBookingResponse == "1") {
        setState(() {
          bookingState = 2;
        });
        Navigator.of(context).pop();

        Navigator.of(context).push(
  MaterialPageRoute(
    builder: (BuildContext context) => BookingSuccessActivity(
      bookNumber: bookNumberAddBooking,
      courseDateAr: courseDateArAddBooking,
      courseDateEn: courseDateEnAddBooking,
      courseTimeAr: courseTimeArAddBooking,
      courseTimeEn: courseTimeEnAddBooking,
      churchRemarks: churchRemarksAddBooking,
      courseRemarks: courseRemarksAddBooking,
      churchNameAr: churchNameArAddBooking,
      churchNameEn: churchNameEnAddBooking,
      governerateNameAr: governerateNameArAddBooking,
      governerateNameEn: governerateNameEnAddBooking,
      myLanguage: myLanguage,
      courseTypeName: courseTypeName,
      attendanceTypeIDAddBooking: attendanceTypeIDAddBooking,
      attendanceTypeNameArAddBooking: attendanceTypeNameArAddBooking,
      attendanceTypeNameEnAddBooking: attendanceTypeNameEnAddBooking,
      bookedPersonsList: bookedPersonsList,
      bookingInfo: { // ✅ Fournir l'argument requis
        "members": listViewMyFamily
            .where((member) => member['isChecked'] == true)
            .toList(),
        "church": selectedChurch ?? "",
        "courseDate": selectedDate ?? "",
        "courseTime": selectedTime ?? "",
        "attendanceType": attendanceTypeIDAddBooking,
      },
    ),
  ),
);

        Fluttertoast.showToast(
  msg: AppLocalizations.of(context)?.bookedSuccessfully 
       ?? "Booked successfully",            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.green,
            fontSize: 16.0);
        }
      else if (addBookingResponse == "3") {
        setState(() {
          bookingState = 2;
        });

       Fluttertoast.showToast(
  msg: "${AppLocalizations.of(context)?.sorryYouCannotBookBefore ?? "Sorry, you cannot book before"} $firstAttendDate",
  toastLength: Toast.LENGTH_LONG,
  gravity: ToastGravity.BOTTOM,
  timeInSecForIosWeb: 1,
  backgroundColor: Colors.white,
  textColor: Colors.red,
  fontSize: 16.0,
);

      }
      else if (addBookingResponse == "4") {
        setState(() {
          bookingState = 2;
        });

       Fluttertoast.showToast(
  msg: AppLocalizations.of(context)?.youCannotBookBecauseYouHaveABookingOnTheSameTime
       ?? "You cannot book because you already have a booking at the same time",
  toastLength: Toast.LENGTH_LONG,
  gravity: ToastGravity.BOTTOM,
  timeInSecForIosWeb: 1,
  backgroundColor: Colors.white,
  textColor: Colors.red,
  fontSize: 16.0,
);
      }
      else if (addBookingResponse == "5") {
        setState(() {
          bookingState = 2;
        });

        Fluttertoast.showToast(
  msg: AppLocalizations.of(context)?.youAreNotRegisteredInThisChurchMembership
       ?? "You are not registered in this church membership",
  toastLength: Toast.LENGTH_LONG,
  gravity: ToastGravity.BOTTOM,
  timeInSecForIosWeb: 1,
  backgroundColor: Colors.white,
  textColor: Colors.red,
  fontSize: 16.0,
);
      }
      else if (addBookingResponse == "7") {
        setState(() {
          bookingState = 2;
        });

        Fluttertoast.showToast(
            msg: failureMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.red,
            fontSize: 16.0);
      }
      else if (addBookingResponse == "6") {
        setState(() {
          bookingState = 2;
        });

        Fluttertoast.showToast(
  msg: AppLocalizations.of(context)?.chosenPersonIsNotaDeacon 
       ?? "The chosen person is not a deacon",
  toastLength: Toast.LENGTH_LONG,
  gravity: ToastGravity.BOTTOM,
  timeInSecForIosWeb: 1,
  backgroundColor: Colors.white,
  textColor: Colors.red,
  fontSize: 16.0,
);
      }
      else if (addBookingResponse == "0") {
        setState(() {
          bookingState = 2;
        });
        if (int.parse(remainingCountFailure) > 10) {
         Fluttertoast.showToast(
  msg: "${AppLocalizations.of(context)?.thereAre ?? "There are"} "
       "$remainingCountFailure "
       "${AppLocalizations.of(context)?.availableSeat ?? "available seat"}",
  toastLength: Toast.LENGTH_LONG,
  gravity: ToastGravity.BOTTOM,
  timeInSecForIosWeb: 1,
  backgroundColor: Colors.white,
  textColor: Colors.red,
  fontSize: 16.0,
);

        } else {
          if (int.parse(remainingCountFailure) > 1) {
           Fluttertoast.showToast(
    msg: "${AppLocalizations.of(context)?.thereAre ?? "There are"} "
         "$remainingCountFailure "
         "${AppLocalizations.of(context)?.availableSeats ?? "available seats"}",
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.white,
    textColor: Colors.red,
    fontSize: 16.0,
  );
          } else {
            Fluttertoast.showToast(
  msg: "${AppLocalizations.of(context)?.thereIs ?? "There is"} "
       "$remainingCountFailure "
       "${AppLocalizations.of(context)?.availableSeatSingular ?? "available seat"}",
  toastLength: Toast.LENGTH_LONG,
  gravity: ToastGravity.BOTTOM,
  timeInSecForIosWeb: 1,
  backgroundColor: Colors.white,
  textColor: Colors.red,
  fontSize: 16.0,
);

          }
        }
      }
      else {
        setState(() {
          bookingState = 2;
        });
       Fluttertoast.showToast(
  msg: AppLocalizations.of(context)?.errorConnectingWithServer 
       ?? "Error connecting with server",
  toastLength: Toast.LENGTH_LONG,
  gravity: ToastGravity.BOTTOM,
  timeInSecForIosWeb: 1,
  backgroundColor: Colors.white,
  textColor: Colors.red,
  fontSize: 16.0,
);

      }
    }
  }

  Future<String?> addBooking(String chosenMembers, String courseID) async {
  try {
    final url = Uri.parse(
      '$baseUrl/Booking/AddBooking/?listAccountMemberIDs=$chosenMembers'
      '&CourseID=$courseID'
      '&UserAccountID=$userID'
      '&AttendanceTypeID=$attendanceTypeID'
      '&Token=$mobileToken',
    );

    final response = await http.post(url);
  print(url);
  print("response body: ${response.body}");
  print("response statusCode: ${response.statusCode}");

  if (response.statusCode == 200) {
    final myAddBookingDetailsObj = addBookingDetailsFromJson(response.body);

    // 🔹 Assignation des données de la réponse
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

    // 🔹 Gestion des messages d’erreur
    failureMessage = (myLanguage == "ar")
        ? (myAddBookingDetailsObj.errorMessageAr ?? "")
        : (myAddBookingDetailsObj.errorMessageEn ?? "");

    // 🔹 Liste des personnes réservées
    bookedPersonsList = myAddBookingDetailsObj.personList;

    if (myAddBookingDetailsObj.sucessCode == "1") {
      courseTypeName = myAddBookingDetailsObj.courseTypeName ?? "";
    }

    return myAddBookingDetailsObj.sucessCode;
  } else {
    print("❗️HTTP Error: ${response.statusCode}");
    return "0"; // 🔹 Échec de la requête
  }
  } catch (e, stackTrace) {
    print("❗️Caught error: $e");
    print("Stack trace: $stackTrace");
    return "0"; // 🔹 Échec en cas d'exception
  }
}

  Future<List<FamilyMember>> getMyFamily() async {
  try {
    final url = Uri.parse(
      '$baseUrl/Family/GetFamilyMembers/?UserID=$userID&Token=$mobileToken',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    print("GET: $url");
    print("Response statusCode: ${response.statusCode}");

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        setState(() => loadingState = 3); // Aucun membre trouvé
        return [];
      }

      // 🔹 Conversion JSON -> Liste de FamilyMember
      final myFamilyMembersObj = familyMemberFromJson(response.body);

      // 🔹 Convertir List<FamilyMember> -> List<Map<String,dynamic>>
      final mappedFamilyMembers = myFamilyMembersObj.map((member) => {
        "userAccountMemberId": member.userAccountMemberId,
        "userAccountId": member.userAccountId,
        "accountMemberNameAr": member.accountMemberNameAr,
        "genderTypeId": member.genderTypeId,
        "genderTypeNameAr": member.genderTypeNameAr,
        "genderTypeNameEn": member.genderTypeNameEn,
        "isDeacon": member.isDeacon,
        "nationalIdNumber": member.nationalIdNumber,
        "mobile": member.mobile,
        "personRelationId": member.personRelationId,
        "personRelationNameAr": member.personRelationNameAr,
        "personRelationNameEn": member.personRelationNameEn,
        "isMainPerson": member.isMainPerson,
        "branchID": member.branchID,
        "governorateID": member.governorateID,
        "churchOfAttendance": member.churchOfAttendance,
        "isChecked": false, // ✅ Pour gérer la sélection
      }).toList();

      // 🔹 Mise à jour de la liste et de l’état
      setState(() {
        listViewMyFamily = mappedFamilyMembers;
        loadingState = 1;
      });

      // Debug
      for (final member in myFamilyMembersObj) {
        print('👤 ${member.accountMemberNameAr} | ${member.genderTypeNameAr} | Deacon: ${member.isDeacon}');
      }

      return myFamilyMembersObj;
    } else {
      setState(() => loadingState = 2);
      print("getMyFamily HTTP error ${response.statusCode}");
      return [];
    }
  } on TimeoutException {
  print("Timeout... retrying in 3 seconds");
  await Future.delayed(const Duration(seconds: 3));
  return getMyFamily(); // 🔁 Retry
} catch (e) {
    setState(() => loadingState = 2);
    print("getMyFamily error: $e");
    return [];
  }
}


  Widget holyLiturgyDate() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: Text(
  AppLocalizations.of(context)?.holyLiturgyDate ?? "Holy Liturgy Date",
  style: const TextStyle(
    fontSize: 18.0,
    color: Colors.black,
  ),
),

            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: myLanguage == "en"
                  ? Text(
                      courseDateEn,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: primaryDarkColor,
                      ),
                    )
                  : Text(
                      courseDateAr,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: primaryDarkColor,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget liturgyTime() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
AppLocalizations.of(context)?.time ?? "Time",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: myLanguage == "en"
                  ? Text(
                      courseTimeEn,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: primaryDarkColor,
                      ),
                    )
                  : Text(
                      courseTimeAr,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: primaryDarkColor,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget church() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 20.0, right: 20.0),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
AppLocalizations.of(context)?.church ?? "Church",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: myLanguage == "en"
                  ? Text(
                      churchNameEn,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: primaryDarkColor,
                      ),
                    )
                  : Text(
                      churchNameAr,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: primaryDarkColor,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

Widget availableSeatsLayout() {
  final count = int.tryParse(remAttendanceCount) ?? 0;

  // Couleur selon nombre de places
  final color = count > 10 ? primaryDarkColor : Colors.redAccent;

  // Message avec gestion singulier/pluriel via la localisation
  final message = count <= 1
      ? AppLocalizations.of(context)?.availableSeatSingular ?? "Available seat $remAttendanceCount"
      : AppLocalizations.of(context)?.availableSeats ?? "Available seats $remAttendanceCount";

  return Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 5.0, right: 18.0, left: 18.0),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 18.0,
          fontFamily: 'cocon-next-arabic-regular',
          color: color,
          fontWeight: FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

  Widget churchRemarksLayout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
            top: 5.0, right: 20.0, left: 20.0, bottom: 5.0),
        child: churchRemarks.isEmpty
            ? new Container()
            : Text(
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
    );
  }

  Widget courseRemarksLayout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0, right: 20.0, left: 20.0),
        child: courseRemarks.isEmpty
            ? new Container()
            : Text(
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
    );
  }

Widget buildChild() {
  // 0️⃣ Chargement : Modern Skeleton with shimmer effect
  if (loadingState == 0) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[50]!,
            Colors.grey[100]!,
          ],
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 6,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                height: 80,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Avatar skeleton
                    SkeletonAnimation(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Text skeletons
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SkeletonAnimation(
                            child: Container(
                              height: 16,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SkeletonAnimation(
                            child: Container(
                              height: 12,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Checkbox skeleton
                    SkeletonAnimation(
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 1️⃣ Modern Family Members List
  if (loadingState == 1) {
    if (listViewMyFamily.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryDarkColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.family_restroom,
                  size: 64,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)?.noMembersFound ?? "No family members found",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Please add family members first",
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryDarkColor.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // Header section with booking info
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryDarkColor, primaryDarkColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryDarkColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.church,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            myLanguage == "ar" ? churchNameAr : churchNameEn,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            myLanguage == "ar" ? courseDateAr : courseDateEn,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        myLanguage == "ar" ? courseTimeAr : courseTimeEn,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Section title
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: primaryDarkColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Select Family Members",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryDarkColor,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Family members list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: listViewMyFamily.length,
              itemBuilder: (context, index) {
                final member = listViewMyFamily[index];
                final isChecked = member['isChecked'] ?? false;
                final isDeacon = member['isDeacon'] ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    elevation: isChecked ? 8 : 4,
                    shadowColor: isChecked 
                        ? primaryDarkColor.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          member['isChecked'] = !isChecked;
                        });
                        chosenMemberCount();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isChecked 
                                ? primaryDarkColor
                                : Colors.grey.withOpacity(0.3),
                            width: isChecked ? 2 : 1,
                          ),
                          gradient: isChecked
                              ? LinearGradient(
                                  colors: [
                                    primaryDarkColor.withOpacity(0.1),
                                    primaryDarkColor.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [Colors.white, Colors.grey[50]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                        ),
                        child: Row(
                          children: [
                            // Avatar with status
                            Stack(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: isDeacon
                                          ? [Colors.blue[400]!, Colors.blue[600]!]
                                          : [Colors.grey[400]!, Colors.grey[600]!],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isDeacon ? Colors.blue : Colors.grey)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isDeacon ? Icons.church : Icons.person,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                if (isDeacon)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.star,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Member info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member['accountMemberNameAr'] ?? '',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isChecked 
                                          ? primaryDarkColor
                                          : Colors.grey[800],
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (isDeacon ? Colors.blue : Colors.grey)
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          member['personRelationNameAr'] ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDeacon ? Colors.blue[700] : Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textDirection: TextDirection.rtl,
                                        ),
                                      ),
                                      if (isDeacon) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            "Deacon",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.amber[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Modern checkbox
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isChecked ? primaryDarkColor : Colors.transparent,
                                border: Border.all(
                                  color: isChecked ? primaryDarkColor : Colors.grey[400]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: isChecked
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 2️⃣ Modern Error State
  if (loadingState == 2) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.red[50]!,
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)?.errorConnectingWithServer ??
                  "Connection Error",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please check your internet connection",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.red[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3️⃣ No members state
  if (loadingState == 3) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.orange[50]!,
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search,
                size: 64,
                color: Colors.orange[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)?.noMembersFound ?? "No Members Found",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "No family members available for booking",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.orange[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Default loader
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryDarkColor.withOpacity(0.1),
          Colors.white,
        ],
      ),
    ),
    child: const Center(
      child: CircularProgressIndicator(),
    ),
  );
}

}
