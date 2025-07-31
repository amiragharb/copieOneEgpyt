// To parse this JSON data, do
//
//     final booking = bookingFromJson(jsonString);

import 'dart:convert';

List<Booking> bookingFromJson(String str) =>
    List<Booking>.from(json.decode(str).map((x) => Booking.fromJson(x)));

String bookingToJson(List<Booking> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Booking {
  Booking({
    this.courseDateOfBook,
    this.courseDateAr,
    this.courseDateEn,
    this.branchNameEn,
    this.courseTimeAr,
    this.courseTimeEn,
    this.churchNameAr,
    this.churchNameEn,
    this.courseNameAr,
    this.courseTypeName,
    this.courseNameEn,
    this.coupleId,
    this.remAttendanceCount,
    this.listOfmember,
    this.registrationNumber,
    this.attendanceTypeID,
    this.attendanceTypeNameEn,
    this.attendanceTypeNameAr,
  });

  String? courseDateOfBook;
  String? courseDateAr;
  String? courseDateEn;
  String? branchNameEn;
  String? courseTimeAr;
  String? courseTimeEn;
  String? churchNameAr;
  String? churchNameEn;
  String? courseNameAr;
  String? courseTypeName;
  String? courseNameEn;
  String? coupleId;
  String? remAttendanceCount;
  List<ListOfmember>? listOfmember;
  String? registrationNumber;
  int? attendanceTypeID;
  String? attendanceTypeNameEn;
  String? attendanceTypeNameAr;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        courseDateOfBook: json["CourseDateOfBook"] as String?,
        courseDateAr: json["CourseDateAr"] as String?,
        courseDateEn: json["CourseDateEn"] as String?,
        branchNameEn: json["BranchNameEn"] as String?,
        courseTimeAr: json["CourseTimeAr"] as String?,
        courseTimeEn: json["CourseTimeEn"] as String?,
        churchNameAr: json["ChurchNameAr"] as String?,
        churchNameEn: json["ChurchNameEn"] as String?,
        courseNameAr: json["CourseNameAr"] as String?,
        courseTypeName: json["CourseTypeName"] as String?,
        courseNameEn: json["CourseNameEn"] as String?,
        coupleId: json["CoupleID"] as String?,
        remAttendanceCount: json["RemAttendanceCount"] as String?,
        listOfmember: json["ListOfmember"] != null
            ? List<ListOfmember>.from(
                (json["ListOfmember"] as List)
                    .map((x) => ListOfmember.fromJson(x)))
            : null,
        registrationNumber: json["RegistrationNumber"] as String?,
        attendanceTypeID: json["AttendanceTypeID"] as int?,
        attendanceTypeNameEn: json["AttendanceTypeNameEn"] as String?,
        attendanceTypeNameAr: json["AttendanceTypeNameAr"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "CourseDateOfBook": courseDateOfBook,
        "CourseDateAr": courseDateAr,
        "CourseDateEn": courseDateEn,
        "BranchNameEn": branchNameEn,
        "CourseTimeAr": courseTimeAr,
        "CourseTimeEn": courseTimeEn,
        "ChurchNameAr": churchNameAr,
        "ChurchNameEn": churchNameEn,
        "CourseNameAr": courseNameAr,
        "CourseTypeName": courseTypeName,
        "CourseNameEn": courseNameEn,
        "CoupleID": coupleId,
        "RemAttendanceCount": remAttendanceCount,
        "ListOfmember": listOfmember == null
            ? null
            : List<dynamic>.from(listOfmember!.map((x) => x.toJson())),
        "RegistrationNumber": registrationNumber,
        "AttendanceTypeID": attendanceTypeID,
        "AttendanceTypeNameEn": attendanceTypeNameEn,
        "AttendanceTypeNameAr": attendanceTypeNameAr,
      };
}

class ListOfmember {
  ListOfmember({
    this.userAccountMemberId,
    this.userAccountId,
    this.accountMemberNameAr,
    this.genderTypeId,
    this.genderTypeNameAr,
    this.genderTypeNameEn,
    this.isDeacon,
    this.nationalIdNumber,
    this.mobile,
    this.personRelationId,
    this.personRelationNameAr,
    this.personRelationNameEn,
    this.isMainPerson,
    this.isSelectedInCourse,
  });

  String? userAccountMemberId;
  String? userAccountId;
  String? accountMemberNameAr;
  String? genderTypeId;
  String? genderTypeNameAr;
  String? genderTypeNameEn;
  bool? isDeacon;
  String? nationalIdNumber;
  String? mobile;
  String? personRelationId;
  String? personRelationNameAr;
  String? personRelationNameEn;
  bool? isMainPerson;
  bool? isSelectedInCourse;

  factory ListOfmember.fromJson(Map<String, dynamic> json) => ListOfmember(
        userAccountMemberId: json["UserAccountMemberID"] as String?,
        userAccountId: json["UserAccountID"] as String?,
        accountMemberNameAr: json["AccountMemberNameAr"] as String?,
        genderTypeId: json["GenderTypeID"] as String?,
        genderTypeNameAr: json["GenderTypeNameAr"] as String?,
        genderTypeNameEn: json["GenderTypeNameEn"] as String?,
        isDeacon: json["IsDeacon"] as bool?,
        nationalIdNumber: json["NationalIDNumber"] as String?,
        mobile: json["Mobile"] as String?,
        personRelationId: json["PersonRelationID"] as String?,
        personRelationNameAr: json["PersonRelationNameAr"] as String?,
        personRelationNameEn: json["PersonRelationNameEn"] as String?,
        isMainPerson: json["IsMainPerson"] as bool?,
        isSelectedInCourse: json["IsSelectedInCourse"] as bool?,
      );

  Map<String, dynamic> toJson() => {
        "UserAccountMemberID": userAccountMemberId,
        "UserAccountID": userAccountId,
        "AccountMemberNameAr": accountMemberNameAr,
        "GenderTypeID": genderTypeId,
        "GenderTypeNameAr": genderTypeNameAr,
        "GenderTypeNameEn": genderTypeNameEn,
        "IsDeacon": isDeacon,
        "NationalIDNumber": nationalIdNumber,
        "Mobile": mobile,
        "PersonRelationID": personRelationId,
        "PersonRelationNameAr": personRelationNameAr,
        "PersonRelationNameEn": personRelationNameEn,
        "IsMainPerson": isMainPerson,
        "IsSelectedInCourse": isSelectedInCourse,
      };
}
