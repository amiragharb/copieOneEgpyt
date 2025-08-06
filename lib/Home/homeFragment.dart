import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:egpycopsversion4/API/apiClient.dart' show BaseUrl;
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Models/news.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/NewsFeed/NewsFeedDetailsActivity.dart';
import 'package:egpycopsversion4/NewsFeed/mP4Video.dart';
import 'package:egpycopsversion4/NewsFeed/newsFeedActivityWithCategoryID.dart';
import 'package:egpycopsversion4/NewsFeed/youtubeVideo.dart';
import 'package:egpycopsversion4/l10n/app_localizations.dart'; // <<----- Correction ici
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:skeleton_text/skeleton_text.dart';

import '../Home/homeActivity.dart';

BaseUrl BASE_URL = BaseUrl();
String baseUrl = BASE_URL.BASE_URL;

class HomeFragment extends StatefulWidget {
  const HomeFragment({Key? key}) : super(key: key);

  @override
  _HomeFragmentState createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> with TickerProviderStateMixin {
  String? mobileToken;
  List<News> newsList = [];
  List<Map<String, dynamic>> listViewNewsFeed = [];
  final ScrollController _scrollController = ScrollController();
  int loadingState = 0;
  String myLanguage = "en";
  String? userID = "";
  int page = 0;
  bool stopLoadingData = false, isLoading = false;

  @override
  void initState() {
    super.initState();
    _initToken();
    loadingState = 0;
    page = 0;
    stopLoadingData = false;
    isLoading = false;
    getDataFromShared();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          !stopLoadingData &&
          !isLoading) {
        getNewsList();
      }
    });
  }

  Future<void> _initToken() async {
    mobileToken = await FirebaseMessaging.instance.getToken();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<String> _checkInternetConnection() async {
    // Utiliser connectivity_plus en production.
    return "1";
  }

  Future<void> getDataFromShared() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      myLanguage = (prefs.getString('language') ?? "en");
      userID = prefs.getString("userID") ?? "";
      setState(() {
        loadingState = 0;
      });
      String connectionResponse = await _checkInternetConnection();
      if (connectionResponse == '1') {
        var fetchedNews = await getNewsList();
        if (mounted && loadingState == 1 && fetchedNews.isNotEmpty) {
          newsListViewData();
        }
      } else {
        if (!mounted) return;
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => NoInternetConnectionActivity()))
            .then((value) async {
          var fetchedNews = await getNewsList();
          if (mounted && loadingState == 1 && fetchedNews.isNotEmpty) {
            newsListViewData();
          }
        });
      }
    } catch (e) {
      debugPrint("Error in getDataFromShared: $e");
      if (mounted) {
        setState(() {
          loadingState = 2; // Error state
        });
      }
    }
  }

  void newsListViewData() {
    try {
      setState(() {
        listViewNewsFeed.clear();
        for (int i = 0; i < newsList.length; i++) {
          listViewNewsFeed.add(newsList[i].toJson());
        }
      });
    } catch (e) {
      debugPrint("Error in newsListViewData: $e");
      setState(() {
        loadingState = 2; // Error state
      });
    }
  }

  Future<List<News>> getNewsList() async {
    if (isLoading) return newsList;
    setState(() { isLoading = true; });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userID") ?? "";
    if (mobileToken == null || mobileToken?.isEmpty == true) {
      mobileToken = await FirebaseMessaging.instance.getToken();
    }

    final url = Uri.parse('$baseUrl/News/GetNews/?UserAccountID=$userID&NewsCategoryID=&KeyWord=&page=$page&Token=${mobileToken ?? ""}');
    final response = await http.post(url);

    setState(() { isLoading = false; });

    if (response.statusCode == 200) {
      final String responseBody = response.body;
      if ((responseBody == "[]" && page == 0) || responseBody.isEmpty) {
        setState(() => loadingState = 3); // No news found
        stopLoadingData = true;
        return [];
      } else if (responseBody == "[]" || responseBody.isEmpty) {
        setState(() => stopLoadingData = true);
        return [];
      } else {
        setState(() => loadingState = 1);
        try {
          var newsObj = newsFromJson(responseBody); // newsFromJson returns List<News>
          page++;
          newsList.addAll(newsObj);
          return newsObj;
        } catch (e) {
          debugPrint("Error parsing news JSON: $e");
          setState(() { loadingState = 2; });
          return [];
        }
      }
    } else {
      setState(() { loadingState = 2; });
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildChild(),
    );
  }

  Widget buildChild() {
    final local = AppLocalizations.of(context)!; // Utilisation du l10n officiel
    if (loadingState == 0) {
      // Skeleton
      return ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(14.0),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  color: Colors.white70),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonAnimation(
                        child: Container(
                          height: 15,
                          width: MediaQuery.of(context).size.width * 0.7,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey[300]),
                        ),
                      ),
                      SizedBox(height: 5),
                      SkeletonAnimation(
                        child: Container(
                          width: 110,
                          height: 13,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey[300]),
                        ),
                      ),
                      SizedBox(height: 5),
                      SkeletonAnimation(
                        child: Container(
                          width: 80,
                          height: 13,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey[300]),
                        ),
                      ),
                      SizedBox(height: 5),
                      SkeletonAnimation(
                        child: Container(
                          width: 80,
                          height: 13,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey[300]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (loadingState == 1) {
      return ListView.builder(
        controller: _scrollController,
        itemCount: listViewNewsFeed.length,
        itemBuilder: (context, index) {
          final news = listViewNewsFeed[index];
          return GestureDetector(
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // News subject
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      news["Subject"] ?? "",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'cocon-next-arabic-regular',
                        fontWeight: FontWeight.normal,
                        color: logoBlue,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Date
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      news["Date"] ?? "",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'cocon-next-arabic-regular',
                        fontWeight: FontWeight.normal,
                        color: grey500,
                      ),
                    ),
                  ),
                  // Church name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        Text(
                          news["ChurchName"] ?? "",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'cocon-next-arabic-regular',
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // By user
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        Text(
                          local.by,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'cocon-next-arabic-regular',
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          news["ByUser"] ?? "",
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'cocon-next-arabic-regular',
                            fontWeight: FontWeight.normal,
                            color: primaryDarkColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // News Category
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        news["NewsCategoryName"] ?? "",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'cocon-next-arabic-regular',
                          fontWeight: FontWeight.normal,
                          color: primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    onTap: () async {
                      String connectionResponse = await _checkInternetConnection();
                      if (connectionResponse == '1') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NewsFeedActivityWithCategoryID(
                                news["NewsCategoryID"].toString(),
                                news["NewsCategoryName"]),
                          ),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NoInternetConnectionActivity(),
                          ),
                        );
                      }
                    },
                  ),
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: Text(
                      news["Description"] ?? "",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'cocon-next-arabic-regular',
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Media
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if ((news["YoutubeURL"] ?? "").isNotEmpty)
                          YoutubeVideo(news["YoutubeURL"])
                        else if ((news["CoverFileURL"] ?? "").isNotEmpty)
                          _buildMedia(news["CoverFileURL"])
                        else
                          Container(),
                        Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            onTap: () async {
              String connectionResponse = await _checkInternetConnection();
              if (connectionResponse == '1') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NewsFeedDetailsActivity(news["NewsID"]),
                  ),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NoInternetConnectionActivity(),
                  ),
                );
              }
            },
          );
        },
      );
    } else if (loadingState == 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Text(
            local.errorConnectingWithServer,
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: 'cocon-next-arabic-regular',
              color: Colors.grey,
            ),
          ),
        ),
      );
    } else if (loadingState == 3) {
      return Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image(
                image: ExactAssetImage('images/earth.png'),
                color: Colors.grey,
                width: 60,
                height: 60,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                local.noNewsFound,
                style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: 'cocon-next-arabic-regular',
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildMedia(String url) {
    final ext = getFileExtension(url).toLowerCase();
    if (ext == ".mp4") {
      return MP4Video(url);
    } else if ([".png", ".jpg", ".jpeg", ".bmp", ".gif"].contains(ext)) {
      return CachedNetworkImage(
        imageUrl: url,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    }
    return Container();
  }

  String getFileExtension(String url) {
    String urlFileExtension = p.extension(url).split('?').first;
    return urlFileExtension;
  }
}
