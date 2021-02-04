import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/SearchResponse.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class DBProvider {
  // create a singleton
  DBProvider._();
  bool initialized;
  static final DBProvider db = DBProvider._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDB();
    return _database;
  }

  initDB() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "data_final.sqlite");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data =
          await rootBundle.load(join("assets", "data_final.sqlite"));

      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }

    return await openDatabase(
      path,
      version: 1,
    );
  }

  getResult(String word) async {
    print("database block called");
    final db = await database;

    String s = word;
    if (s.codeUnitAt(0) >= 65 && s.codeUnitAt(0) <= 122) {
      // query en_dz table
      var res3 = await db.query('en_dz',
          where: "keyword like ?", whereArgs: [word], limit: 4);

      var res4 = await db.query('technical_terminologies',
          where: "terminology like ?", whereArgs: [word], limit: 4);

      List<DzoSearchResponse> result3 = res3.isNotEmpty
          ? res3.map((note) => DzoSearchResponse.fromJson(note)).toList()
          : [];
      List<DzoSearchResponse> result4 = res4.isNotEmpty
          ? res4.map((note) => DzoSearchResponse.fromJson(note)).toList()
          : [];

      // if (result3.length > 0) {
      // result3[0].message = "From English-Dzongkha Dictionary";

      // }

      for (var i = 0; i < result3.length; i++) {
        result3[i].terminology = "";

        result3[i].message = "";
        result3[0].message = "From English-Dzongkha Dictionary";
      }

      for (var i = 0; i < result4.length; i++) {
        result4[i].pos = "";
        result4[i].keyword = "";
        result4[i].id = "";
        result4[i].message = "From Terminology Books";
      }

      print(result3.length);
      print("if block");

      return result3 + result4;
    } else {
      print("else block ");

      // query dz_dz and dz_en table
      var res1 = await db.query('dz_dz',
          where: "keyword like ?", whereArgs: [word], limit: 4);
      var res2 = await db.query('dz_en',
          where: "keyword like ?", whereArgs: [word], limit: 4);

      List<DzoSearchResponse> result1 = res1.isNotEmpty
          ? res1.map((note) => DzoSearchResponse.fromJson(note)).toList()
          : [];
      List<DzoSearchResponse> result2 = res2.isNotEmpty
          ? res2.map((note) => DzoSearchResponse.fromJson(note)).toList()
          : [];

      for (var i = 0; i < result1.length; i++) {
        result1[i].pos = "";
        result1[i].terminology = "";
        result1[i].message = "From Dzongkha-Dzongkha Dictionary";
      }
      for (var i = 0; i < result2.length; i++) {
        result2[i].terminology = "";
        result2[i].message = "From Dzongkha-English Dictionary";
      }

      return result1 + result2;
    }
  }
}
