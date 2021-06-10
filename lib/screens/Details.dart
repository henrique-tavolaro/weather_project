import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:weather_icons/weather_icons.dart';
import 'package:weather_project/data/models/favorite.dart';
import 'package:weather_project/data/models/weather.dart';
import 'package:weather_project/data/source/Dao.dart';
import 'package:weather_project/data/source/Database.dart';

class Details extends StatelessWidget {
  final Weather weather;

  const Details(this.weather);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(weather.name),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Color(0xFF1e1942),
      ),
      body: DetailsBody(weather: weather),
    );
  }
}

class DetailsBody extends StatelessWidget {
  final Weather weather;

  const DetailsBody({required this.weather});

  @override
  Widget build(BuildContext context) {
    DateTime datetime = DateTime.now();
    String _format = DateFormat.MMMMEEEEd().format(datetime);
    return Container(
        padding: EdgeInsets.all(16),
        child: Card(
            elevation: 8,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: Text(
                    _format,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: BoxedIcon(
                        WeatherIcons.day_cloudy,
                        size: 42,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          weather.weather[0].description,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        '${weather.main.temp.toInt()}ºC',
                        style: TextStyle(fontSize: 48),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          children: [
                            Text('min: ${weather.main.tempMin.toInt()}ºC'),
                            Text('max: ${weather.main.tempMax.toInt()}ºC')
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Save as favorite',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    IconButton(
                      onPressed: () {
                        FavoriteDao().insertFavorite(Favorite(weather.id, weather.name));
                      },
                      icon: Icon(Icons.favorite_border),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Mark as your default city',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    IconButton(
                      onPressed: () {
                        final int id = weather.id;
                        FavoriteDao().deleteFavorite(id);
                            // .then((value) => Navigator.pop(context));
                      },
                      icon: Icon(Icons.assistant_photo_outlined),
                    )
                  ],
                ),
              ElevatedButton(
                onPressed: () async {

                  final list = FavoriteDao().getFavorites().then((value) => print('value $value'));
                 // String url = 'https://openweathermap.org/city/${weather.id}'
                 //  if(await canLaunch(url)){
                 //    await launch(url);
                 //  } else {
                 //    Fluttertoast.showToast(msg: 'Something went wrong', toastLength: Toast.LENGTH_SHORT,
                 //    gravity: ToastGravity.CENTER, timeInSecForIosWeb: 1);
                 //  }
                },
                child: Text('Check more details on the website', style: (TextStyle(fontSize: 16)),),
                style: ElevatedButton.styleFrom(primary: Color(0xFF4270c7)),
              )
              ],

            ),),);
  }
}
