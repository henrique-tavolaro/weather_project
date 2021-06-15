import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_project/bloc/FavoriteBloc.dart';
import 'package:weather_project/bloc/ForecastBloc.dart';
import 'package:weather_project/data/models/favorite.dart';
import 'package:weather_project/data/models/weather.dart';
import 'package:weather_project/data/source/NetworkService.dart';
import 'package:weather_project/widgets/WeatherIcons.dart';

class Details extends StatefulWidget {
  final Weather weather;
  final List<Favorite> favoriteList;
  final String savedCity;

  const Details(this.weather, this.favoriteList, this.savedCity);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  late FavoriteBloc favoriteBloc;
  late ForecastBloc forecastBloc;
  final NetworkService networkService = NetworkService();

  @override
  void initState() {
    super.initState();
    favoriteBloc = BlocProvider.of<FavoriteBloc>(context);

    forecastBloc = BlocProvider.of<ForecastBloc>(context);
    forecastBloc.add(ForecastEvent(widget.savedCity));
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
      body: DetailsBody(
        weather: widget.weather,
        favoriteBloc: favoriteBloc,
        favoriteList: widget.favoriteList,
        savedCity: widget.savedCity,
      ),
    );
  }
}

class DetailsBody extends StatefulWidget {
  final Weather weather;
  final FavoriteBloc favoriteBloc;
  final List<Favorite> favoriteList;
  final String savedCity;

  const DetailsBody(
      {required this.weather,
      required this.favoriteBloc,
      required this.favoriteList,
      required this.savedCity});

  @override
  _DetailsBodyState createState() => _DetailsBodyState();
}

class _DetailsBodyState extends State<DetailsBody> {
  bool isFavorite = false;
  bool isDefault = false;

  @override
  void initState() {
    super.initState();
    for (Favorite n in widget.favoriteList) {
      if (n.id == widget.weather.id) {
        isFavorite = true;
      }
    }

    if (widget.savedCity == widget.weather.name) {
      isDefault = true;
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
          buildShowSnackBar(
              context, '${widget.weather.name} marked as favorite');
        }
        if (state is FavoriteDeletedState) {
          buildShowSnackBar(
              context, '${widget.weather.name} removed from favorites');
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
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: Text(
                        _format,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: WeatherIcon(
                            widget.weather.weather[0].main, Colors.black, 42),
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Divider(
                      height: 1,
                      thickness: 2,
                      color: Colors.black12,
                    ),
                  ),
                  BlocBuilder<ForecastBloc, FetchForecastState>(
                      builder: (context, state) {
                    if (state is ForecastInitialState ||
                        state is ForecastLoadingState) {
                      return Container(
                        height: 150,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (state is ForecastLoadedState) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          forecastContainer(state, 5),
                          forecastContainer(state, 13),
                          forecastContainer(state, 21),
                        ],
                      );
                    } else if (state is ForecastErrorState) {
                      return Text('Something went wrong');
                    } else {
                      return Text('An error occurred');
                    }
                  }),
                  SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Save as favorite',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      IconButton(
                        onPressed: () {
                          final favorite =
                              Favorite(widget.weather.id, widget.weather.name);
                          !isFavorite
                              ? widget.favoriteBloc
                                  .add(AddFavoriteEvent(favorite))
                              : widget.favoriteBloc
                                  .add(DeleteFavoriteEvent(favorite.id));
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        },
                        icon: isFavorite
                            ? Icon(Icons.favorite, color: Colors.red)
                            : Icon(Icons.favorite_border),
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
                            if (!isDefault) {
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Save as default city?'),
                                  content: const Text(
                                      'Are you sure you want the set as your default city?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setPreference(widget.weather.name);
                                        setState(() {
                                          isDefault = !isDefault;
                                        });
                                        Navigator.pop(context, 'OK');
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      'Choose a new city to change the default',
                                  textColor: Colors.black,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.black12,
                                  timeInSecForIosWeb: 3);
                            }
                          },
                          icon: isDefault
                              ? Icon(
                                  Icons.assistant_photo,
                                  color: Colors.green.shade900,
                                )
                              : Icon(
                                  Icons.assistant_photo_outlined,
                                  color: Colors.grey,
                                ))
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        String url =
                            'https://openweathermap.org/city/${widget.weather.id}';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Something went wrong',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1);
                        }
                      },
                      child: Text(
                        'Check more details on the website',
                        style: (TextStyle(fontSize: 16)),
                      ),
                      style:
                          ElevatedButton.styleFrom(primary: Color(0xFF4270c7)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Container forecastContainer(ForecastLoadedState state, int position) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Text(DateFormat('EEE d MM')
              .format(state.forecast.list[position].dtTxt)
              .toString()),
          WeatherIcon(
            state.forecast.list[position].weather[0].main,
            Colors.black12,
            48,
          ),
          Text(state.forecast.list[position].weather[0].description),
          Text(
              '${state.forecast.list[position].main.tempMin.toInt()}ºC - ${state.forecast.list[position].main.tempMax.toInt()}ºC')
        ],
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> buildShowSnackBar(
      BuildContext context, String text) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
