import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Booking/bookingSuccessActivity.dart' show BookingSuccessActivity;
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Family/addFamilyMemberActivity.dart';
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

import '../Family/addFamilyMemberActivity.dart';

typedef void LocaleChangeCallback(Locale locale);

// 🔐 Variables liées à la réservation
late String bookNumberAddBooking;
late String courseDateArAddBooking;
late String courseDateEnAddBooking;
late String courseTimeArAddBooking;
late String courseTimeEnAddBooking;

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
      myFamilyList = await getMyFamily() ?? [];
    } else {
      // 🔹 Navigation vers l'écran "No Internet"
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => NoInternetConnectionActivity(),
        ),
      );

      // 🔹 Retenter après le retour de l'écran "No Internet"
      myFamilyList = await getMyFamily() ?? [];
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

 Widget buildBookButton() {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryDarkColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    onPressed: bookingState == 1
        ? null // Désactive le bouton pendant le chargement
        : () {
            // 🔹 Récupère les membres sélectionnés (optionnel)
            final selectedMembers = listViewMyFamily
                .where((member) => member['isChecked'] == true)
                .toList();

            // 🔹 Prépare les données de réservation
            final bookingData = {
  "governorate": governerateNameArAddBooking,
  "church": selectedChurch ?? "",
  "bookingType": courseTypeName,
  "courseDate": selectedDate ?? "",
  "courseTime": selectedTime ?? "",
  "attendanceType": attendanceTypeIDAddBooking,
  "members": listViewMyFamily
      .where((member) => member['isChecked'] == true)
      .toList(),
};


            Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => BookingSuccessActivity(
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
      bookingInfo: {
        "governorate": governerateNameArAddBooking,
        "church": selectedChurch ?? "",
        "bookingType": courseTypeName,
        "courseDate": selectedDate ?? "",
        "courseTime": selectedTime ?? "",
        "attendanceType": attendanceTypeIDAddBooking,
        "members": listViewMyFamily
            .where((member) => member['isChecked'] == true)
            .toList(),
      },
    ),
  ),
);

          },
    child: bookingState == 1
        ? const SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Text(
            AppLocalizations.of(context)?.confirmBooking ?? "Confirm Booking",
            style: const TextStyle(
              fontSize: 18.0,
              fontFamily: 'cocon-next-arabic-regular',
              fontWeight: FontWeight.normal,
            ),
          ),
  );
}


@override
Widget build(BuildContext context) {
  final size = MediaQuery.of(context).size;

  return Scaffold(
    appBar: AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      title: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(
          AppLocalizations.of(context)?.bookADate ?? "Book a Date",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      backgroundColor: primaryDarkColor,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    body: buildChild(), // ✅ Contenu principal
    bottomNavigationBar: SizedBox(
      width: size.width,
      height: 50.0,
      child: bookbutton(), // ✅ Assure-toi que bookbutton() retourne bien un Widget
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
  });
}


  Widget bookbutton() {
  return ElevatedButton(
    onPressed: showSaveButton ? () async => book() : null,
    style: ElevatedButton.styleFrom(
      backgroundColor: showSaveButton ? Colors.green : greyColor,
      foregroundColor: Colors.white,
    ),
    child: buildBookButton(),
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
    return "0"; // 🔹 Échec de la requête
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
  // 0️⃣ Chargement : Skeleton
  if (loadingState == 0) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(14.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        padding: const EdgeInsets.only(left: 15.0, bottom: 10),
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
  }

  // 1️⃣ Liste des membres
  if (loadingState == 1) {
    if (listViewMyFamily.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)?.noMembersFound ?? "No members found",
          style: const TextStyle(fontSize: 20.0, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
  itemCount: listViewMyFamily.length,
  itemBuilder: (context, index) {
    final member = listViewMyFamily[index]; // Map<String,dynamic>

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        value: member['isChecked'] ?? false,
        onChanged: (bool? value) {
          setState(() {
            member['isChecked'] = value ?? false;
          });
        },
        title: Text(
          member['accountMemberNameAr'] ?? '',
          style: const TextStyle(fontSize: 18),
          textDirection: TextDirection.rtl,
        ),
        subtitle: Text(
          member['personRelationNameAr'] ?? '',
          textDirection: TextDirection.rtl,
        ),
        secondary: Icon(
          (member['isDeacon'] ?? false) ? Icons.church : Icons.person,
          color: (member['isDeacon'] ?? false)
              ? Colors.blueAccent
              : Colors.grey,
        ),
      ),
    );
  },
);

  }

  // 2️⃣ Erreur de connexion
  if (loadingState == 2) {
    return Center(
      child: Text(
        AppLocalizations.of(context)?.errorConnectingWithServer ??
            "Error connecting with server",
        style: const TextStyle(fontSize: 20.0, color: Colors.grey),
      ),
    );
  }

  // 3️⃣ Aucun membre trouvé
  if (loadingState == 3) {
    return Center(
      child: Text(
        AppLocalizations.of(context)?.noMembersFound ?? "No members found",
        style: const TextStyle(fontSize: 20.0, color: Colors.grey),
      ),
    );
  }

  // 🔹 Loader par défaut
  return const Center(child: CircularProgressIndicator());
}

}
