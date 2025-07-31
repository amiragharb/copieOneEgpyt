// To parse this JSON data, do
//     final bookingDetails = addBookingDetailsFromJson(jsonString);

import 'dart:convert';

AddBookingDetails addBookingDetailsFromJson(String str) =>
    AddBookingDetails.fromJson(json.decode(str));

String addBookingDetailsToJson(AddBookingDetails data) =>
    json.encode(data.toJson());

class AddBookingDetails {
  AddBookingDetails({
    this.bookNumber,
    this.remAttendanceCount,
    this.courseDate,
    this.courseDateAr,
    this.courseDateEn,
    this.courseTimeAr,
    this.courseTimeEn,
    this.churchRemarks,
    this.courseRemarks,
    this.churchNameAr,
    this.churchNameEn,
    this.governerateNameAr,
    this.governerateNameEn,
    this.courseNameAr,
    this.courseNameEn,
    this.courseTypeName,
    this.sucessCode,
    this.firstAttendDate,
    this.attendanceTypeID,
    this.attendanceTypeNameEn,
    this.attendanceTypeNameAr,
    this.errorMessageAr,
    this.errorMessageEn,
    this.personList = const [],
  });

  String? bookNumber;
  String? remAttendanceCount;
  String? courseDate;
  String? courseDateAr;
  String? courseDateEn;
  String? courseTimeAr;
  String? courseTimeEn;
  String? churchRemarks;
  String? courseRemarks;
  String? churchNameAr;
  String? churchNameEn;
  String? governerateNameAr;
  String? governerateNameEn;
  String? courseNameAr;
  String? courseNameEn;
  String? courseTypeName;
  String? sucessCode;
  String? firstAttendDate;
  int? attendanceTypeID;
  String? attendanceTypeNameEn;
  String? attendanceTypeNameAr;
  String? errorMessageAr;
  String? errorMessageEn;
  List<BookedPersonsList> personList;

  factory AddBookingDetails.fromJson(Map<String, dynamic> json) =>
      AddBookingDetails(
        bookNumber: json["BookNumber"] as String?,
        remAttendanceCount: json["RemAttendanceCount"] as String?,
        courseDate: json["CourseDate"] as String?,
        courseDateAr: json["CourseDateAr"] as String?,
        courseDateEn: json["CourseDateEn"] as String?,
        courseTimeAr: json["CourseTimeAr"] as String?,
        courseTimeEn: json["CourseTimeEn"] as String?,
        churchRemarks: json["ChurchRemarks"] as String?,
        courseRemarks: json["CourseRemarks"] as String?,
        churchNameAr: json["ChurchNameAr"] as String?,
        churchNameEn: json["ChurchNameEn"] as String?,
        governerateNameAr: json["GovernerateNameAr"] as String?,
        governerateNameEn: json["GovernerateNameEn"] as String?,
        courseNameAr: json["CourseNameAr"] as String?,
        courseNameEn: json["CourseNameEn"] as String?,
        courseTypeName: json["CourseTypeName"] as String?,
        sucessCode: json["SucessCode"] as String?,
        firstAttendDate: json["FirstAttendDate"] as String?,
        attendanceTypeID: json["AttendanceTypeID"] as int?,
        attendanceTypeNameEn: json["AttendanceTypeNameEn"] as String?,
        attendanceTypeNameAr: json["AttendanceTypeNameAr"] as String?,
        errorMessageAr: json["ErrorMessageAr"] as String?,
        errorMessageEn: json["ErrorMessageEn"] as String?,
        personList: json["PersonList"] != null
            ? List<BookedPersonsList>.from(
                (json["PersonList"] as List)
                    .map((x) => BookedPersonsList.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "BookNumber": bookNumber,
        "RemAttendanceCount": remAttendanceCount,
        "CourseDate": courseDate,
        "CourseDateAr": courseDateAr,
        "CourseDateEn": courseDateEn,
        "CourseTimeAr": courseTimeAr,
        "CourseTimeEn": courseTimeEn,
        "ChurchRemarks": churchRemarks,
        "CourseRemarks": courseRemarks,
        "ChurchNameAr": churchNameAr,
        "ChurchNameEn": churchNameEn,
        "GovernerateNameAr": governerateNameAr,
        "GovernerateNameEn": governerateNameEn,
        "CourseNameAr": courseNameAr,
        "CourseNameEn": courseNameEn,
        "CourseTypeName": courseTypeName,
        "SucessCode": sucessCode,
        "FirstAttendDate": firstAttendDate,
        "AttendanceTypeID": attendanceTypeID,
        "AttendanceTypeNameEn": attendanceTypeNameEn,
        "AttendanceTypeNameAr": attendanceTypeNameAr,
        "ErrorMessageAr": errorMessageAr,
        "ErrorMessageEn": errorMessageEn,
        "PersonList": List<dynamic>.from(personList.map((x) => x.toJson())),
      };
}

class BookedPersonsList {
  BookedPersonsList({
    this.name,
    this.nationalID,
  });

  String? name;
  String? nationalID;

  factory BookedPersonsList.fromJson(Map<String, dynamic> json) =>
      BookedPersonsList(
        name: json["Name"] as String?,
        nationalID: json["NationalID"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "Name": name,
        "NationalID": nationalID,
      };
}
