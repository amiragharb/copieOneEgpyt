class UserInsurance {
  int? iD;
  int? insuranceTypeID;
  String? insuranceTypeOther;
  String? insuranceCardNumber;
  int? hasConcessionCard;
  String? insuranceConcessionCardNumber;

  UserInsurance({
    this.iD,
    this.insuranceTypeID,
    this.insuranceTypeOther,
    this.insuranceCardNumber,
    this.hasConcessionCard,
    this.insuranceConcessionCardNumber,
  });

  factory UserInsurance.fromJson(Map<String, dynamic> json) => UserInsurance(
        iD: json['ID'],
        insuranceTypeID: json['InsuranceTypeID'],
        insuranceTypeOther: json['InsuranceTypeOther'],
        insuranceCardNumber: json['InsuranceCardNumber'],
        hasConcessionCard: json['HasConcessionCard'],
        insuranceConcessionCardNumber: json['InsuranceConcessionCardNumber'],
      );

  Map<String, dynamic> toJson() => {
        "ID": iD,
        "InsuranceTypeID": insuranceTypeID,
        "InsuranceTypeOther": insuranceTypeOther,
        "InsuranceCardNumber": insuranceCardNumber,
        "HasConcessionCard": hasConcessionCard,
        "InsuranceConcessionCardNumber": insuranceConcessionCardNumber,
      };
}