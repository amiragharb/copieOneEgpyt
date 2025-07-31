import 'dart:convert';

EditBooking editBookingFromJson(String str) => EditBooking.fromJson(json.decode(str));

String editBookingToJson(EditBooking data) => json.encode(data.toJson());

class EditBooking {
  EditBooking({
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
    this.sucessCode,
    this.firstAttendDate,
    this.errorMessageAr,
    this.errorMessageEn,
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
  String? sucessCode;
  String? firstAttendDate;
  String? errorMessageAr;
  String? errorMessageEn;

  factory EditBooking.fromJson(Map<String, dynamic> json) => EditBooking(
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
        sucessCode: json["SucessCode"] as String?,
        firstAttendDate: json["FirstAttendDate"] as String?,
        errorMessageAr: json["ErrorMessageAr"] as String?,
        errorMessageEn: json["ErrorMessageEn"] as String?,
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
        "SucessCode": sucessCode,
        "FirstAttendDate": firstAttendDate,
        "ErrorMessageAr": errorMessageAr,
        "ErrorMessageEn": errorMessageEn,
      };
}
