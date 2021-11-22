import 'package:flutter/material.dart';
import 'package:timer/models/phase.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'database.dart';
import 'main.dart';
import 'models/timer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewTimer extends StatefulWidget {
  NewTimer({Key? key, required this.title, required this.id}) : super(key: key);
  final String title;
  final int id;
  late MyTimer tempTimer;
  @override
  _NewTimerState createState() => _NewTimerState();
}

class _NewTimerState extends State<NewTimer> {
  Map<String, Phase> phases = <String, Phase>{};
  Map<String, TextEditingController> phaseControllers =
      <String, TextEditingController>{};
  ColorSwatch? _tempMainColor;
  Color? _tempShadeColor;
  ColorSwatch? _mainColor = Colors.blue;
  Color? _shadeColor = Colors.blue[800];

  void _openDialog(String title, Widget content) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(title),
          content: content,
          actions: [
            TextButton(
              child: Text('CANCEL'),
              onPressed: Navigator.of(context).pop,
            ),
            TextButton(
              child: Text('SUBMIT'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _mainColor = _tempMainColor;
                  widget.tempTimer.mcolor = _mainColor!.value;
                  _shadeColor = _tempShadeColor;
                  widget.tempTimer.scolor = _shadeColor!.value;
                  DBProvider.db.updateTimer(widget.tempTimer);
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _openColorPicker() async {
    _openDialog(
      "Color picker",
      MaterialColorPicker(
        selectedColor: _shadeColor,
        onColorChange: (color) => setState(() => _tempShadeColor = color),
        onMainColorChange: (color) => setState(() {
          _tempMainColor = color;
        }),
        onBack: () => print("Back button pressed"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        body: new Container(
            child: new SingleChildScrollView(
                child: Column(children: [
          FutureBuilder<MyTimer>(
            future: DBProvider.db.getTimer(widget.id),
            builder: (BuildContext context, AsyncSnapshot<MyTimer> snapshot) {
              if (snapshot.hasData) {
                widget.tempTimer = MyTimer(
                    id: widget.id,
                    title: snapshot.data!.title,
                    phaseDelay: snapshot.data!.phaseDelay,
                    repeatDelay: snapshot.data!.repeatDelay,
                    repeat: snapshot.data!.repeat,
                    mcolor: snapshot.data!.mcolor,
                    scolor: snapshot.data!.scolor);
                _shadeColor = new Color(widget.tempTimer.scolor);
                _mainColor = new MaterialColor(widget.tempTimer.mcolor, {});

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: CircleAvatar(
                              backgroundColor: _shadeColor,
                              radius: 35.0,
                            )),
                        OutlinedButton(
                          onPressed: _openColorPicker,
                          child:
                              Text(AppLocalizations.of(context)!.selectColor),
                        ),
                      ],
                    ),
                    Container(
                        padding: const EdgeInsets.all(20.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.title),
                          initialValue: widget.tempTimer.title,
                          onChanged: (text) {
                            setState(() {
                              widget.tempTimer.title = text;
                              DBProvider.db.updateTimer(widget.tempTimer);
                            });
                          },
                        )),
                    Container(
                        padding: const EdgeInsets.all(20.0),
                        child: TextFormField(
                            decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.phaseDelay),
                            keyboardType: TextInputType.number,
                            initialValue:
                                widget.tempTimer.phaseDelay.toString(),
                            onChanged: (text) {
                              setState(() {
                                widget.tempTimer.phaseDelay = int.parse(text);
                                DBProvider.db.updateTimer(widget.tempTimer);
                              });
                            })),
                    Container(
                        padding: const EdgeInsets.all(20.0),
                        child: TextFormField(
                            decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.repeatDelay),
                            keyboardType: TextInputType.number,
                            initialValue:
                                widget.tempTimer.repeatDelay.toString(),
                            onChanged: (text) {
                              setState(() {
                                widget.tempTimer.repeatDelay = int.parse(text);
                                DBProvider.db.updateTimer(widget.tempTimer);
                              });
                            })),
                    Container(
                        padding: const EdgeInsets.all(20.0),
                        child: TextFormField(
                            decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.repeats),
                            keyboardType: TextInputType.number,
                            initialValue: widget.tempTimer.repeat.toString(),
                            onChanged: (text) {
                              setState(() {
                                widget.tempTimer.repeat = int.parse(text);
                                DBProvider.db.updateTimer(widget.tempTimer);
                              });
                            })),
                  ],
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Container(
              padding: const EdgeInsets.all(20.0),
              child: FutureBuilder<List<Phase>>(
                  future: DBProvider.db.getAllPhasesForTimer(widget.id),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Phase>> snapshot) {
                    if (snapshot.hasData) {
                      var widgets = <Widget>[];
                      for (var item in snapshot.data as List<Phase>) {
                        phases[item.id.toString()] = item;
                        phaseControllers[item.id.toString()] =
                            TextEditingController(text: item.wait.toString());
                        widgets.add(Column(
                          children: [
                            Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 50, 0),
                                child: new ListTile(
                                  trailing: IconButton(
                                    onPressed: () {
                                      DBProvider.db.deletePhase(item.id);
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.delete_forever),
                                  ),
                                  title: TextFormField(
                                      decoration: InputDecoration(
                                          labelText:
                                              AppLocalizations.of(context)!
                                                  .phaseTitle),
                                      initialValue:
                                          phases[item.id.toString()]!.title,
                                      onChanged: (text) {
                                        setState(() {
                                          phases[item.id.toString()]!.title =
                                              text;
                                          DBProvider.db.updatePhase(
                                              (phases[item.id.toString()]
                                                  as Phase));
                                        });
                                      }),
                                )),
                            Container(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 20, 150, 0),
                                child: TextField(
                                    decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)!
                                            .phaseWait),
                                    keyboardType: TextInputType.number,
                                    controller:
                                        phaseControllers[item.id.toString()],
                                    onSubmitted: (text) {
                                      setState(() {
                                        phases[item.id.toString()]!.wait =
                                            int.parse(text);
                                        phaseControllers[item.id.toString()]!
                                            .text = text;
                                        DBProvider.db.updatePhase(
                                            (phases[item.id.toString()]
                                                as Phase));
                                      });
                                    })),
                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 10, 20, 10),
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      setState(() {
                                        if (phases[item.id.toString()]!.wait >
                                            0)
                                          phases[item.id.toString()]!.wait--;
                                        DBProvider.db.updatePhase(
                                            phases[item.id.toString()]
                                                as Phase);
                                      });
                                    },
                                    tooltip: 'decrement',
                                    child: Icon(Icons.remove),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      setState(() {
                                        var newPhase = item;
                                        newPhase.wait++;
                                        DBProvider.db.updatePhase(newPhase);
                                      });
                                    },
                                    tooltip: 'increment',
                                    child: Icon(Icons.add),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ));
                      }
                      return Column(children: widgets);
                    } else
                      return Center(child: CircularProgressIndicator());
                  })),
        ]))),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                DBProvider.db.deleteTimer(widget.id);

                Navigator.pop(context);
              },
              tooltip: 'delete timer',
              child: Icon(Icons.delete),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                tooltip: 'save timer',
                child: Icon(Icons.save),
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                var newPhase = new Phase(
                    id: 0, title: "title", wait: 1, timerId: widget.id);
                DBProvider.db.newPhase(newPhase);
                setState(() {});
              },
              tooltip: 'add phase',
              child: Icon(Icons.add),
            ),
          ],
        ));
  }
}
