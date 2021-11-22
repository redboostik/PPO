class Phase {
  Phase({
    required this.id,
    required this.title,
    required this.wait,
    required this.timerId,
  });
  int timerId;
  int id;
  String title;
  int wait;

  factory Phase.fromJson(Map<String, dynamic> json) => Phase(
        id: json["id"],
        title: json["title"],
        wait: json["wait"],
        timerId: json["timerId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "wait": wait,
        "timerId": timerId,
      };
}
