import 'dart:convert';

List<NewsCategory> newsCategoryFromJson(String str) =>
    List<NewsCategory>.from(json.decode(str).map((x) => NewsCategory.fromJson(x)));

String newsCategoryToJson(List<NewsCategory> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NewsCategory {
  NewsCategory({
    this.id,
    this.name,
    this.isSelected,
  });

  int? id;
  String? name;
  bool? isSelected;

  factory NewsCategory.fromJson(Map<String, dynamic> json) => NewsCategory(
        id: json["ID"],
        name: json["Name"],
        isSelected: json["IsSelected"],
      );

  Map<String, dynamic> toJson() => {
        "ID": id,
        "Name": name,
        "IsSelected": isSelected,
      };
}
