import 'package:flutter/material.dart';
import 'package:timer/models/phase.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import 'database.dart';
import 'main.dart';
import 'models/timer.dart';
import 'package:flutter/services.dart';

class RunTimerPage extends StatefulWidget {
  RunTimerPage({Key? key, required this.title, required this.id})
      : super(key: key);

  final String title;
  final int id;

  @override
  _RunTimerPageState createState() => _RunTimerPageState();
}

class _RunTimerPageState extends State<RunTimerPage> {
  String phaseName = '';
  int time = 0;
  int phase = 0;
  int repeat = 0;
  late List<Phase> phases;
  late MyTimer timer;
  late Timer tim;
  bool isRun = false;
  bool phaseDelay = false;

  createBody() {
    return Scaffold(
        appBar: AppBar(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 0.09,
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: ValueListenableBuilder<double>(
                        valueListenable: MyApp.font2,
                        builder: (_, double font, __) {
                          return Text(widget.title,
                              style: TextStyle(
                                fontSize: font,
                              ));
                        })),
              ]),
        ),
        body: Column(
          children: [
            Align(
                alignment: Alignment.center,
                child: ValueListenableBuilder<double>(
                    valueListenable: MyApp.font2,
                    builder: (_, double font, __) {
                      return Text(
                        '$phaseName',
                        style: TextStyle(fontSize: font),
                      );
                    })),
            Align(
                alignment: Alignment.center,
                child: ValueListenableBuilder<double>(
                    valueListenable: MyApp.font3,
                    builder: (_, double font, __) {
                      return Text(
                        '$time',
                        style: TextStyle(fontSize: font),
                      );
                    })),
            Container(
                padding: EdgeInsets.fromLTRB(20, 40, 0, 20),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: ValueListenableBuilder<double>(
                        valueListenable: MyApp.font1,
                        builder: (_, double font, __) {
                          return Text(
                            AppLocalizations.of(context)!.repeats + ' $repeat',
                            style: TextStyle(fontSize: font),
                          );
                        }))),
            Container(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: FutureBuilder<List<Phase>>(
                        future: DBProvider.db.getAllPhasesForTimer(widget.id),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Phase>> snapshot) {
                          if (snapshot.hasData) {
                            var widgets = <Widget>[];
                            for (var item in snapshot.data as List<Phase>) {
                              widgets.add(Row(children: [
                                ValueListenableBuilder<double>(
                                    valueListenable: MyApp.font1,
                                    builder: (_, double font, __) {
                                      return Text(
                                        item.title +
                                            "  " +
                                            AppLocalizations.of(context)!
                                                .phaseWait +
                                            "  " +
                                            item.wait.toString(),
                                        style: TextStyle(fontSize: font),
                                      );
                                    }),
                              ]));
                            }
                            return Column(children: widgets);
                          } else
                            return Center(child: CircularProgressIndicator());
                        }))),
          ],
        ),
        floatingActionButton:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            onPressed: () {
              phase -= 1;
              if (phase == -1) phase = 0;
              time = 0;
            },
            child: Icon(Icons.skip_previous),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: FloatingActionButton(
              onPressed: () {
                if (!isRun) {
                  isRun = true;
                  tim = new Timer.periodic(Duration(seconds: 1), (Timer _tim) {
                    if (time <= 0) {
                      for (var i = 0; i < 50; i++) HapticFeedback.vibrate();

                      if (phase < phases.length) {
                        if (!phaseDelay) {
                          setState(() {
                            phaseName =
                                'delay before phase ' + phases[phase].title;
                            time = timer.phaseDelay;
                            phaseDelay = true;
                          });
                        } else {
                          setState(() {
                            phaseName = phases[phase].title;
                            time = phases[phase].wait;
                            phaseDelay = false;
                            phase++;
                          });
                        }
                      } else if (repeat < timer.repeat) {
                        setState(() {
                          repeat++;
                          phaseName = 'repeat delay';
                          phase = 0;

                          time = timer.repeatDelay;
                        });
                      } else
                        setState(() {
                          phaseName = timer.title;
                          phase = 0;
                          repeat = 0;
                          isRun = false;
                          _tim.cancel();
                        });
                    } else {
                      setState(() {
                        time--;
                      });
                    }
                  });
                }
              },
              child: Icon(Icons.play_arrow),
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              time = 0;
            },
            child: Icon(Icons.skip_next),
          ),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    DBProvider.db
        .getAllPhasesForTimer(widget.id)
        .then((value) => phases = value);
    return FutureBuilder<MyTimer>(
      future: DBProvider.db.getTimer(widget.id),
      builder: (BuildContext context, AsyncSnapshot<MyTimer> snapshot) {
        if (snapshot.hasData) {
          timer = snapshot.data as MyTimer;
          return FutureBuilder<List<Phase>>(
              future: DBProvider.db.getAllPhasesForTimer(widget.id),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Phase>> snapshot) {
                if (snapshot.hasData) {
                  phases = snapshot.data as List<Phase>;
                  return createBody();
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              });
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
