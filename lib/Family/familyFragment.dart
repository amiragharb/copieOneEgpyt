import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Family/addFamilyMemberActivity.dart';
import 'package:egpycopsversion4/Models/familyMember.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/l10n/app_localizations.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:skeleton_text/skeleton_text.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

typedef void LocaleChangeCallback(Locale locale);

BaseUrl BASE_URL = BaseUrl();
String baseUrl = BASE_URL.BASE_URL;

class FamilyFragment extends StatefulWidget {
  const FamilyFragment({Key? key}) : super(key: key);

  @override
  State<FamilyFragment> createState() => _FamilyFragmentState();
}

class _FamilyFragmentState extends State<FamilyFragment> {
  List<FamilyMember> myFamilyList = [];
  List<Map<String, dynamic>> listViewMyFamily = [];
  final ScrollController _scrollController = ScrollController();
  int loadingState = 0; // 0 = loading, 1 = loaded, 2 = error, 3 = empty
  int pageNumber = 0;
  String userID = "";
  String? mobileToken;
  late BuildContext mContext;
  late String myLanguage;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((String? token) {
      if (mounted && token != null) {
        mobileToken = token;
      }
    });
    pageNumber = 0;
    loadingState = 0;
    getDataFromShared();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // pagination possible ici si besoin
      }
    });
  }

  Future<String> _checkInternetConnection() async {
    var result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.none ? "0" : "1";
  }

  Future<void> getDataFromShared() async {
    final prefs = await SharedPreferences.getInstance();
    myLanguage = prefs.getString('language') ?? "en";
    userID = prefs.getString("userID") ?? "";
    setState(() {
      loadingState = 0;
      pageNumber = 0;
    });
    String connectionResponse = await _checkInternetConnection();
    if (connectionResponse == '1') {
      myFamilyList = await getMyFamily();
      if (loadingState == 1 && myFamilyList.isNotEmpty) {
        myFamilyListViewData();
      }
    } else {
      if (!mounted) return;
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => NoInternetConnectionActivity(),
        ),
      )
          .then((value) async {
        myFamilyList = await getMyFamily();
        if (loadingState == 1 && myFamilyList.isNotEmpty) {
          myFamilyListViewData();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    return Scaffold(
      body: buildChild(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => AddFamilyMemberActivity(
                  true, "", "0", 0, "", "", "", "", "", "", "", 0, false),
            ),
          )
              .then((value) {
            setState(() {
              pageNumber = 0;
              loadingState = 0;
              listViewMyFamily.clear();
              getDataFromShared();
            });
          });
        },
        tooltip: 'Add',
        backgroundColor: accentColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void myFamilyListViewData() {
    setState(() {
      listViewMyFamily.clear();
      for (var member in myFamilyList) {
        listViewMyFamily.add({
          "userAccountMemberId": member.userAccountMemberId,
          "userAccountId": member.userAccountId,
          "accountMemberNameAr": member.accountMemberNameAr,
          "genderTypeId": member.genderTypeId,
          "genderTypeNameAr": member.genderTypeNameAr,
          "genderTypeNameEn": member.genderTypeNameEn,
          "isDeacon": member.isDeacon,
          "nationalIdNumber": member.nationalIdNumber,
          "mobile": member.mobile,
          "personRelationId": member.personRelationId,
          "address": member.address,
          "personRelationNameAr": member.personRelationNameAr,
          "personRelationNameEn": member.personRelationNameEn,
          "isMainPerson": member.isMainPerson,
          "branchID": member.branchID,
          "governorateID": member.governorateID,
          "churchOfAttendance": member.churchOfAttendance,
        });
      }
    });
  }

  Future<List<FamilyMember>> getMyFamily() async {
    final prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userID") ?? "";
    await FirebaseMessaging.instance.getToken().then((String? token) {
      if (token != null) {
        mobileToken = token;
      }
    });
    final url =
        '$baseUrl/Family/GetFamilyMembers/?UserID=$userID&Token=$mobileToken';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      if (response.body.isEmpty && listViewMyFamily.isEmpty) {
        setState(() {
          loadingState = 3;
        });
        return [];
      } else {
        setState(() {
          loadingState = 1;
        });
        var myFamilyMembersObj = familyMemberFromJson(response.body.toString());
        return myFamilyMembersObj;
      }
    } else {
      setState(() {
        loadingState = 2;
      });
      return [];
    }
  }

  Widget buildChild() {
    if (loadingState == 0) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (loadingState == 1) {
      return buildFamilyList();
    } else if (loadingState == 2) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.errorConnectingWithServer,
          style: const TextStyle(
            fontSize: 20.0,
            fontFamily: 'cocon-next-arabic-regular',
            color: Colors.grey,
          ),
        ),
      );
    } else {
      // loadingState == 3
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noMembersFound,
          style: const TextStyle(
            fontSize: 20.0,
            fontFamily: 'cocon-next-arabic-regular',
            color: Colors.grey,
          ),
        ),
      );
    }
  }

  Widget buildFamilyList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: listViewMyFamily.length,
      itemBuilder: (context, index) {
        var member = listViewMyFamily[index];
        return GestureDetector(
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member["accountMemberNameAr"] ?? '',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'cocon-next-arabic-regular',
                            color: logoBlue,
                          ),
                          maxLines: 1,
                        ),
                        Text(
                          myLanguage == "en"
                              ? member["personRelationNameEn"] ?? ''
                              : member["personRelationNameAr"] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'cocon-next-arabic-regular',
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  deleteIcon(
                      member["isMainPerson"] ?? false,
                      index,
                      member["userAccountMemberId"] ?? ""),
                ],
              ),
            ),
          ),
          onTap: () {
            int isDeacon = (member["isDeacon"] == true) ? 1 : 2;
            int isMain = (member["isMainPerson"] == true) ? 1 : 0;
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => AddFamilyMemberActivity(
                  false,
                  member["accountMemberNameAr"] ?? "",
                  member["personRelationId"] ?? "",
                  isDeacon,
                  member["nationalIdNumber"] ?? "",
                  member["mobile"] ?? "",
                  member["userAccountMemberId"] ?? "",
                  member["address"] ?? "",
                  member["branchID"] ?? "",
                  member["governorateID"] ?? "",
                  member["churchOfAttendance"] ?? "",
                  isMain,
                  false,
                ),
              ),
            )
                .then((value) {
              setState(() {
                pageNumber = 0;
                loadingState = 0;
                listViewMyFamily.clear();
                getDataFromShared();
              });
            });
          },
        );
      },
    );
  }

  Future<String> deleteFamilyMember(String memberID) async {
    final url =
        '$baseUrl/Family/DeleteFamilyMember/?UserAccountID=$userID&AccountMemberID=$memberID&Token=$mobileToken';
    var response = await http.post(Uri.parse(url));
    if (response.statusCode == 200) {
      if (response.body.toString() == "1") {
        return "1";
      } else {
        return response.body;
      }
    } else {
      return response.body;
    }
  }

  Widget deleteIcon(bool isMainPerson, int index, String memberID) {
    if (isMainPerson) {
      return Container();
    } else {
      return InkWell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.delete,
            color: primaryColor,
          ),
        ),
        onTap: () async {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(
                AppLocalizations.of(mContext)!.doYouWantToDeleteThisMember,
                style: const TextStyle(
                  fontFamily: 'cocon-next-arabic-regular',
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    String connectionResponse =
                        await _checkInternetConnection();
                    if (connectionResponse == '1') {
                      Navigator.pop(context);

                      ProgressDialog progressDialog =
                          ProgressDialog(mContext, isDismissible: false);
                      progressDialog.style(
                        message: AppLocalizations.of(mContext)!.pleaseWait,
                        borderRadius: 10.0,
                        backgroundColor: Colors.white,
                        progressWidget: const CircularProgressIndicator(),
                        elevation: 10.0,
                        insetAnimCurve: Curves.easeInOut,
                        progress: 0.0,
                        maxProgress: 100.0,
                        progressTextStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 13.0,
                            fontWeight: FontWeight.normal),
                        messageTextStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 19.0,
                            fontWeight: FontWeight.normal),
                      );
                      await progressDialog.show();

                      String responseDeleteFamilyMember =
                          await deleteFamilyMember(memberID);
                      await progressDialog.hide();
                      if (responseDeleteFamilyMember == '1') {
                        setState(() {
                          listViewMyFamily.removeAt(index);
                        });
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(mContext)!
                                .deletedSuccessfully,
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.white,
                            textColor: Colors.green,
                            fontSize: 16.0);
                      } else if (responseDeleteFamilyMember == '2') {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(mContext)!
                                .cannotDeleteBecauseThisUserIsLinkedToBookings,
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.white,
                            textColor: Colors.red,
                            fontSize: 16.0);
                      } else {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(mContext)!
                                .errorConnectingWithServer,
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.white,
                            textColor: Colors.red,
                            fontSize: 16.0);
                      }
                    }
                  },
                  child: Text(
                    AppLocalizations.of(mContext)!.yes,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'cocon-next-arabic-regular',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(mContext)!.no,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontFamily: 'cocon-next-arabic-regular',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
