import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Home/youtubeLiveVideo.dart';
import 'package:egpycopsversion4/Models/liveVideoDetails.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/Translation/localizations.dart' hide AppLocalizations;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:skeleton_text/skeleton_text.dart';
import 'package:egpycopsversion4/l10n/app_localizations.dart';

BaseUrl BASE_URL = BaseUrl();
String baseUrl = BASE_URL.BASE_URL;

class YoutubeLiveVideoDetailsActivity extends StatefulWidget {
  final int videoID;

  const YoutubeLiveVideoDetailsActivity(this.videoID, {Key? key}) : super(key: key);

  @override
  State<YoutubeLiveVideoDetailsActivity> createState() => _YoutubeLiveVideoDetailsActivityState();
}

class _YoutubeLiveVideoDetailsActivityState extends State<YoutubeLiveVideoDetailsActivity> {
  int loadingState = 0;
  String? mobileToken;
  String myLanguage = 'en';
  String userID = '';
  String liveUrl = '';
  String liveDescriptionAr = '';
  String liveDescriptionEn = '';
  String isLive = '0';
  String nameAr = '';
  String nameEn = '';
  String date = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) setState(() => mobileToken = token);
    });
    await _getDataFromShared();
  }

  Future<String> _checkInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.none ? "0" : "1";
  }

  Future<void> _getDataFromShared() async {
    final prefs = await SharedPreferences.getInstance();
    myLanguage = prefs.getString('language') ?? "en";
    userID = prefs.getString("userID") ?? "";
    final connection = await _checkInternetConnection();
    if (connection == '1') {
      await _getYoutubeLiveVideoDetails();
    } else {
      if (!mounted) return;
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => NoInternetConnectionActivity()))
          .then((_) async {
        await _getYoutubeLiveVideoDetails();
      });
    }
  }

  Future<void> _getYoutubeLiveVideoDetails() async {
    setState(() => loadingState = 0);
    final response = await http.get(
      Uri.parse('$baseUrl/Booking/GetLiveCourseDetail/?UserAccountID=$userID&CourseID=${widget.videoID}'),
    );
    if (response.statusCode == 200) {
      final details = youtubeLiveVideoDetailsFromJson(response.body.toString());
      if (details.isNotEmpty) {
        final d = details[0];
        setState(() {
          loadingState = 1;
          liveUrl = d.liveUrl ?? '';
          liveDescriptionAr = d.liveDescriptionAr ?? '';
          liveDescriptionEn = d.liveDescriptionEn ?? '';
          isLive = d.isLive ?? '0';
          nameAr = d.nameAr ?? '';
          nameEn = d.nameEn ?? '';
          date = d.date ?? '';
        });
      } else {
        setState(() => loadingState = 3);
      }
    } else {
      setState(() => loadingState = 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: _buildChild(context, localizations),
    );
  }

  Widget _buildChild(BuildContext context, AppLocalizations? localizations) {
    if (loadingState == 0) {
      return _buildLoadingState();
    } else if (loadingState == 1) {
      return _buildContentState(localizations);
    } else if (loadingState == 2) {
      return _buildErrorState(localizations);
    } else {
      return _buildEmptyState(localizations);
    }
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SkeletonAnimation(
                child: Container(
                  color: Colors.grey[300],
                ),
              ),
            ),
          ),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonAnimation(
                  child: Container(
                    height: 32,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SkeletonAnimation(
                  child: Container(
                    height: 20,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SkeletonAnimation(
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentState(AppLocalizations? localizations) {
    final title = myLanguage == "en" ? liveDescriptionEn : liveDescriptionAr;
    final courseName = myLanguage == "en" ? nameEn : nameAr;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                if (liveUrl.isNotEmpty)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: YoutubeLiveVideo(liveUrl, isLive, true),
                  )
                else
                  Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 80,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                if (isLive == "1")
                  Positioned(
                    top: 60,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFDC2626).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            localizations?.liveBadge ?? "LIVE",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
              ),
              child: IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // Share functionality can be implemented here
                },
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.isNotEmpty ? title : courseName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                          fontFamily: 'cocon-next-arabic-regular',
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (courseName.isNotEmpty && title.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF3B82F6).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            courseName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'cocon-next-arabic-regular',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (date.isNotEmpty)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color(0xFF3B82F6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.schedule,
                                  color: Color(0xFF3B82F6),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localizations?.dateTime ?? "Date & Time",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      date,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF1F2937),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'cocon-next-arabic-regular',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        if (date.isNotEmpty)
                          const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isLive == "1"
                                    ? Color(0xFFDCFDF7)
                                    : Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isLive == "1" ? Icons.circle : Icons.play_circle,
                                color: isLive == "1"
                                    ? Color(0xFF059669)
                                    : Color(0xFF6B7280),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations?.status ?? "Status",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    isLive == "1"
                                        ? (localizations?.liveStreaming ?? "LIVE STREAMING")
                                        : (localizations?.recordedVideo ?? "RECORDED VIDEO"),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isLive == "1"
                                          ? Color(0xFF059669)
                                          : Color(0xFF6B7280),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'cocon-next-arabic-regular',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isLive == "1"
                                    ? Color(0xFFDCFDF7)
                                    : Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isLive == "1"
                                    ? (localizations?.live ?? "LIVE")
                                    : (localizations?.recorded ?? "RECORDED"),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isLive == "1"
                                      ? Color(0xFF059669)
                                      : Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Add to favorites functionality
                          },
                          icon: const Icon(Icons.favorite_border, size: 20),
                          label: Text(localizations?.addToFavorites ?? 'Add to Favorites'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF3B82F6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Color(0xFF3B82F6).withOpacity(0.3),
                              ),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Download or watch later functionality
                          },
                          icon: const Icon(Icons.download, size: 20),
                          label: Text(localizations?.download ?? 'Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(AppLocalizations? localizations) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Color(0xFFF8FAFC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFEF2F2),
                  border: Border.all(
                    color: Color(0xFFFECACA),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                localizations?.connectionError ?? "Connection Error",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  fontFamily: 'cocon-next-arabic-regular',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                localizations?.errorConnectingWithServer ??
                    "Unable to load video details.\nPlease check your internet connection and try again.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _getYoutubeLiveVideoDetails(),
                icon: const Icon(Icons.refresh, size: 20),
                label: Text(localizations?.tryAgain ?? 'Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations? localizations) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Color(0xFFF8FAFC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.live_tv_rounded,
                  size: 70,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                localizations?.videoNotFound ?? "Video Not Found",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  fontFamily: 'cocon-next-arabic-regular',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                localizations?.noVideosFound ??
                    "The video you're looking for doesn't exist or has been removed.\nPlease check back later or try another video.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, size: 20),
                label: Text(localizations?.goBack ?? 'Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
