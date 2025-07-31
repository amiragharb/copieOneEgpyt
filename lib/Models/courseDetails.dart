// To parse this JSON data, do
//
//     final courseDetails = courseDetailsFromJson(jsonString);

import 'dart:convert';

CourseDetails courseDetailsFromJson(String str) =>
    CourseDetails.fromJson(json.decode(str));

String courseDetailsToJson(CourseDetails data) =>
    json.encode(data.toJson());

class CourseDetails {
  CourseDetails({
    this.id,
    this.nameAr,
    this.nameEn,
    this.isDefualt,
    this.remAttendanceCount,
    this.remAttendanceDeaconCount,
    this.courseDate,
    this.courseDateAr,
    this.courseDateEn,
    this.courseTimeAr,
    this.courseTimeEn,
    this.churchRemarks,
    this.courseRemarks,
    this.governerateNameAr,
    this.governerateNameEn,
    this.churchNameAr,
    this.courseTypeName,
    this.churchNameEn,
    this.courseNameAr,
    this.courseNameEn,
  });

  int? id;
  String? nameAr;
  String? nameEn;
  bool? isDefualt;
  int? remAttendanceCount;
  int? remAttendanceDeaconCount;
  String? courseDate;
  String? courseDateAr;
  String? courseDateEn;
  String? courseTimeAr;
  String? courseTimeEn;
  String? churchRemarks;
  String? courseRemarks;
  String? governerateNameAr;
  String? governerateNameEn;
  String? churchNameAr;
  String? courseTypeName;
  String? churchNameEn;
  String? courseNameAr;
  String? courseNameEn;

  factory CourseDetails.fromJson(Map<String, dynamic> json) => CourseDetails(
        id: json["ID"] as int?,
        nameAr: json["NameAr"] as String?,
        nameEn: json["NameEn"] as String?,
        isDefualt: json["IsDefualt"] as bool?,
        remAttendanceCount: json["RemAttendanceCount"] as int?,
        remAttendanceDeaconCount: json["RemAttendanceDeaconCount"] as int?,
        courseDate: json["CourseDate"] as String?,
        courseDateAr: json["CourseDateAr"] as String?,
        courseDateEn: json["CourseDateEn"] as String?,
        courseTimeAr: json["CourseTimeAr"] as String?,
        courseTimeEn: json["CourseTimeEn"] as String?,
        churchRemarks: json["ChurchRemarks"] as String?,
        courseRemarks: json["CourseRemarks"] as String?,
        governerateNameAr: json["GovernerateNameAr"] as String?,
        governerateNameEn: json["GovernerateNameEn"] as String?,
        churchNameAr: json["ChurchNameAr"] as String?,
        courseTypeName: json["CourseTypeName"] as String?,
        churchNameEn: json["ChurchNameEn"] as String?,
        courseNameAr: json["CourseNameAr"] as String?,
        courseNameEn: json["CourseNameEn"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "ID": id,
        "NameAr": nameAr,
        "NameEn": nameEn,
        "IsDefualt": isDefualt,
        "RemAttendanceCount": remAttendanceCount,
        "RemAttendanceDeaconCount": remAttendanceDeaconCount,
        "CourseDate": courseDate,
        "CourseDateAr": courseDateAr,
        "CourseDateEn": courseDateEn,
        "CourseTimeAr": courseTimeAr,
        "CourseTimeEn": courseTimeEn,
        "ChurchRemarks": churchRemarks,
        "CourseRemarks": courseRemarks,
        "GovernerateNameAr": governerateNameAr,
        "GovernerateNameEn": governerateNameEn,
        "ChurchNameAr": churchNameAr,
        "CourseTypeName": courseTypeName,
        "ChurchNameEn": churchNameEn,
        "CourseNameAr": courseNameAr,
        "CourseNameEn": courseNameEn,
      };
}
