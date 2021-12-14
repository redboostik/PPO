import 'package:flutter/material.dart';
import 'package:keeps/models/keep.dart';

import 'datebase.dart';
import 'models/tag.dart';

class KeepPage extends StatefulWidget {
  KeepPage({
    Key? key,
    required this.keepId,
  }) : super(key: key);

  final int keepId;
  late List<Tag> tags;
  late Keep keep;
  @override
  _KeepPageState createState() => _KeepPageState();
}

class _KeepPageState extends State<KeepPage> {
  Map<String, Tag> tags = <String, Tag>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                DBProvider.db.deleteKeep(widget.keepId);
                Navigator.pop(context);
              },
              icon: Icon(Icons.delete))
        ],
      ),
      body: new SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          FutureBuilder<List<Tag>>(
              future: DBProvider.db.getAllTagsForKeep(widget.keepId),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Tag>> snapshot) {
                if (snapshot.hasData) {
                  tags = <String, Tag>{};
                  for (var item in snapshot.data as List<Tag>) {
                    tags[item.id.toString()] = item;
                  }
                  return new Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          border: Border.all(),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          Tag item = snapshot.data![index];
                          return new ListTile(
                            trailing: IconButton(
                              onPressed: () {
                                setState(() {
                                  DBProvider.db
                                      .deleteTag(tags[item.id.toString()]!.id);
                                });
                              },
                              icon: Icon(Icons.delete_forever),
                            ),
                            title: TextFormField(
                                decoration: InputDecoration(labelText: "tag"),
                                initialValue: tags[item.id.toString()]!.text,
                                onChanged: (text) {
                                  setState(() {
                                    tags[item.id.toString()]!.text = text;
                                    DBProvider.db.updateTag(
                                        (tags[item.id.toString()] as Tag));
                                  });
                                }),
                          );
                        },
                      ));
                } else
                  return Center(child: CircularProgressIndicator());
              }),
          FutureBuilder<Keep>(
              future: DBProvider.db.getKeep(widget.keepId),
              builder: (BuildContext context, AsyncSnapshot<Keep> snapshot) {
                if (snapshot.hasData) {
                  widget.keep = snapshot.data!;
                  return Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Container(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              border: Border.all(),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Column(
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                initialValue: widget.keep.title,
                                decoration: InputDecoration(
                                  hintText: "Title",
                                ),
                                onChanged: (text) {
                                  setState(() {
                                    widget.keep.title = text;
                                    DBProvider.db.updateKeep(widget.keep);
                                  });
                                },
                              ),
                              TextFormField(
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                initialValue: widget.keep.text,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Text",
                                ),
                                onChanged: (text) {
                                  setState(() {
                                    widget.keep.text = text;
                                    DBProvider.db.updateKeep(widget.keep);
                                  });
                                },
                              ),
                            ],
                          )));
                } else
                  return Center(child: CircularProgressIndicator());
              }),
        ],
      )),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          tags.length < 3
              ? DBProvider.db
                  .newTag(new Tag(id: 1, keepId: widget.keepId, text: "tag"))
                  .then(setState(() {}))
              : 2;
        },
        tooltip: 'add tag',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
