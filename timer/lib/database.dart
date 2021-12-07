
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'models/setting_model.dart';
import 'models/timer.dart';
import 'models/phase.dart';

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

  Future<int> newTimer(MyTimer newTimer) async {
    final db = await database as Database;
    //get the biggest id in the table
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM MyTimer");
    int id = table.first['id'] == null ? 0 : table.first['id'] as int;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into MyTimer "
        "(id,title,phaseDelay,repeatDelay,repeat,scolor,mcolor)"
        " VALUES (?,?,?,?,?,?,?)",
        [
          id,
          newTimer.title,
          newTimer.phaseDelay,
          newTimer.repeatDelay,
          newTimer.repeat,
          newTimer.scolor,
          newTimer.mcolor,
        ]);
    return raw;
  }

  Future<MyTimer> getTimer(int id) async {
    final db = await database as Database;
    var res = await db.query("MyTimer", where: "id = ?", whereArgs: [id]);
    return MyTimer.fromJson(res.first);
  }

  Future<List<MyTimer>> getAllTimers() async {
    final db = await database as Database;
    var res = await db.query("MyTimer");
    List<MyTimer> list =
        res.isNotEmpty ? res.map((c) => MyTimer.fromJson(c)).toList() : [];
    return list;
  }

  updateTimer(MyTimer newTimer) async {
    final db = await database as Database;
    var res = await db.update("MyTimer", newTimer.toJson(),
        where: "id = ?", whereArgs: [newTimer.id]);
    return res;
  }

  updateSetting(SettingModel newSetting) async {
    final db = await database as Database;
    var res = await db.update("Settings", newSetting.toJson(),
        where: "id = ?", whereArgs: [newSetting.id]);
    return res;
  }

  Future<List<SettingModel>> getAllSettings() async {
    final db = await database as Database;
    var res = await db.query("Settings");
    List<SettingModel> list =
        res.isNotEmpty ? res.map((c) => SettingModel.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> newSetting(SettingModel newSetting) async {
    final db = await database as Database;
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Settings");
    var raw = await db.rawInsert(
        "INSERT Into Settings "
        "(id,title,value)"
        " VALUES (?,?,?)",
        [newSetting.id, newSetting.title, newSetting.value]);
    return raw;
  }

  deleteSetting(int id) async {
    final db = await database as Database;
    db.delete("Settings", where: "id = ?", whereArgs: [id]);
  }

  flush() async {
    final db = await database as Database;
    db.delete("Phase");
    db.delete("MyTimer");
  }

  deleteTimer(int id) async {
    final db = await database as Database;
    db.delete("MyTimer", where: "id = ?", whereArgs: [id]);
    db.delete("Phase", where: "timerId = ?", whereArgs: [id]);
  }

  newPhase(Phase newPhase) async {
    final db = await database as Database;
    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Phase");
    int id = table.first["id"] != null ? (table.first["id"] as int) : 0;
    var raw = await db.rawInsert(
        "INSERT Into Phase (id,title,wait,timerId)"
        " VALUES (?,?,?,?)",
        [
          id,
          newPhase.title,
          newPhase.wait,
          newPhase.timerId,
        ]);
    return raw;
  }

  Future<List<Phase>> getAllPhasesForTimer(int timerId) async {
    final db = await database as Database;
    var res =
        await db.query("Phase", where: "timerId = ?", whereArgs: [timerId]);
    List<Phase> list =
        res.isNotEmpty ? res.map((c) => Phase.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> updatePhase(Phase newPhase) async {
    final db = await database as Database;
    var res = await db.update("Phase", newPhase.toJson(),
        where: "id = ?", whereArgs: [newPhase.id]);
    return res;
  }

  deletePhase(int id) async {
    final db = await database as Database;
    db.delete("Phase", where: "id = ?", whereArgs: [id]);
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //File a = File(documentsDirectory.path + "/sqlite.db");
    //a.delete();

    return await openDatabase(documentsDirectory.path + "/sqlite.db",
        version: 1, onOpen: (db) {
      var a = 1;
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Phase ("
          "id INTEGER PRIMARY KEY, "
          "title TEXT, "
          "wait INTEGER, "
          "timerId INTEGER "
          ")");
      await db.execute("CREATE TABLE MyTimer ("
          "id INTEGER PRIMARY KEY, "
          "title TEXT, "
          "phaseDelay INTEGER, "
          "repeat INTEGER, "
          "repeatDelay INTEGER, "
          "mcolor INTEGER, "
          "scolor INTEGER "
          ")");
      await db.execute("CREATE TABLE Settings ("
          "id INTEGER PRIMARY KEY, "
          "title TEXT, "
          "value INTEGER "
          ")");
    });
  }
}
