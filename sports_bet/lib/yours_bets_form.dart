import 'package:flutter/material.dart';
import 'package:sports_bet/edit_match.dart';
import 'package:sports_bet/tempData.dart';
import 'models/match.dart';
import 'database.dart';

class YoursBetsFormWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _YoursBetsFormWidgetState();
  }
}

class _YoursBetsFormWidgetState extends State<YoursBetsFormWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
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
                        onTap: () {
                          TempData.match = item;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => new EditMatchScreen()));
                        },
                        title: Text(item.date + "   " + item.title),
                        subtitle: Text(item.comment),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          TextButton(
                            onPressed: () {},
                            child: Text((item.win == 0 ? 0 : total / item.win)
                                .toString()),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text((item.draw == 0 ? 0 : total / item.draw)
                                .toString()),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text((item.lose == 0 ? 0 : total / item.lose)
                                .toString()),
                          ),
                          IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Choose result'),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text('win'),
                                          onPressed: () {
                                            DBProvider.db.deleteMatch(item.id);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        FlatButton(
                                          child: Text('draw'),
                                          onPressed: () {
                                            DBProvider.db.deleteMatch(item.id);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        FlatButton(
                                          child: Text('lose'),
                                          onPressed: () {
                                            DBProvider.db.deleteMatch(item.id);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(Icons.check))
                        ]),
                      ),
                    ));
                  }
                  listWidgets.add(new FloatingActionButton(
                    onPressed: () {
                      DBProvider.db.newMatch(new Match(
                          id: 0,
                          userId: TempData.userId,
                          title: "Title",
                          comment: "comment",
                          date: "xx.xx",
                          win: 0,
                          draw: 0,
                          lose: 0));
                    },
                    tooltip: 'Increment',
                    child: Icon(Icons.add),
                  ));
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
