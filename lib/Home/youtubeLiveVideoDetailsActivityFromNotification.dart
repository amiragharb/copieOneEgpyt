import 'package:connectivity_plus/connectivity_plus.dart' show Connectivity, ConnectivityResult;
import 'package:egpycopsversion4/Colors/colors.dart';
import 'package:egpycopsversion4/Home/homeActivity.dart';
import 'package:egpycopsversion4/Home/youtubeLiveVideo.dart';
import 'package:egpycopsversion4/Models/liveVideoDetails.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Translation/localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:skeleton_text/skeleton_text.dart';
import 'dart:async';

class YoutubeLiveVideoDetailsActivityFromNotification extends StatefulWidget {
  final int videoID;

  const YoutubeLiveVideoDetailsActivityFromNotification(this.videoID, {Key? key}) : super(key: key);

  @override
  _YoutubeLiveVideoDetailsActivityFromNotificationState createState() =>
      _YoutubeLiveVideoDetailsActivityFromNotificationState();
}

class _YoutubeLiveVideoDetailsActivityFromNotificationState
    extends State<YoutubeLiveVideoDetailsActivityFromNotification> {
  int loadingState = 0;
  String? mobileToken;
  String myLanguage = "en";
  String userID = "";
  String liveUrl = "";
  String liveDescriptionAr = "";
  String liveDescriptionEn = "";
  String isLive = "0";
  String nameAr = "";
  String nameEn = "";
  String date = "";

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) setState(() => mobileToken = token);
    });
    await getDataFromShared();
  }

  Future<String> _checkInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.none ? "0" : "1";
  }

  Future<void> getDataFromShared() async {
    final prefs = await SharedPreferences.getInstance();
    myLanguage = (prefs.getString('language') ?? "en");
    userID = prefs.getString("userID") ?? "";
    String connectionResponse = await _checkInternetConnection();
    if (connectionResponse == '1') {
      await getYoutubeLiveVideoDetails();
    } else {
      if (!mounted) return;
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => NoInternetConnectionActivity()))
          .then((value) async {
        await getYoutubeLiveVideoDetails();
      });
    }
  }

  Future<void> getYoutubeLiveVideoDetails() async {
    setState(() => loadingState = 0);
    final response = await http.get(
        Uri.parse('$baseUrl/Booking/GetLiveCourseDetail/?UserAccountID=$userID&CourseID=${widget.videoID}'));
    if (response.statusCode == 200) {
      var youtubeLiveVideoDetailsObj =
          youtubeLiveVideoDetailsFromJson(response.body.toString());
      if (youtubeLiveVideoDetailsObj.isNotEmpty) {
        var details = youtubeLiveVideoDetailsObj[0];
        setState(() {
          loadingState = 1;
          liveUrl = details.liveUrl ?? '';
          liveDescriptionAr = details.liveDescriptionAr ?? '';
          liveDescriptionEn = details.liveDescriptionEn ?? '';
          isLive = details.isLive ?? '0';
          nameAr = details.nameAr ?? '';
          nameEn = details.nameEn ?? '';
          date = details.date ?? '';
        });
      } else {
        setState(() => loadingState = 3);
      }
    } else {
      setState(() => loadingState = 2);
    }
  }

  Future<bool> _onWillPop() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeActivity(false)),
      ModalRoute.withName("/Home"),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeActivity(false)),
                  ModalRoute.withName("/Home"));
            },
          ),
          title: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              AppLocalizations.of(context)!.details,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
            ),
          ),
          backgroundColor: primaryDarkColor,
        ),
        body: buildChild(),
      ),
    );
  }

  Widget buildChild() {
    if (loadingState == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
        child: Center(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: 1,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(14.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSkeleton(width: 0.7, height: 15),
                          _buildSkeleton(width: 0.4, height: 15),
                          _buildSkeleton(width: 0.8, height: 150),
                          _buildSkeleton(width: 0.8, height: 13),
                          _buildSkeleton(width: 0.7, height: 13),
                          _buildSkeleton(width: 0.4, height: 13),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ),
        ),
      );
    } else if (loadingState == 1) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _textBlock(myLanguage == "en" ? liveDescriptionEn : liveDescriptionAr, primaryColor, 22),
            _textBlock(myLanguage == "en" ? nameEn : nameAr, Colors.black, 14, selectable: true),
            if (date.isNotEmpty)
              _textBlock(date, grey500, 14),
YoutubeLiveVideo(liveUrl, isLive, true)
          ],
        ),
      );
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.live_tv, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noVideosFound,
              style: const TextStyle(
                fontSize: 20.0,
                fontFamily: 'cocon-next-arabic-regular',
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSkeleton({double width = 1.0, double height = 15.0}) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, bottom: 5.0),
      child: SkeletonAnimation(
        child: Container(
          height: height,
          width: MediaQuery.of(context).size.width * width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.grey[300],
          ),
        ),
      ),
    );
  }

  Widget _textBlock(String text, Color color, double fontSize, {bool selectable = false}) {
    final style = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.normal,
      fontFamily: 'cocon-next-arabic-regular',
    );
    if (selectable) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 3),
        child: SelectableText(text, style: style),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 3),
      child: Text(text, style: style),
    );
  }
}
