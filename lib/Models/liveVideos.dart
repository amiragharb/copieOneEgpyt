import 'dart:convert';

List<LiveVideos> liveVideosFromJson(String str) =>
    List<LiveVideos>.from(json.decode(str).map((x) => LiveVideos.fromJson(x)));

String liveVideosToJson(List<LiveVideos> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LiveVideos {
  LiveVideos({
    this.courseId,
    this.liveUrl,
    this.liveDescriptionAr,
    this.liveDescriptionEn,
    this.isLive,
    this.nameAr,
    this.nameEn,
    this.date,
  });

  final int? courseId;
  final String? liveUrl;
  final String? liveDescriptionAr;
  final String? liveDescriptionEn;
  final String? isLive;
  final String? nameAr;
  final String? nameEn;
  final String? date;

  factory LiveVideos.fromJson(Map<String, dynamic> json) => LiveVideos(
        courseId: json["CourseID"] as int?,
        liveUrl: json["LiveURL"] as String?,
        liveDescriptionAr: json["LiveDescriptionAr"] as String?,
        liveDescriptionEn: json["LiveDescriptionEn"] as String?,
        isLive: json["IsLive"] as String?,
        nameAr: json["NameAr"] as String?,
        nameEn: json["NameEn"] as String?,
        date: json["Date"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "CourseID": courseId,
        "LiveURL": liveUrl,
        "LiveDescriptionAr": liveDescriptionAr,
        "LiveDescriptionEn": liveDescriptionEn,
        "IsLive": isLive,
        "NameAr": nameAr,
        "NameEn": nameEn,
        "Date": date,
      };
}
