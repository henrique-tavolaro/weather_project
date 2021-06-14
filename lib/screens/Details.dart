import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:weather_icons/weather_icons.dart';
import 'package:weather_project/bloc/FavoriteBloc.dart';
import 'package:weather_project/data/models/favorite.dart';
import 'package:weather_project/data/models/weather.dart';
import 'package:weather_project/data/source/Dao.dart';

class Details extends StatefulWidget {
  final Weather weather;
  final List<Favorite> favoriteList;
  const Details(this.weather, this.favoriteList);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  late FavoriteBloc favoriteBloc;


  @override
  void initState() {
    super.initState();
    favoriteBloc = BlocProvider.of<FavoriteBloc>(context);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              favoriteBloc.add(GetAllFavoritesEvent());
            });
          },
        ),
        title: Text(widget.weather.name),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Color(0xFF1e1942),
      ),
      body: DetailsBody(weather: widget.weather, favoriteBloc: favoriteBloc, favoriteList: widget.favoriteList),
    );
  }
}

class DetailsBody extends StatefulWidget {
  final Weather weather;
  final FavoriteBloc favoriteBloc;
  final List<Favorite> favoriteList;
  const DetailsBody({required this.weather, required this.favoriteBloc, required this.favoriteList});

  @override
  _DetailsBodyState createState() => _DetailsBodyState();
}

class _DetailsBodyState extends State<DetailsBody> {
  bool isFavorite = false;
  @override
  void initState() {
    super.initState();
    for(Favorite n in widget.favoriteList){
      if(n.id == widget.weather.id){
        isFavorite = true;
      }
    }
  }

  void setPreference(String cityName) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('defaultCity', cityName);
  }

  @override
  Widget build(BuildContext context) {

    DateTime datetime = DateTime.now();
    String _format = DateFormat.MMMMEEEEd().format(datetime);
    return BlocListener<FavoriteBloc, FavoriteState>(
      listener: (context, state) {
        if (state is FavoriteAddedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.weather.name} marked as favorite'),
              duration: Duration(seconds: 2),
            ),
          );
        }
          if (state is FavoriteDeletedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.weather.name} removed from favorites'),
              duration: Duration(seconds: 2),
            ),
          );
        }

      },
      child: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
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
                            widget.weather.weather[0].description,
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
                          '${widget.weather.main.temp.toInt()}ºC',
                          style: TextStyle(fontSize: 48),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Column(
                            children: [
                              Text(
                                  'min: ${widget.weather.main.tempMin.toInt()}ºC'),
                              Text(
                                  'max: ${widget.weather.main.tempMax.toInt()}ºC')
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
                          final favorite = Favorite(widget.weather.id, widget.weather.name);
                          !isFavorite ? widget.favoriteBloc.add(AddFavoriteEvent(favorite))
                              : widget.favoriteBloc.add(DeleteFavoriteEvent(favorite.id));
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                          print(isFavorite);


                        },
                        icon: isFavorite ? Icon(Icons.favorite, color: Colors.red) : Icon(Icons.favorite_border),
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

                          setPreference(widget.weather.name);


                        },
                        icon: Icon(Icons.assistant_photo_outlined),
                      )
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // final list = FavoriteDao()
                      //     .getFavorites()
                      //     .then((value) => print('value $value'));

                      String url = 'https://openweathermap.org/city/${widget.weather.id}';
                       if(await canLaunch(url)){
                         await launch(url);
                       } else {
                         Fluttertoast.showToast(msg: 'Something went wrong', toastLength: Toast.LENGTH_SHORT,
                         gravity: ToastGravity.CENTER, timeInSecForIosWeb: 1);
                       }
                    },
                    child: Text(
                      'Check more details on the website',
                      style: (TextStyle(fontSize: 16)),
                    ),
                    style: ElevatedButton.styleFrom(primary: Color(0xFF4270c7)),
                  )
                ],
              ),
            ),
          );
        },
      ),

    );


  }


}
