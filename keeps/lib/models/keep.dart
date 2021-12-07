class Keep {
  Keep({required this.id, required this.title, required this.text});
  String title;
  String text;
  int id;

  factory Keep.fromJson(Map<String, dynamic> json) => Keep(
        id: json["id"],
        title: json["title"],
        text: json["text"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "text": text,
      };
}
