import 'dart:convert';

List<EditBookingDetails> editBookingDetailsFromJson(String str) =>
    List<EditBookingDetails>.from(json.decode(str).map((x) => EditBookingDetails.fromJson(x)));

String editBookingDetailsToJson(List<EditBookingDetails> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EditBookingDetails {
  EditBookingDetails({
    this.courseDateOfBook,
    this.courseDateAr,
    this.registrationNumber,
    this.allowEdit,
    this.churchRemarks,
    this.courseRemarks,
    this.courseDateEn,
    this.branchNameEn,
    this.courseTimeAr,
    this.courseTimeEn,
    this.churchNameAr,
    this.churchNameEn,
    this.courseNameAr,
    this.courseNameEn,
    this.coupleId,
    this.remAttendanceCount,
    this.courseTypeName,
    this.listOfmember,
    this.remAttendanceDeaconCount,
    this.attendanceTypeID,
    this.attendanceTypeNameEn,
    this.attendanceTypeNameAr,
  });

  String? courseDateOfBook;
  String? courseDateAr;
  String? registrationNumber;
  bool? allowEdit;
  String? churchRemarks;
  String? courseRemarks;
  String? courseDateEn;
  String? branchNameEn;
  String? courseTimeAr;
  String? courseTimeEn;
  String? churchNameAr;
  String? churchNameEn;
  String? courseNameAr;
  String? courseNameEn;
  String? coupleId;
  String? remAttendanceCount;
  String? courseTypeName;
  List<EditFamilyMember>? listOfmember;
  String? remAttendanceDeaconCount;
  int? attendanceTypeID;
  String? attendanceTypeNameEn;
  String? attendanceTypeNameAr;

  factory EditBookingDetails.fromJson(Map<String, dynamic> json) => EditBookingDetails(
        courseDateOfBook: json["CourseDateOfBook"] as String?,
        courseDateAr: json["CourseDateAr"] as String?,
        registrationNumber: json["RegistrationNumber"] as String?,
        allowEdit: json["AllowEdit"] as bool?,
        churchRemarks: json["ChurchRemarks"] as String?,
        courseRemarks: json["CourseRemarks"] as String?,
        courseDateEn: json["CourseDateEn"] as String?,
        branchNameEn: json["BranchNameEn"] as String?,
        courseTimeAr: json["CourseTimeAr"] as String?,
        courseTimeEn: json["CourseTimeEn"] as String?,
        churchNameAr: json["ChurchNameAr"] as String?,
        churchNameEn: json["ChurchNameEn"] as String?,
        courseNameAr: json["CourseNameAr"] as String?,
        courseNameEn: json["CourseNameEn"] as String?,
        coupleId: json["CoupleID"] as String?,
        remAttendanceCount: json["RemAttendanceCount"] as String?,
        courseTypeName: json["CourseTypeName"] as String?,
        listOfmember: json["ListOfmember"] == null
            ? null
            : List<EditFamilyMember>.from(
                json["ListOfmember"].map((x) => EditFamilyMember.fromJson(x))),
        remAttendanceDeaconCount: json["RemAttendanceDeaconCount"] as String?,
        attendanceTypeID: json["AttendanceTypeID"] as int?,
        attendanceTypeNameEn: json["AttendanceTypeNameEn"] as String?,
        attendanceTypeNameAr: json["AttendanceTypeNameAr"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "CourseDateOfBook": courseDateOfBook,
        "CourseDateAr": courseDateAr,
        "RegistrationNumber": registrationNumber,
        "AllowEdit": allowEdit,
        "ChurchRemarks": churchRemarks,
        "CourseRemarks": courseRemarks,
        "CourseDateEn": courseDateEn,
        "BranchNameEn": branchNameEn,
        "CourseTimeAr": courseTimeAr,
        "CourseTimeEn": courseTimeEn,
        "ChurchNameAr": churchNameAr,
        "ChurchNameEn": churchNameEn,
        "CourseNameAr": courseNameAr,
        "CourseNameEn": courseNameEn,
        "CoupleID": coupleId,
        "RemAttendanceCount": remAttendanceCount,
        "CourseTypeName": courseTypeName,
        "ListOfmember": listOfmember == null
            ? null
            : List<dynamic>.from(listOfmember!.map((x) => x.toJson())),
        "RemAttendanceDeaconCount": remAttendanceDeaconCount,
        "AttendanceTypeID": attendanceTypeID,
        "AttendanceTypeNameEn": attendanceTypeNameEn,
        "AttendanceTypeNameAr": attendanceTypeNameAr,
      };
}

class EditFamilyMember {
  EditFamilyMember({
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

  factory EditFamilyMember.fromJson(Map<String, dynamic> json) => EditFamilyMember(
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
