import 'package:sqflite/sqflite.dart';
import 'package:weather_project/data/models/favorite.dart';

import 'Database.dart';

class FavoriteDao{


  Future<void> insertFavorite(Favorite favorite) async {
    final Database db = await getDatabase();

    await db.insert(
      'favorites',
      favorite.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<List<Favorite>> getFavorites() async {
    final Database db = await getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('favorites');

    return List.generate(
      maps.length,
          (index) {
        return Favorite(
          maps[index]['id'],
          maps[index]['cityName'],
        );
      },
    );
  }


  Future<void> deleteFavorite(int id) async {
    final Database db = await getDatabase();

    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


}