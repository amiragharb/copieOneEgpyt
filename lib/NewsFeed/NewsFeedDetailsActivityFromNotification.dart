import 'package:cached_network_image/cached_network_image.dart';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Models/newsDetails.dart' show newsDetailsFromJson, NewsDetails, NewsFile;
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:skeleton_text/skeleton_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// You must define BaseUrl, AppLocalizations, YoutubeVideo, MP4Video, YoutubeCoverVideo, MP4CoverVideo, NewsFeedActivityWithCategoryID, NoInternetConnectionActivity, NewsDetails, and NewsFile elsewhere in your project.

// Updated fields with null safety
int loadingState = 0;
String? mobileToken;
String? userID = "";
String? myLanguage;

int? newsId;
String? subject;
String? description;
String? creatorUserId;
String? byUser;
String? churchName;
String? time1;
String? date2;
String? date;
String? isSeen;
int? newsCategoryId;
String? newsCategoryName;
String? youtubeUrl;
String? coverFileName;
String? coverFileUrl;
List<NewsFile>? newsFiles;

BaseUrl BASE_URL = BaseUrl();
String baseUrl = BASE_URL.BASE_URL;

class NewsFeedDetailsActivity extends StatefulWidget {
  NewsFeedDetailsActivity(int id) {
    newsId = id;
  }

  @override
  _NewsFeedDetailsActivityState createState() => _NewsFeedDetailsActivityState();
}

class _NewsFeedDetailsActivityState extends State<NewsFeedDetailsActivity> {
  List<Map> listViewNewsYoutubeVideos = [];
  List<Map> listViewNewsMp4Videos = [];
  List<Map> listViewNewsImages = [];
  List<NewsDetails> newsDetailsList = [];

  @override
  void initState() {
    super.initState();
    loadingState = 0;
    FirebaseMessaging.instance.getToken().then((String? token) {
      if (token != null) {
        print("Token  \$token");
        mobileToken = token;
      }
    });
    getDataFromShared();
  }

  Future<String> _checkInternetConnection() async {
    var result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.none ? "0" : "1";
  }

  getDataFromShared() async {
    final prefs = await SharedPreferences.getInstance();
    myLanguage = prefs.getString('language') ?? "en";
    userID = prefs.getString("userID");

    String connectionResponse = await _checkInternetConnection();
    if (connectionResponse == '1') {
      newsDetailsList = await getNewsDetails() ?? [];
      if (newsDetailsList.isNotEmpty) {
        newsDetailsListViewData();
      }
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NoInternetConnectionActivity(),
        ),
      ).then((_) async {
        newsDetailsList = await getNewsDetails() ?? [];
        if (newsDetailsList.isNotEmpty) {
          newsDetailsListViewData();
        }
      });
    }
  }

  newsDetailsListViewData() {
    setState(() {
      if (newsDetailsList.isNotEmpty && newsDetailsList.first.newsFiles != null) {
        for (var file in newsDetailsList.first.newsFiles!) {
          String extension = getFileExtension(file.fileUrl ?? "");
          Map item = {
            "newsFileId": file.newsFileId,
            "fileUrl": file.fileUrl,
            "fileName": file.fileName,
            "youtubeUrl": file.youtubeUrl,
            "description": file.description,
          };

          if ((file.youtubeUrl ?? '').isNotEmpty) {
            listViewNewsYoutubeVideos.add(item);
          } else if ([".png", ".jpg", ".jpeg", ".bmp", ".gif"].contains(extension)) {
            listViewNewsImages.add(item);
          } else {
            listViewNewsMp4Videos.add(item);
          }
        }
      }
    });
  }

  Future<List<NewsDetails>?> getNewsDetails() async {
    final prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userID");
    await FirebaseMessaging.instance.getToken().then((String? token) {
      if (token != null) {
        mobileToken = token;
      }
    });

    String languageID = myLanguage == "en" ? "2" : "1";

    var response = await http.post(Uri.parse(
        '\$baseUrl/News/GetNewsDetails/?UserAccountID=\$userID&NewsID=\$newsId&Token=\$mobileToken'));

    if (response.statusCode == 200) {
      setState(() {
        loadingState = 1;
      });

      var newsDetailsObj = newsDetailsFromJson(response.body);

      final detail = newsDetailsObj.first;
      newsId = detail.newsId;
      subject = detail.subject;
      description = detail.description;
      creatorUserId = detail.creatorUserId;
      byUser = detail.byUser;
      churchName = detail.churchName;
      time1 = detail.time1;
      date2 = detail.date2;
      date = detail.date;
      isSeen = detail.isSeen;
      newsCategoryId = detail.newsCategoryId;
      newsCategoryName = detail.newsCategoryName;
      youtubeUrl = detail.youtubeUrl;
      coverFileName = detail.coverFileName;
      coverFileUrl = detail.coverFileUrl;
      newsFiles = detail.newsFiles;

      return newsDetailsObj;
    } else {
      setState(() {
        loadingState = 2;
      });
      print("get newsDetails error");
      return null;
    }
  }

  String getFileExtension(String? url) {
    return p.extension(url ?? '').split('?').first;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            AppLocalizations.of(context)!.details,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
          ),
        ),
        backgroundColor: primaryDarkColor,
      ),
      body: buildChild(),
    );
  }

  Widget buildChild() {
    return Center(
      child: Text('TODO: Implement news detail view'),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final String imageUrl;

  DetailScreen(this.imageUrl);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        body: InteractiveViewer(
          panEnabled: false,
          boundaryMargin: EdgeInsets.all(80),
          minScale: 0.5,
          maxScale: 4,
          child: Center(
            child: Hero(
              tag: 'imageHero',
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}
