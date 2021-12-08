import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'models/Feed.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  Future<List<Feed>> getAllFeeds() async {
    final db = await database as Database;
    var res = await db.query("Feed");
    List<Feed> list =
        res.isNotEmpty ? res.map((c) => Feed.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> newFeed(Feed newFeed) async {
    final db = await database as Database;
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Feed");
    int id = table.first["id"] != null ? (table.first["id"] as int) : 0;
    var raw = await db.rawInsert(
        "INSERT Into Feed (id,title,link,icon)"
        " VALUES (?,?,?,?)",
        [
          id,
          newFeed.title,
          newFeed.link,
          newFeed.icon,
        ]);
    return raw;
  }

  deleteAllFeed() async {
    final db = await database as Database;
    db.delete("Feed");
  }

  Future<int> updateUrl(String url) async {
    final db = await database as Database;
    var res = await db.update("Url", {'id': 0, 'url': url}, where: "id = 0");
    return res;
  }

  Future<String> getUrl() async {
    final db = await database as Database;
    var res = await db.query("Url");

    return res[0]['url'] as String;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //File a = File(documentsDirectory.path + "/sqlite.db");
    //a.delete();

    return await openDatabase(documentsDirectory.path + "/sqlitedb.db",
        version: 1,
        onOpen: (db) {}, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Feed ("
          "id INTEGER PRIMARY KEY, "
          "title TEXT, "
          "link TEXT, "
          "icon TEXT "
          ")");
      await db.execute("CREATE TABLE Url ("
          "id INTEGER PRIMARY KEY, "
          "url TEXT "
          ")");
      await db.rawInsert(
          "INSERT Into Url (id,url)"
          " VALUES (?,?)",
          [0, 'https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss']);
    });
  }
}
