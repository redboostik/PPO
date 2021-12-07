import 'package:flutter/material.dart';
import 'package:keeps/datebase.dart';
import 'package:keeps/models/keep.dart';

import 'keep_page.dart';
import 'models/tag.dart';

class PortraitMode extends StatefulWidget {
  PortraitMode({Key? key}) : super(key: key);
  @override
  _PortraitModeState createState() => _PortraitModeState();
}

class _PortraitModeState extends State<PortraitMode> {
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
              sortValue.value
                  ? data.sort((a, b) => a.title.compareTo(b.title))
                  : data.sort((a, b) => a.id.compareTo(b.id));

              data = sortType.value ? data : snapshot.data!.reversed.toList();
              return new ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  Keep item = data[index];
                  return new SingleChildScrollView(
                      child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                              margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: FutureBuilder<List<Tag>>(
                                  future:
                                      DBProvider.db.getAllTagsForKeep(item.id),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<List<Tag>> snapshot) {
                                    if (snapshot.hasData) {
                                      String tags = '';
                                      for (Tag tag in snapshot.data!) {
                                        tags += tag.text + ', ';
                                      }
                                      if (tags.isNotEmpty)
                                        tags =
                                            tags.substring(0, tags.length - 2);
                                      return searchValue.value == '' ||
                                              tags.contains(searchValue.value)
                                          ? Column(
                                              children: [
                                                Text(tags,
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    )),
                                                Container(
                                                    margin: EdgeInsets.fromLTRB(
                                                        0, 10, 0, 20),
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20))),
                                                    child: InkWell(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    new KeepPage(
                                                                        keepId:
                                                                            item.id)),
                                                          ).then((value) =>
                                                              setState(() {}));
                                                        },
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                                margin: EdgeInsets
                                                                    .fromLTRB(
                                                                        0,
                                                                        0,
                                                                        0,
                                                                        10),
                                                                child: Text(
                                                                  item.title,
                                                                )),
                                                            Container(
                                                                margin: EdgeInsets
                                                                    .fromLTRB(
                                                                        0,
                                                                        0,
                                                                        0,
                                                                        10),
                                                                child: Text(
                                                                  item.text.length >
                                                                          200
                                                                      ? item.text.substring(
                                                                              0,
                                                                              200) +
                                                                          "..."
                                                                      : item
                                                                          .text,
                                                                ))
                                                          ],
                                                        ))),
                                              ],
                                            )
                                          : Column();
                                    } else
                                      return Center(
                                          child: CircularProgressIndicator());
                                  })),
                        ],
                      )
                    ],
                  ));
                },
              );
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
