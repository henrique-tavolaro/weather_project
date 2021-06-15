
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:weather_project/bloc/FavoriteBloc.dart';
import 'package:weather_project/bloc/FetchDataBloc.dart';
import 'package:weather_project/data/models/favorite.dart';
import 'package:weather_project/data/models/weather.dart';
import 'package:weather_project/data/source/NetworkService.dart';
import 'package:intl/intl.dart';
import 'package:weather_project/widgets/WeatherIcons.dart';

import 'Details.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  NetworkService networkService = NetworkService();
  late FetchDataBloc weatherBloc;
  late FavoriteBloc favoriteBloc;
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Favorite> favoriteList = [];
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isDefaultSet = true;
  String savedCity = "";
  bool isSearchPressed = false;

  @override
  void initState() {
    super.initState();
    weatherBloc = BlocProvider.of<FetchDataBloc>(context);

    getPreference();

    favoriteBloc = BlocProvider.of<FavoriteBloc>(context);
    favoriteBloc.add(GetAllFavoritesEvent());
  }

  void getPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedCity = prefs.getString('defaultCity') ?? "";
      savedCity == ""
          ? isDefaultSet = false
          : weatherBloc.add(FetchEvent(savedCity));

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: Search(_scrollController, favoriteList, favoriteBloc, weatherBloc,
          savedCity, isDefaultSet),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      key: _scaffoldKey,
      title: isSearchPressed
          ? TextField(
        controller: _textEditingController,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.search),
            suffixIcon: IconButton(
              icon: Icon(Icons.backspace),
              onPressed: () { _textEditingController.text = ''; },
            ),
            hintText: 'Search'),
        textInputAction: TextInputAction.search,
        onSubmitted: (query) {
          setState(() {
            isDefaultSet = true;
          });
          weatherBloc.add(FetchEvent(query));
          _scrollController.animateTo(0,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut);
        },
      )
          : Text('The Weather App'),
      centerTitle: true,
      elevation: 4,
      backgroundColor: Color(0xFF1e1942),
      actions: [
        // IconButton(
        //   icon: Icon(Icons.backspace, color: isSearchPressed ? Colors.white : Colors.transparent),
        //   onPressed: () {
        //     _textEditingController.text = '';
        //   },),
        IconButton(
            onPressed: () {
              setState(() {
                isSearchPressed = !isSearchPressed;
              });
            },
            icon: isSearchPressed ? Icon(Icons.clear) : Icon(Icons.search)),

      ],
    );
  }
}

class Search extends StatefulWidget {
  final ScrollController scrollController;
  final List<Favorite> list;
  final FavoriteBloc favoriteBloc;
  final FetchDataBloc weatherBloc;
  final String savedCity;
  final isDefaultSet;

  const Search(this.scrollController, this.list, this.favoriteBloc,
      this.weatherBloc, this.savedCity, this.isDefaultSet);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _textEditingController = TextEditingController();
  late Weather weather;
  List<Favorite> favoriteList = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1e1942), Color(0xFFFFFFFF)],
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 180,
                  // padding: EdgeInsets.only(top: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: BoxedIcon(
                          WeatherIcons.day_cloudy,
                          color: Colors.white,
                          size: 56,
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: EdgeInsets.only(left: 16.0, bottom: 16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Check the weather',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                              Text(
                                'Worldwide',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 44,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: widget.isDefaultSet
                      ? BlocBuilder<FetchDataBloc, FetchDataState>(
                    builder: (context, state) {
                      if (state is FetchInitialState ||
                          state is FetchLoadingState) {
                        return Container(
                          height: 150,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (state is FetchLoadedState) {
                        weather = state.weather;
                        return Center(
                          child: DefaultCityCard(
                              weather, favoriteList, widget.savedCity),
                        );
                      } else if (state is FetchErrorState) {
                        return Container(
                            height: 250,
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Center(
                                  child: Text('An Error occurred',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic))),
                            ));
                      } else {
                        return Container(
                            height: 250,
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Center(
                                  child: Text('Some other error',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic))),
                            ));
                      }
                    },
                  )
                      : Container(
                    height: 250,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Center(
                        child: Text(
                          'No city set as default',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(
                    'Favorites:',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            ),
          ),
          FavoriteListWidget(favoriteList: favoriteList, widget: widget)
        ],
      ),
    );
  }
}

class FavoriteListWidget extends StatelessWidget {
  const FavoriteListWidget({
    Key? key,
    required this.favoriteList,
    required this.widget,
  }) : super(key: key);

  final List<Favorite> favoriteList;
  final Search widget;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(builder: (context, state) {
      if (state is FavoriteInitialState ||
          state is FavoriteIsLoadingState) {
        return Center(child: CircularProgressIndicator());
      } else if (state is FavoriteLoadedState) {
        favoriteList.clear();
        favoriteList.addAll(state.favoriteList);
        return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: favoriteList.length,
          itemBuilder: (context, index) {
            return Container(
                height: 80.0,
                child: Card(
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8),
                    onTap: () {
                      widget.weatherBloc
                          .add(FetchEvent(favoriteList[index].cityName));
                    },
                    leading: CircleAvatar(
                      radius: 25,
                      child: Text(
                        '${favoriteList[index].cityName[0]}',
                        style: TextStyle(fontSize: 28),
                      ),
                      backgroundColor: Color(0xFF4270c7),
                    ),
                    title: Text(
                      '${favoriteList[index].cityName}',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                )
              // Center(
              //   child: Text('${favoriteList[index].cityName}',
              //       textScaleFactor: 3),
              // )
            );
          },
        );
      } else {
        return Center(
          child: Text('Something went wrong'),
        );
      }
    });
  }
}

class DefaultCityCard extends StatefulWidget {
  final Weather weather;
  final List<Favorite> favoriteList;
  final String savedCity;


  const DefaultCityCard(this.weather, this.favoriteList, this.savedCity);

  @override
  _DefaultCityCardState createState() => _DefaultCityCardState();
}

class _DefaultCityCardState extends State<DefaultCityCard> {
  final DateTime datetime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    String _format = DateFormat.MMMMEEEEd().format(datetime);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 16),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        color: Colors.transparent,
                      ),
                      Text(
                        widget.weather.name,
                        style: TextStyle(fontSize: 36),
                        textAlign: TextAlign.center,
                      ),
                      Icon(Icons.assistant_photo, color: widget.savedCity == widget.weather.name
                          ? Colors.green.shade900
                          : Colors.transparent
                          , semanticLabel: 'Default City',),
                    ],
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _format,
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: WeatherIcon(widget.weather.weather[0].main, Colors.black, 42),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            // _format,
                            widget.weather.weather[0].description,
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16, bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
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
                                      'min: ${widget.weather.main.tempMin
                                          .toInt()}ºC'),
                                  Text(
                                      'max: ${widget.weather.main.tempMax
                                          .toInt()}ºC')
                                ],
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    BlocProvider.value(
                                        value:
                                        BlocProvider.of<FavoriteBloc>(context),
                                        child: Details(widget.weather,
                                            widget.favoriteList,
                                            widget.savedCity)),
                              ),
                            );
                          },
                          child: Row(children: [
                            Text(
                              'More details',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Icon(Icons.arrow_right_alt_rounded),
                            )
                          ]),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

