import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/NewsFeed/NewsFeedDetailsActivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:skeleton_text/skeleton_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../Home/homeActivity.dart' hide baseUrl;
import '../Models/news.dart';
import '../Translation/localizations.dart';
import '../NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'NewsFeedDetailsActivity.dart';


class NewsFeedActivityWithCategoryID extends StatefulWidget {
  final String categoryID;
  final String categoryName;

  const NewsFeedActivityWithCategoryID(this.categoryID, this.categoryName, {Key? key}) : super(key: key);

  @override
  _NewsFeedActivityWithCategoryIDState createState() => _NewsFeedActivityWithCategoryIDState();
}

class _NewsFeedActivityWithCategoryIDState extends State<NewsFeedActivityWithCategoryID> {
  late String userID;
  late String myLanguage;
  late ScrollController _scrollController;
  late SharedPreferences prefs;

  List<News> newsList = [];
  List<Map<String, dynamic>> listViewNewsFeed = [];

  bool stopLoadingData = false;
  bool isLoading = false;
  int loadingState = 0;
  int page = 0;
  String? mobileToken;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _init();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !stopLoadingData && !isLoading) {
      getNewsList();
    }
  }

  Future<void> _init() async {
    prefs = await SharedPreferences.getInstance();
    myLanguage = prefs.getString('language') ?? "en";
    userID = prefs.getString("userID") ?? "";

    mobileToken = await FirebaseMessaging.instance.getToken();

    String connectionResponse = await _checkInternetConnection();
    if (connectionResponse == '1') {
      newsList = await getNewsList();
      if (loadingState == 1) newsListViewData();
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => NoInternetConnectionActivity()))
          .then((_) async {
        newsList = await getNewsList();
        if (loadingState == 1) newsListViewData();
      });
    }
  }

  Future<String> _checkInternetConnection() async {
    var result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.none ? "0" : "1";
  }

  Future<List<News>> getNewsList() async {
    setState(() => isLoading = true);
    final uri = Uri.parse(
      '$baseUrl/News/GetNews/?UserAccountID=$userID&NewsCategoryID=${widget.categoryID}&KeyWord=&page=$page&Token=$mobileToken'
    );
    final response = await http.post(uri);

    if (response.statusCode == 200) {
      setState(() => isLoading = false);
      if (response.body == "[]" && page == 0) {
        setState(() => loadingState = 3);
        return [];
      } else if (response.body == "[]" || response.body.isEmpty) {
        setState(() => stopLoadingData = true);
        return [];
      } else {
        final newsObj = newsFromJson(response.body);
        setState(() {
          loadingState = 1;
          page++;
        });
        return newsObj;
      }
    } else {
      setState(() {
        isLoading = false;
        loadingState = 2;
      });
      return [];
    }
  }

  void newsListViewData() {
  setState(() {
    for (final news in newsList) {
      if (!listViewNewsFeed.any((item) => item["newsId"] == news.newsId)) {
        listViewNewsFeed.add({
          "newsId": news.newsId ?? 0,
          "subject": news.subject ?? "",
          "description": news.description ?? "",
          "creatorUserId": news.creatorUserId ?? "",
          "byUser": news.byUser ?? "",
          "churchName": news.churchName ?? "",
          "time1": news.time1 ?? "",
          "date2": news.date2 ?? "",
          "date": news.date ?? "",
          "isSeen": news.isSeen ?? "0",
          "newsCategoryId": news.newsCategoryId ?? 0,
          "newsCategoryName": news.newsCategoryName ?? "",
          "youtubeUrl": news.youtubeUrl ?? "",
          "coverFileName": news.coverFileName ?? "",
          "coverFileUrl": news.coverFileUrl ?? "",
        });
      }
    }
  });
}


  String getFileExtension(String url) {
    return p.extension(url).split('?').first;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.categoryName, style: const TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: buildChild(),
    );
  }

  Widget buildChild() {
    // You can plug back the conditional UI rendering blocks for loadingState == 0/1/2/3
    return Container();
  }
}
