import 'package:flutter/material.dart';
import 'models/match.dart';
import 'database.dart';

class BetsFormWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BetsFormWidgetState();
  }
}

TextEditingController _textFieldController = TextEditingController();

class _BetsFormWidgetState extends State<BetsFormWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Column(
        children: <Widget>[
          FutureBuilder<List<Match>>(
              future: DBProvider.db.getAllMatchs(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Match>> snapshot) {
                if (snapshot.hasData) {
                  var listWidgets = <Widget>[];
                  listWidgets.add(new ListTile(title: _buildLogo()));
                  for (var item in snapshot.data!.toList()) {
                    var total = item.win + item.lose + item.draw;
                    listWidgets.add(new Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text(item.date + "   " + item.title),
                        subtitle: Text(item.comment),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('bet to win'),
                                    content: TextField(
                                      keyboardType: TextInputType.number,
                                      controller: _textFieldController,
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('CANCEL'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      FlatButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          item.win += int.parse(
                                              _textFieldController.text);
                                          DBProvider.db.updateMatch(item);

                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text((item.win == 0 ? 0 : total / item.win)
                                .toString()),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('bet to draw'),
                                    content: TextField(
                                      keyboardType: TextInputType.number,
                                      controller: _textFieldController,
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('CANCEL'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      FlatButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          item.draw += int.parse(
                                              _textFieldController.text);
                                          DBProvider.db.updateMatch(item);

                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text((item.draw == 0 ? 0 : total / item.draw)
                                .toString()),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('bet to lose'),
                                    content: TextField(
                                      keyboardType: TextInputType.number,
                                      controller: _textFieldController,
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('CANCEL'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      FlatButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          item.lose += int.parse(
                                              _textFieldController.text);
                                          DBProvider.db.updateMatch(item);

                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text((item.lose == 0 ? 0 : total / item.lose)
                                .toString()),
                          )
                        ]),
                      ),
                    ));
                  }
                  return Card(
                      elevation: 8,
                      child: Container(
                          height: MediaQuery.of(context).size.height - 30,
                          child: SingleChildScrollView(
                            child: Column(
                              children: listWidgets,
                            ),
                          )));
                } else
                  return Center(child: CircularProgressIndicator());
              }),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Image.asset(
        "images/ic_launcher.png",
        height: 100,
        width: 100,
      ),
    );
  }
}
