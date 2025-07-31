// To parse this JSON data, do
//
//     final newsDetails = newsDetailsFromJson(jsonString);

import 'dart:convert';

// JSON decode helpers
List<NewsDetails> newsDetailsFromJson(String str) =>
    List<NewsDetails>.from(json.decode(str).map((x) => NewsDetails.fromJson(x)));

String newsDetailsToJson(List<NewsDetails> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NewsDetails {
  NewsDetails({
    this.newsId,
    this.subject,
    this.description,
    this.creatorUserId,
    this.byUser,
    this.churchName,
    this.time1,
    this.date2,
    this.date,
    this.isSeen,
    this.newsCategoryId,
    this.newsCategoryName,
    this.youtubeUrl,
    this.coverFileName,
    this.coverFileUrl,
    this.newsFiles,
  });

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

  factory NewsDetails.fromJson(Map<String, dynamic> json) => NewsDetails(
        newsId: json["NewsID"],
        subject: json["Subject"],
        description: json["Description"],
        creatorUserId: json["CreatorUserID"],
        byUser: json["ByUser"],
        churchName: json["ChurchName"],
        time1: json["Time1"],
        date2: json["Date2"],
        date: json["Date"],
        isSeen: json["IsSeen"],
        newsCategoryId: json["NewsCategoryID"],
        newsCategoryName: json["NewsCategoryName"],
        youtubeUrl: json["YoutubeURL"],
        coverFileName: json["CoverFileName"],
        coverFileUrl: json["CoverFileURL"],
        newsFiles: json["NewsFiles"] == null
            ? []
            : List<NewsFile>.from(json["NewsFiles"].map((x) => NewsFile.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "NewsID": newsId,
        "Subject": subject,
        "Description": description,
        "CreatorUserID": creatorUserId,
        "ByUser": byUser,
        "ChurchName": churchName,
        "Time1": time1,
        "Date2": date2,
        "Date": date,
        "IsSeen": isSeen,
        "NewsCategoryID": newsCategoryId,
        "NewsCategoryName": newsCategoryName,
        "YoutubeURL": youtubeUrl,
        "CoverFileName": coverFileName,
        "CoverFileURL": coverFileUrl,
        "NewsFiles": newsFiles == null
            ? []
            : List<dynamic>.from(newsFiles!.map((x) => x.toJson())),
      };
}

class NewsFile {
  NewsFile({
    this.newsFileId,
    this.fileUrl,
    this.fileName,
    this.youtubeUrl,
    this.description,
  });

  int? newsFileId;
  String? fileUrl;
  String? fileName;
  String? youtubeUrl;
  String? description;

  factory NewsFile.fromJson(Map<String, dynamic> json) => NewsFile(
        newsFileId: json["NewsFileID"],
        fileUrl: json["FileURL"],
        fileName: json["FileName"],
        youtubeUrl: json["YoutubeURL"],
        description: json["Description"],
      );

  Map<String, dynamic> toJson() => {
        "NewsFileID": newsFileId,
        "FileURL": fileUrl,
        "FileName": fileName,
        "YoutubeURL": youtubeUrl,
        "Description": description,
      };
}
