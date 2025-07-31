class User {
  String? userID;
  String? loginUsername;
  String? name;
  bool? isValidate;
  String? languageID;
  String? deviceTypeID;
  bool? isActiveted;
  String? accountType;
  String? email;
  String? address;
  bool? hasMainAccount;
  String? sucessCode;
  int? governateID;
  int? branchID;

  User({
    this.userID,
    this.loginUsername,
    this.name,
    this.isValidate,
    this.languageID,
    this.deviceTypeID,
    this.isActiveted,
    this.accountType,
    this.email,
    this.address,
    this.hasMainAccount,
    this.sucessCode,
    this.governateID,
    this.branchID,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userID: json['UserID'],
        loginUsername: json['LoginUsername'],
        name: json['Name'],
        isValidate: json['IsValidate'],
        languageID: json['LanguageID'],
        deviceTypeID: json['DeviceTypeID'],
        isActiveted: json['IsActiveted'],
        accountType: json['AccountType'],
        email: json['Email'],
        address: json['Address'],
        hasMainAccount: json['HasMainAccount'],
        sucessCode: json['sucessCode'],
        governateID: json['GovernateID'],
        branchID: json['BranchID'],
      );

  Map<String, dynamic> toJson() => {
        "UserID": userID,
        "LoginUsername": loginUsername,
        "Name": name,
        "IsValidate": isValidate,
        "LanguageID": languageID,
        "DeviceTypeID": deviceTypeID,
        "IsActiveted": isActiveted,
        "AccountType": accountType,
        "Email": email,
        "Address": address,
        "HasMainAccount": hasMainAccount,
        "sucessCode": sucessCode,
        "GovernateID": governateID,
        "BranchID": branchID,
      };
}