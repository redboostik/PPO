class Match {
  Match(
      {required this.id,
      required this.userId,
      required this.title,
      required this.comment,
      required this.date,
      required this.win,
      required this.draw,
      required this.lose});
  String title;
  int userId;
  int win;
  int draw;
  int lose;
  String comment;
  String date;
  int id;

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        id: json["id"],
        userId: json["userId"],
        title: json["title"],
        comment: json["comment"],
        date: json["date"],
        win: json["win"],
        draw: json["draw"],
        lose: json["lose"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "id": id,
        "title": title,
        "comment": comment,
        "date": date,
        "win": win,
        "draw": draw,
        "lose": lose,
      };
}
