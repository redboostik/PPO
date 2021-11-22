import 'phase.dart';

class MyTimer {
  MyTimer({
    required this.id,
    required this.title,
    required this.phaseDelay,
    required this.repeatDelay,
    required this.repeat,
    required this.mcolor,
    required this.scolor,
  });

  int id;
  String title;
  int phaseDelay;
  int repeatDelay;
  int repeat;
  int mcolor;
  int scolor;

  factory MyTimer.fromJson(Map<String, dynamic> json) => MyTimer(
        id: json["id"],
        title: json["title"],
        phaseDelay: json["phaseDelay"],
        repeatDelay: json["repeatDelay"],
        repeat: json["repeat"],
        mcolor: json["mcolor"],
        scolor: json["scolor"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "phaseDelay": phaseDelay,
        "repeatDelay": repeatDelay,
        "repeat": repeat,
        "mcolor": mcolor,
        "scolor": scolor,
      };
}
