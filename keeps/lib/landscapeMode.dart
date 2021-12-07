import 'package:flutter/material.dart';
import 'package:keeps/datebase.dart';
import 'package:keeps/models/keep.dart';

import 'keep_page.dart';
import 'models/tag.dart';

class LandscapeMode extends StatefulWidget {
  LandscapeMode({Key? key}) : super(key: key);
  @override
  _LandscapeModeState createState() => _LandscapeModeState();
}

class _LandscapeModeState extends State<LandscapeMode> {
  static final ValueNotifier<bool> sortType = ValueNotifier(false);
  static final ValueNotifier<bool> sortValue = ValueNotifier(false);
  static final ValueNotifier<String> searchValue = ValueNotifier('');
  void genPort() {
    return;
  }

  void genLand() {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: TextFormField(
            decoration: InputDecoration(labelText: "Search"),
            initialValue: '',
            onChanged: (text) {
              setState(() {
                searchValue.value = text;
              });
            },
          ),
        ),
        actions: [
          IconButton(
            icon: sortType.value
                ? Icon(Icons.south_rounded)
                : Icon(Icons.north_rounded),
            onPressed: () {
              setState(() {
                sortType.value = !sortType.value;
              });
            },
          ),
          IconButton(
            icon: sortValue.value
                ? Icon(Icons.sort_by_alpha)
                : Icon(Icons.date_range),
            onPressed: () {
              setState(() {
                sortValue.value = !sortValue.value;
              });
            },
          )
        ],
      ),
      body: FutureBuilder<List<Keep>>(
          future: DBProvider.db.getAllKeeps(),
          builder: (BuildContext context, AsyncSnapshot<List<Keep>> snapshot) {
            if (snapshot.hasData) {
              List<Keep> data = snapshot.data!;
              List<Keep> dataLeft = [];
              List<Keep> dataRight = [];
              sortValue.value
                  ? data.sort((a, b) => a.title.compareTo(b.title))
                  : data.sort((a, b) => a.id.compareTo(b.id));
              data = sortType.value ? data : snapshot.data!.reversed.toList();
              bool left = true;
              for (var item in data) {
                left ? dataLeft.add(item) : dataRight.add(item);
                left = !left;
              }
              var widgetLeft = <Widget>[];
              var widgetRight = <Widget>[];

              for (var leftItem in dataLeft) {
                widgetLeft.add(Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    width: MediaQuery.of(context).size.width * 0.40,
                    child: FutureBuilder<List<Tag>>(
                        future: DBProvider.db.getAllTagsForKeep(leftItem.id),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Tag>> snapshot) {
                          if (snapshot.hasData) {
                            String tags = '';
                            for (Tag tag in snapshot.data!) {
                              tags += tag.text + ', ';
                            }
                            if (tags.isNotEmpty)
                              tags = tags.substring(0, tags.length - 2);
                            return (searchValue.value == '' ||
                                    tags.contains(searchValue.value))
                                ? Column(
                                    children: [
                                      Text(tags,
                                          style: TextStyle(
                                            color: Colors.grey,
                                          )),
                                      Container(
                                          margin:
                                              EdgeInsets.fromLTRB(0, 10, 0, 20),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                          child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          new KeepPage(
                                                              keepId:
                                                                  leftItem.id)),
                                                ).then(
                                                    (value) => setState(() {}));
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              0, 0, 0, 10),
                                                      child: Text(
                                                        leftItem.title,
                                                      )),
                                                  Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              0, 0, 0, 10),
                                                      child: Text(
                                                        leftItem.text.length >
                                                                200
                                                            ? leftItem.text
                                                                    .substring(
                                                                        0,
                                                                        200) +
                                                                "..."
                                                            : leftItem.text,
                                                      ))
                                                ],
                                              ))),
                                    ],
                                  )
                                : Column();
                          } else
                            return Center(child: CircularProgressIndicator());
                        })));
              }
              for (var rightItem in dataRight) {
                widgetRight.add(Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    width: MediaQuery.of(context).size.width * 0.40,
                    child: FutureBuilder<List<Tag>>(
                        future: DBProvider.db.getAllTagsForKeep(rightItem.id),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Tag>> snapshot) {
                          if (snapshot.hasData) {
                            String tags = '';
                            for (Tag tag in snapshot.data!) {
                              tags += tag.text + ', ';
                            }
                            if (tags.isNotEmpty)
                              tags = tags.substring(0, tags.length - 2);
                            return (searchValue.value == '' ||
                                    tags.contains(searchValue.value))
                                ? Column(
                                    children: [
                                      Text(tags,
                                          style: TextStyle(
                                            color: Colors.grey,
                                          )),
                                      Container(
                                          margin:
                                              EdgeInsets.fromLTRB(0, 10, 0, 20),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                          child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          new KeepPage(
                                                              keepId: rightItem
                                                                  .id)),
                                                ).then(
                                                    (value) => setState(() {}));
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              0, 0, 0, 10),
                                                      child: Text(
                                                        rightItem.title,
                                                      )),
                                                  Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              0, 0, 0, 10),
                                                      child: Text(
                                                        rightItem.text.length >
                                                                200
                                                            ? rightItem.text
                                                                    .substring(
                                                                        0,
                                                                        200) +
                                                                "..."
                                                            : rightItem.text,
                                                      ))
                                                ],
                                              ))),
                                    ],
                                  )
                                : Column();
                          } else
                            return Center(child: CircularProgressIndicator());
                        })));
              }
              return new SingleChildScrollView(
                  child: Row(
                children: [
                  Column(
                    children: widgetLeft,
                  ),
                  Column(
                    children: widgetRight,
                  )
                ],
              ));
            } else
              return Center(child: CircularProgressIndicator());
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          DBProvider.db
              .newKeep(new Keep(id: 1, title: "title", text: "text"))
              .then((value) => setState(() {}));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
