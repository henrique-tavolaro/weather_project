import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weather_project/data/models/favorite.dart';

Future<Database> getDatabase() async {
  WidgetsFlutterBinding.ensureInitialized();

  final String path = join(await getDatabasesPath(), 'favorites.db');
  return openDatabase(path,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE favorites(id INTEGER PRIMARY KEY, cityName TEXT)',
        );
      }, version: 1);
}


