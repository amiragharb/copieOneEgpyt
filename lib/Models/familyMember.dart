import 'dart:convert';

List<FamilyMember> familyMemberFromJson(String str) =>
    List<FamilyMember>.from(json.decode(str).map((x) => FamilyMember.fromJson(x)));

String familyMemberToJson(List<FamilyMember> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FamilyMember {
  FamilyMember({
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
    this.address,
    this.personRelationNameAr,
    this.personRelationNameEn,
    this.isMainPerson,
    this.branchID,
    this.governorateID,
    this.churchOfAttendance,
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
  String? address;
  String? personRelationNameAr;
  String? personRelationNameEn;
  bool? isMainPerson;
  String? branchID;
  String? governorateID;
  String? churchOfAttendance;

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
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
        address: json["Address"] as String?,
        personRelationNameAr: json["PersonRelationNameAr"] as String?,
        personRelationNameEn: json["PersonRelationNameEn"] as String?,
        isMainPerson: json["IsMainPerson"] as bool?,
        branchID: json["branchID"] as String?,
        governorateID: json["GovernorateID"] as String?,
        churchOfAttendance: json["churchOfAttendance"] as String?,
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
        "Address": address,
        "PersonRelationNameAr": personRelationNameAr,
        "PersonRelationNameEn": personRelationNameEn,
        "IsMainPerson": isMainPerson,
        "branchID": branchID,
        "GovernorateID": governorateID,
        "churchOfAttendance": churchOfAttendance,
      };
}
