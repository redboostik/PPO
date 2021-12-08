class Feed {
  Feed(
      {required this.id,
      required this.title,
      required this.icon,
      required this.link});
  String title;
  String icon;
  String link;
  int id;
  factory Feed.fromJson(Map<String, dynamic> json) => Feed(
        id: json["id"],
        title: json["title"],
        icon: json["icon"],
        link: json["link"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "icon": icon,
        "link": link,
      };
}
