import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'models/keep.dart';
import 'models/tag.dart';

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

  Future<Keep> getKeep(int id) async {
    final db = await database as Database;
    var res = await db.query("Keep", where: "id = ?", whereArgs: [id]);
    return Keep.fromJson(res.first);
  }

  Future<List<Keep>> getAllKeeps() async {
    final db = await database as Database;
    var res = await db.query("Keep");
    List<Keep> list =
        res.isNotEmpty ? res.map((c) => Keep.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> newKeep(Keep newKeep) async {
    final db = await database as Database;
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Keep");
    int id = table.first["id"] != null ? (table.first["id"] as int) : 0;
    var raw = await db.rawInsert(
        "INSERT Into Keep (id,title,text)"
        " VALUES (?,?,?)",
        [
          id,
          newKeep.title,
          newKeep.text,
        ]);
    return raw;
  }

  Future<int> updateKeep(Keep newKeep) async {
    final db = await database as Database;
    var res = await db.update("Keep", newKeep.toJson(),
        where: "id = ?", whereArgs: [newKeep.id]);
    return res;
  }

  deleteKeep(int id) async {
    final db = await database as Database;
    db.delete("Keep", where: "id = ?", whereArgs: [id]);
  }

  newTag(Tag newTag) async {
    final db = await database as Database;
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Tag");
    int id = table.first["id"] != null ? (table.first["id"] as int) : 0;
    var raw = await db.rawInsert(
        "INSERT Into Tag (id,keepId,text)"
        " VALUES (?,?,?)",
        [
          id,
          newTag.keepId,
          newTag.text,
        ]);
    return raw;
  }

  Future<int> updateTag(Tag newTag) async {
    final db = await database as Database;
    var res = await db.update("Tag", newTag.toJson(),
        where: "id = ?", whereArgs: [newTag.id]);
    return res;
  }

  Future<List<Tag>> getAllTagsForKeep(int keepId) async {
    final db = await database as Database;
    var res = await db.query("Tag", where: "keepId = ?", whereArgs: [keepId]);
    List<Tag> list =
        res.isNotEmpty ? res.map((c) => Tag.fromJson(c)).toList() : [];
    return list;
  }

  deleteTag(int id) async {
    final db = await database as Database;
    db.delete("Tag", where: "id = ?", whereArgs: [id]);
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //File a = File(documentsDirectory.path + "/sqlite.db");
    //a.delete();

    return await openDatabase(documentsDirectory.path + "/data.db",
        version: 1,
        onOpen: (db) {}, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Keep ("
          "id INTEGER PRIMARY KEY, "
          "title TEXT, "
          "text TEXT "
          ")");
      await db.execute("CREATE TABLE Tag ("
          "id INTEGER PRIMARY KEY, "
          "text TEXT, "
          "keepId INTEGER "
          ")");
    });
  }
}
