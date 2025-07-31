class InsurancesList {
  final List<InsuranceType> insuranceTypesObj;

  InsurancesList({
    required this.insuranceTypesObj,
  });

  factory InsurancesList.fromJson(List<dynamic> parsedJson) {
    return InsurancesList(
      insuranceTypesObj: parsedJson.map((i) => InsuranceType.fromJson(i)).toList(),
    );
  }
}

class InsuranceType {
  final String? nameEn;
  final String? id;
  final String? nameAr;

  InsuranceType({
    this.nameEn,
    this.id,
    this.nameAr,
  });

  factory InsuranceType.fromJson(Map<String, dynamic> json) {
    return InsuranceType(
      nameEn: json['insuranceType_name_En'] as String?,
      id: json['insuranceType_id'] as String?,
      nameAr: json['insuranceType_name_Ar'] as String?,
    );
  }
}
