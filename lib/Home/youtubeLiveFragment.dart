import 'dart:async';
import 'package:egpycopsversion4/API/apiClient.dart';
import 'package:egpycopsversion4/Home/youtubeLiveVideo.dart';
import 'package:egpycopsversion4/Home/youtubeLiveVideoDetailsActivity.dart';
import 'package:egpycopsversion4/Models/liveVideos.dart';
import 'package:egpycopsversion4/NetworkConnectivity/noNetworkConnectionActivity.dart';
import 'package:egpycopsversion4/l10n/app_localizations.dart'; // <-- ici !
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:skeleton_text/skeleton_text.dart';

BaseUrl BASE_URL = BaseUrl();
String baseUrl = BASE_URL.BASE_URL;

class YoutubeLiveFragment extends StatefulWidget {
  const YoutubeLiveFragment({Key? key}) : super(key: key);

  @override
  State<YoutubeLiveFragment> createState() => _YoutubeLiveFragmentState();
}

class _YoutubeLiveFragmentState extends State<YoutubeLiveFragment> {
  String myLanguage = "en";
  int loadingState = 0; // 0=loading, 1=loaded, 2=error, 3=empty
  bool stopLoadingData = false;
  bool isFetching = false;
  int page = 0;

  String userID = "";
  String? mobileToken;
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> listViewLiveVideos = [];

  @override
  void initState() {
    super.initState();
    listViewLiveVideos.clear();
    _fetchMobileToken();
    _getDataFromShared();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
        !stopLoadingData &&
        !isFetching &&
        loadingState == 1) {
      _getDataFromShared();
    }
  }

  Future<void> _fetchMobileToken() async {
    mobileToken = await FirebaseMessaging.instance.getToken();
    debugPrint(mobileToken == null || mobileToken!.isEmpty
        ? "⚠️ mobileToken non récupéré"
        : "📱 Token: $mobileToken");
  }

  Future<String> _checkInternetConnection() async {
    var result = await Connectivity().checkConnectivity();
    return result == ConnectivityResult.none ? "0" : "1";
  }

  Future<void> _getDataFromShared() async {
    if (isFetching) return;
    isFetching = true;

    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        myLanguage = prefs.getString('language') ?? "en";
        userID = prefs.getString("userID") ?? "";
      });
    }

    final fetched = await _getLiveVideos();
    if (mounted && loadingState == 1 && fetched.isNotEmpty) {
      _liveVideosListViewData(fetched);
      page++;
    }

    isFetching = false;
  }

  Future<List<LiveVideos>> _getLiveVideos() async {
    final uri = Uri.parse(
        '$baseUrl/Booking/GetLiveCourses/?UserAccountID=$userID&Token=${mobileToken ?? ""}&page=$page');
    final response = await http.get(uri);

    if (!mounted) return [];

    if (response.statusCode == 200) {
      if (response.body == "[]" || response.body.isEmpty) {
        setState(() {
          stopLoadingData = true;
          if (page == 0) loadingState = 3;
        });
        return [];
      } else {
        setState(() {
          stopLoadingData = false;
          loadingState = 1;
        });
        return liveVideosFromJson(response.body);
      }
    } else {
      setState(() {
        loadingState = 2;
        stopLoadingData = true;
      });
      return [];
    }
  }

  void _liveVideosListViewData(List<LiveVideos> fetched) {
    if (!mounted) return;
    setState(() {
      for (final video in fetched) {
        final liveUrl = video.liveUrl ?? '';
        if (liveUrl.isNotEmpty && 
            RegExp(r'youtu(\.be|be\.com)', caseSensitive: false).hasMatch(liveUrl)) {
          String isLive = "0";
          final rawIsLive = video.isLive;

          if (rawIsLive is bool) {
            isLive = rawIsLive == true ? "1" : "0";
          } else if (rawIsLive != null) {
            final s = rawIsLive.toString().toLowerCase();
            isLive = (s == 'true' || s == '1') ? "1" : "0";
          }

          if (!listViewLiveVideos.any((e) => e["courseId"] == video.courseId) &&
              video.courseId != null) {
            listViewLiveVideos.add({
              "courseId": video.courseId,
              "nameAr": video.nameAr ?? "",
              "nameEn": video.nameEn ?? "",
              "liveDescriptionAr": video.liveDescriptionAr ?? "",
              "liveDescriptionEn": video.liveDescriptionEn ?? "",
              "liveUrl": liveUrl,
              "isLive": isLive,
              "date": video.date ?? "",
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Modern Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xB30D2138), Color(0xB30A1C31)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.live_tv_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations?.live ?? "Live",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'cocon-next-arabic-regular',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizations?.watchLiveSubtitle ?? "Watch live streams and courses",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.circle,
                      color: Colors.red,
                      size: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: _buildListViewChild(localizations)),
        ],
      ),
    );
  }

  Widget _buildListViewChild(AppLocalizations? localizations) {
    if (loadingState == 0) {
      return _buildLoadingState();
    } else if (loadingState == 1) {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: listViewLiveVideos.length,
        itemBuilder: (context, index) {
          final video = listViewLiveVideos[index];

          final liveUrl = (video["liveUrl"] as String?) ?? "";
          final isLive = (video["isLive"] as String?) ?? "0";
          final desc = myLanguage == "en"
              ? ((video["liveDescriptionEn"] as String?) ?? "")
              : ((video["liveDescriptionAr"] as String?) ?? "");
          final name = myLanguage == "en"
              ? ((video["nameEn"] as String?) ?? "")
              : ((video["nameAr"] as String?) ?? "");
          final date = (video["date"] as String?) ?? "";
          final courseIdRaw = video["courseId"];

          int? courseId;
          if (courseIdRaw is int) {
            courseId = courseIdRaw;
          } else if (courseIdRaw is String) {
            courseId = int.tryParse(courseIdRaw);
          } else if (courseIdRaw != null) {
            courseId = int.tryParse(courseIdRaw.toString());
          }

          if (liveUrl.isEmpty || courseId == null) {
            return const SizedBox.shrink();
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                try {
                  if (courseId == null) return;

                  if (await _checkInternetConnection() == '1') {
                    final selectedVideo = listViewLiveVideos[index];

                    setState(() {
                      listViewLiveVideos.removeAt(index);
                    });

                    await Future.delayed(const Duration(milliseconds: 300));

                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => YoutubeLiveVideoDetailsActivity(courseId!),
                      ),
                    );

                    setState(() {
                      listViewLiveVideos.insert(index, selectedVideo);
                    });
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => NoInternetConnectionActivity()),
                    );
                  }
                } catch (e) {
                  debugPrint("❗️Navigation error: $e");
                }
              },

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Builder(
                                builder: (context) {
                                  try {
                                    return YoutubeLiveVideo(liveUrl, isLive, false);
                                  } catch (e) {
                                    debugPrint("❗️Error loading YouTube video: $e");
                                    return Container(
                                      color: Colors.grey[300],
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.video_library_outlined,
                                            color: Colors.grey,
                                            size: 48,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            localizations?.videoLoadFailed ?? 'Video loading failed',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                              Container(
                                color: Colors.transparent,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isLive == "1")
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
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
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  localizations?.liveBadge ?? 'LIVE',
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
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.95),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isLive == "1" ? Icons.visibility : Icons.play_arrow,
                                    color: const Color(0xFF1E3A8A),
                                    size: 35,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isLive == "1"
                                      ? (localizations?.watchLive ?? 'Watch Live')
                                      : (localizations?.playVideo ?? 'Play Video'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          desc.isNotEmpty ? desc : name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                            fontFamily: 'cocon-next-arabic-regular',
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        if (name.isNotEmpty && desc.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF3B82F6).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3B82F6),
                                fontFamily: 'cocon-next-arabic-regular',
                              ),
                            ),
                          ),
                        if (name.isNotEmpty && desc.isNotEmpty)
                          const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 16,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                date.isNotEmpty
                                  ? date
                                  : (localizations?.noDateAvailable ?? "No date available"),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                  fontFamily: 'cocon-next-arabic-regular',
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isLive == "1"
                                    ? const Color(0xFFDCFDF7)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isLive == "1"
                                  ? (localizations?.streaming ?? "STREAMING")
                                  : (localizations?.recorded ?? "RECORDED"),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isLive == "1"
                                      ? const Color(0xFF059669)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (loadingState == 2) {
      return _buildErrorState(localizations);
    } else {
      return _buildEmptyState(localizations);
    }
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonAnimation(
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: Colors.grey[300],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonAnimation(
                      child: Container(
                        height: 24,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SkeletonAnimation(
                      child: Container(
                        height: 24,
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SkeletonAnimation(
                      child: Container(
                        height: 28,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SkeletonAnimation(
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SkeletonAnimation(
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[300],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SkeletonAnimation(
                          child: Container(
                            width: 80,
                            height: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(AppLocalizations? localizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFEF2F2),
                border: Border.all(
                  color: const Color(0xFFFECACA),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 50,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizations?.connectionErrorTitle ?? "Connection Error",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                fontFamily: 'cocon-next-arabic-regular',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations?.errorConnectingWithServer ??
                  "Unable to connect with the server.\nPlease check your internet connection and try again.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  loadingState = 0;
                  page = 0;
                  stopLoadingData = false;
                });
                _getDataFromShared();
              },
              icon: const Icon(Icons.refresh, size: 20),
              label: Text(localizations?.retry ?? 'Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations? localizations) {
    return Center(
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
                gradient: const LinearGradient(
                  colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.live_tv_rounded,
                size: 60,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizations?.noVideosFoundTitle ?? "No Live Videos",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                fontFamily: 'cocon-next-arabic-regular',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations?.noVideosFound ??
                  "No live videos or courses are available at the moment.\nCheck back later for new content.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  loadingState = 0;
                  page = 0;
                  stopLoadingData = false;
                });
                _getDataFromShared();
              },
              icon: const Icon(Icons.refresh, size: 20),
              label: Text(localizations?.refresh ?? 'Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
