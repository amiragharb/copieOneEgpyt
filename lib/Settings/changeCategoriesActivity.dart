import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Models/newsCategory.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_text/skeleton_text.dart';


BaseUrl BASE_URL = new BaseUrl();
String baseUrl = BASE_URL.BASE_URL;

class ChangeCategoriesActivity extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ChangeCategoriesActivityState();
  }
}

class ChangeCategoriesActivityState extends State<ChangeCategoriesActivity>
    with TickerProviderStateMixin {
  late String mobileToken;
  late String myLanguage;
  List<NewsCategory> categoriesList = [];
  List<Map<String, dynamic>> listViewCategories = [];

  final _formKey = GlobalKey<FormState>();
  int loadingState = 0;
  int savingState = 0;
  late Animation<double> _animationSaving;
  late String userID;
  late String accountType;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((String? token) {
      if (token != null) {
        print("Token  " + token);
        mobileToken = token;
      }
    });
    getSharedData();
  }

  Future<void> getSharedData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    myLanguage = (prefs.getString('language') ?? "en");
    accountType = prefs.getString("accountType") ?? "";
    userID = prefs.getString("userID") ?? "";
    setState(() {
      loadingState = 0;
      savingState = 0;
    });
    String connectionResponse = await _checkInternetConnection();
    if (connectionResponse == '1') {
      categoriesList = await getNewsCategories() ?? [];
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => NoInternetConnectionActivity(),
      )).then((_) async {
        categoriesList = await getNewsCategories() ?? [];
      });
    }
    if (loadingState == 1) {
      categoriesListViewData();
    }
  }

  Future<List<NewsCategory>?> getNewsCategories() async {
    final response = await http.get(Uri.parse(
        '$baseUrl/Booking/GetUserCategories/?UserAccountID=$userID&Token=$mobileToken'));
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        setState(() {
          loadingState = 3;
        });
      } else {
        setState(() {
          loadingState = 1;
        });
        return newsCategoryFromJson(response.body.toString());
      }
    } else {
      setState(() {
        loadingState = 2;
      });
    }
    return null;
  }

  void categoriesListViewData() {
    setState(() {
      for (var category in categoriesList) {
        listViewCategories.add({
          "id": category.id,
          "name": category.name,
          "isSelected": category.isSelected,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            AppLocalizations.of(context)!.newsCategories,
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: primaryDarkColor,
      ),
      body: buildChild(),
    );
  }

  Widget buildChild() {
    if (loadingState == 0) {
      return ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
          return SkeletonAnimation(
            child: Container(
              margin: EdgeInsets.all(10),
              height: 60,
              color: Colors.grey[300],
            ),
          );
        },
      );
    } else if (loadingState == 1) {
      return SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: listViewCategories.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: listViewCategories[index]["isSelected"],
                      onChanged: (bool? value) {
                        setState(() {
                          listViewCategories[index]["isSelected"] = value!;
                        });
                      },
                    ),
                    title: Text(
                      listViewCategories[index]["name"],
                      style: TextStyle(
                        fontSize: 18,
                        color: logoBlue,
                      ),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                child: buildSaveButton(),
                onPressed: () async {
                  String connectionResponse =
                      await _checkInternetConnection();
                  if (connectionResponse == '1') {
                    if (savingState == 0 || savingState == 2) {
                      animateButton();
                    }
                    await saveUserCategories();
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          NoInternetConnectionActivity(),
                    ));
                  }
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.errorConnectingWithServer,
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }

  Future<void> saveUserCategories() async {
    String chosenCategories = listViewCategories
        .where((element) => !(element["isSelected"] ?? false))
        .map((e) => e["id"].toString())
        .join(",");

    setState(() {
      savingState = 1;
    });

    String response = await saveUserNewsCategories(chosenCategories);
    setState(() {
      savingState = 2;
    });

    Fluttertoast.showToast(
      msg: response == "1"
          ? AppLocalizations.of(context)!.savedSuccessfully
          : AppLocalizations.of(context)!.errorConnectingWithServer,
      backgroundColor: Colors.white,
      textColor: response == "1" ? Colors.green : Colors.red,
    );

    if (response == "1") {
      Navigator.of(context).pop();
    }
  }

  Future<String> saveUserNewsCategories(String chosenCategories) async {
    final response = await http.post(Uri.parse(
        '$baseUrl/Booking/SaveUserAccountNewsCategories/?listCatg=$chosenCategories&UserAccountID=$userID&token=$mobileToken'));
    return response.statusCode == 200 ? "1" : "0";
  }

  Widget buildSaveButton() {
    return savingState == 1
        ? CircularProgressIndicator(color: Colors.white)
        : Text(
            AppLocalizations.of(context)!.save,
            style: TextStyle(fontSize: 18),
          );
  }

  void animateButton() {
    var controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animationSaving = Tween<double>(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.forward();
  }

  Future<String> _checkInternetConnection() async {
    var result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.none ? "0" : "1";
  }
}
