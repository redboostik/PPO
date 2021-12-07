class Tag {
  Tag({required this.id, required this.keepId, required this.text});
  String text;
  int id;
  int keepId;

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json["id"],
        keepId: json["keepId"],
        text: json["text"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "keepId": keepId,
        "text": text,
      };
}
