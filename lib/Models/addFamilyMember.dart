import 'dart:convert';

// For parsing JSON to model
AddFamilyMember addFamilyMemberFromJson(String str) =>
    AddFamilyMember.fromJson(json.decode(str));

// For converting model to JSON string
String addFamilyMemberToJson(AddFamilyMember data) =>
    json.encode(data.toJson());

class AddFamilyMember {
  AddFamilyMember({
    this.code,
    this.nameEn,
    this.nameAr,
  });

  String? code;
  String? nameEn;
  String? nameAr;

  factory AddFamilyMember.fromJson(Map<String, dynamic> json) => AddFamilyMember(
        code: json["Code"] as String?,
        nameEn: json["NameEn"] as String?,
        nameAr: json["NameAr"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "Code": code,
        "NameEn": nameEn,
        "NameAr": nameAr,
      };
}
