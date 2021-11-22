class SettingModel {
  SettingModel({
    required this.id,
    required this.title,
    required this.value,
  });
  int value;
  int id;
  String title;

  factory SettingModel.fromJson(Map<String, dynamic> json) => SettingModel(
        id: json["id"],
        title: json["title"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "value": value,
      };
}
