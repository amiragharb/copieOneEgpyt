import 'dart:convert';

class News {
  News({
    this.newsId,
    this.subject,
    this.date,
    this.churchName,
    this.byUser,
    this.newsCategoryId,
    this.newsCategoryName,
    this.description,
    this.youtubeUrl,
    this.coverFileUrl,
    this.creatorUserId,
    this.time1,
    this.date2,
    this.isSeen,
    this.coverFileName,
  });

  int? newsId;
  String? subject;
  String? date;
  String? churchName;
  String? byUser;
  int? newsCategoryId;
  String? newsCategoryName;
  String? description;
  String? youtubeUrl;
  String? coverFileUrl;
  String? creatorUserId;
  String? time1;
  String? date2;
  String? isSeen;
  String? coverFileName;

  factory News.fromJson(Map<String, dynamic> json) => News(
        newsId: json["NewsID"],
        subject: json["Subject"],
        date: json["Date"],
        churchName: json["ChurchName"],
        byUser: json["ByUser"],
        newsCategoryId: json["NewsCategoryID"],
        newsCategoryName: json["NewsCategoryName"],
        description: json["Description"],
        youtubeUrl: json["YoutubeUrl"],
        coverFileUrl: json["CoverFileUrl"],
        creatorUserId: json["CreatorUserID"],
        time1: json["Time1"],
        date2: json["Date2"],
        isSeen: json["IsSeen"],
        coverFileName: json["CoverFileName"],
      );

  Map<String, dynamic> toJson() => {
        "NewsID": newsId,
        "Subject": subject,
        "Date": date,
        "ChurchName": churchName,
        "ByUser": byUser,
        "NewsCategoryID": newsCategoryId,
        "NewsCategoryName": newsCategoryName,
        "Description": description,
        "YoutubeUrl": youtubeUrl,
        "CoverFileUrl": coverFileUrl,
        "CreatorUserID": creatorUserId,
        "Time1": time1,
        "Date2": date2,
        "IsSeen": isSeen,
        "CoverFileName": coverFileName,
      };
}

List<News> newsFromJson(String str) =>
    List<News>.from(json.decode(str).map((x) => News.fromJson(x)));

String newsToJson(List<News> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
