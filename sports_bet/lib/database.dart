import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'models/match.dart';
import 'models/user.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  Future<Match> getMatch(int id) async {
    final db = await database as Database;
    var res = await db.query("Match", where: "id = ?", whereArgs: [id]);
    return Match.fromJson(res.first);
  }

  Future<List<Match>> getAllMatchs() async {
    final db = await database as Database;
    var res = await db.query("Match");
    List<Match> list =
        res.isNotEmpty ? res.map((c) => Match.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> newMatch(Match newMatch) async {
    final db = await database as Database;
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Match");
    int id = table.first["id"] != null ? (table.first["id"] as int) : 0;
    var raw = await db.rawInsert(
        "INSERT Into Match (id,title,comment,date,userId,win,draw,lose)"
        " VALUES (?,?,?,?,?,?,?,?)",
        [
          id,
          newMatch.title,
          newMatch.comment,
          newMatch.date,
          newMatch.userId,
          newMatch.win,
          newMatch.draw,
          newMatch.lose,
        ]);
    return raw;
  }

  Future<int> updateMatch(Match newMatch) async {
    final db = await database as Database;
    var res = await db.update("Match", newMatch.toJson(),
        where: "id = ?", whereArgs: [newMatch.id]);
    return res;
  }

  deleteMatch(int id) async {
    final db = await database as Database;
    db.delete("Match", where: "id = ?", whereArgs: [id]);
  }

  newUser(User newUser) async {
    final db = await database as Database;
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM User");
    int id = table.first["id"] != null ? (table.first["id"] as int) : 0;
    var raw = await db.rawInsert(
        "INSERT Into User (id,login,password)"
        " VALUES (?,?,?)",
        [
          id,
          newUser.login,
          newUser.password,
        ]);
    return raw;
  }

  Future<int> updateUser(User newUser) async {
    final db = await database as Database;
    var res = await db.update("User", newUser.toJson(),
        where: "id = ?", whereArgs: [newUser.id]);
    return res;
  }

  Future<List<Match>> getAllMatchForUser(int userId) async {
    final db = await database as Database;
    var res = await db.query("Match", where: "userId = ?", whereArgs: [userId]);
    List<Match> list =
        res.isNotEmpty ? res.map((c) => Match.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> userLogin(String login, String password) async {
    final db = await database as Database;
    var res = await db.query("User",
        where: "login = ? and password = ?", whereArgs: [login, password]);
    List<User> list =
        res.isNotEmpty ? res.map((c) => User.fromJson(c)).toList() : [];
    return list.isNotEmpty ? list[0].id : -1;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //File a = File(documentsDirectory.path + "/sqlite.db");
    //a.delete();

    return await openDatabase(documentsDirectory.path + "/db.db",
        version: 1,
        onOpen: (db) {}, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Match ("
          "id INTEGER PRIMARY KEY, "
          "title TEXT, "
          "comment TEXT, "
          "date TEXT, "
          "userId INTEGER,"
          "win INTEGER,"
          "lose INTEGER,"
          "draw INTEGER"
          ")");
      await db.execute("CREATE TABLE User ("
          "id INTEGER PRIMARY KEY, "
          "login TEXT, "
          "password TEXT "
          ")");
    });
  }
}
