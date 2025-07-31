import 'dart:convert';

List<CourseTime> courseTimeFromJson(String str) =>
    List<CourseTime>.from(json.decode(str).map((x) => CourseTime.fromJson(x)));

String courseTimeToJson(List<CourseTime> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CourseTime {
  CourseTime({
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
    this.timeCount,
    this.avaliableAttendanceTypes,
    this.showAttendanceTypePopup,
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
  int? timeCount;
  List<ListAttendanceTypes>? avaliableAttendanceTypes;
  int? showAttendanceTypePopup;

  factory CourseTime.fromJson(Map<String, dynamic> json) => CourseTime(
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
        timeCount: json["TimeCount"] as int?,
        avaliableAttendanceTypes: json["AvaliableAttendanceTypes"] == null
            ? null
            : List<ListAttendanceTypes>.from(
                json["AvaliableAttendanceTypes"].map((x) => ListAttendanceTypes.fromJson(x))),
        showAttendanceTypePopup: json["ShowAttendanceTypePopup"] as int?,
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
        "TimeCount": timeCount,
        "AvaliableAttendanceTypes": avaliableAttendanceTypes == null
            ? null
            : List<dynamic>.from(avaliableAttendanceTypes!.map((x) => x.toJson())),
        "ShowAttendanceTypePopup": showAttendanceTypePopup,
      };
}

class ListAttendanceTypes {
  ListAttendanceTypes({
    this.iD,
    this.nameAr,
    this.nameEn,
  });

  int? iD;
  String? nameAr;
  String? nameEn;

  factory ListAttendanceTypes.fromJson(Map<String, dynamic> json) => ListAttendanceTypes(
        iD: json["ID"] as int?,
        nameAr: json["NameAr"] as String?,
        nameEn: json["NameEn"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "ID": iD,
        "NameAr": nameAr,
        "NameEn": nameEn,
      };
}
