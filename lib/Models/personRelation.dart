// To parse this JSON data, do
//
//     final churchs = churchsFromJson(jsonString);

import 'dart:convert';

List<PersonRelation> personRelationFromJson(String str) =>
    List<PersonRelation>.from(json.decode(str).map((x) => PersonRelation.fromJson(x)));

String personRelationToJson(List<PersonRelation> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PersonRelation {
  int? id;
  int? genderTypeID;
  String? nameAr;
  String? nameEn;

  PersonRelation({
    this.id,
    this.genderTypeID,
    this.nameAr,
    this.nameEn,
  });

  factory PersonRelation.fromJson(Map<String, dynamic> json) => PersonRelation(
        id: json["ID"],
        genderTypeID: json["GenderTypeID"],
        nameAr: json["NameAr"],
        nameEn: json["NameEn"],
      );

  Map<String, dynamic> toJson() => {
        "ID": id,
        "GenderTypeID": genderTypeID,
        "NameAr": nameAr,
        "NameEn": nameEn,
      };
}

// User Model
