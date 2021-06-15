import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:weather_project/bloc/FavoriteBloc.dart';
import 'package:weather_project/bloc/FetchDataBloc.dart';
import 'package:weather_project/data/models/favorite.dart';
import 'package:weather_project/data/models/weather.dart';
import 'package:weather_project/data/source/Dao.dart';
import 'package:weather_project/data/source/NetworkService.dart';
import 'package:intl/intl.dart';

import 'Details.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NetworkService networkService = NetworkService();
  late FetchDataBloc weatherBloc;
  late FavoriteBloc favoriteBloc;
  String query = '';
  bool isSearchPressed = false;
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Favorite> favoriteList = [];
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  String savedCity = "";



  @override
  void initState() {
    super.initState();
    weatherBloc = BlocProvider.of<FetchDataBloc>(context);
    void getPreference() async {
      final prefs = await SharedPreferences.getInstance();
      setState((){
        savedCity = prefs.getString('defaultCity') ?? "";
        weatherBloc.add(FetchEvent(savedCity));
      });
    }

    getPreference();
    // if(savedCity != ''){
    //   query = savedCity;
    // }



    favoriteBloc = BlocProvider.of<FavoriteBloc>(context);
    favoriteBloc.add(GetAllFavoritesEvent());
    // FavoriteDao().getFavorites().then((value) => favoriteList.addAll(value));

  }





  @override
  Widget build(BuildContext context) {
    print('savedCity: $savedCity');
    return Scaffold(
      appBar: AppBar(
        key: _scaffoldKey,
        title: isSearchPressed
            ? TextField(
          controller: _textEditingController,
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.search),
              hintText: 'Search'),
          textInputAction: TextInputAction.search,
          onSubmitted: (query) {
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
          IconButton(
              onPressed: () {
                setState(() {
                  isSearchPressed = !isSearchPressed;
                });
              },
              icon: isSearchPressed ? Icon(Icons.clear) : Icon(Icons.search))
        ],
      ),
      body: Search(_scrollController, favoriteList, favoriteBloc, weatherBloc),
    );
  }
}

class Search extends StatefulWidget {
  final ScrollController scrollController;
  final List<Favorite> list;
  final FavoriteBloc favoriteBloc;
  final FetchDataBloc weatherBloc;

  const Search(this.scrollController, this.list, this.favoriteBloc, this.weatherBloc);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _textEditingController = TextEditingController();
  late Weather weather;
  List<Favorite> favoriteList = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, state) {
        if (state is FavoriteInitialState ||
            state is FavoriteIsLoadingState) {
          return Center(child: CircularProgressIndicator());
        } else if (state is FavoriteLoadedState) {
          favoriteList.clear();
          favoriteList.addAll(state.favoriteList);
          print(favoriteList.toString());
          return CustomScrollView(
            controller: widget.scrollController,
            slivers: [
              SliverAppBar(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30))),
                  // pinned: true,
                  floating: true,
                  expandedHeight: 180,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF1e1942), Color(0xFF4270c7)])),
                    child: FlexibleSpaceBar(
                      background: Container(
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
                                  padding: EdgeInsets.only(
                                      left: 16.0, bottom: 16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
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
                          )),
                    ),
                  )),
              SliverToBoxAdapter(
                  child: BlocBuilder<FetchDataBloc, FetchDataState>(
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
                          child: DefaultCityCard(weather, favoriteList),
                        );
                      } else if (state is FetchErrorState) {
                        return Center(child: Text('An error of network'));
                      } else {
                        return Center(child: Text('Some other error'));
                      }
                    },
                  )),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return Container(
                        // color: index.isOdd ? Colors.white : Colors.black12,
                        height: 80.0,

                        child: Card(
                          elevation: 4,
                          child: ListTile(
                            onTap: () {
                              widget.weatherBloc.add(FetchEvent(favoriteList[index].cityName));
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                      value: BlocProvider.of<FavoriteBloc>(context),
                                      child: BlocBuilder<FetchDataBloc, FetchDataState>(
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
                                            return Details(weather, favoriteList);
                                          } else if (state is FetchErrorState) {
                                            return Center(child: Text('An error occured'));
                                          } else {
                                            return Center(child: Text('An error occured'));
                                          }
                                        },
                                      )
                                  ),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              radius: 25,
                              child: Text('${favoriteList[index].cityName[0]}', style: TextStyle(fontSize: 28),),
                              backgroundColor: Color(0xFF4270c7),
                            ),
                          title: Text('${favoriteList[index].cityName}', style: TextStyle(fontSize: 22),),
                          ),
                        )
                        // Center(
                        //   child: Text('${favoriteList[index].cityName}',
                        //       textScaleFactor: 3),
                        // )
                    );
                  },
                  childCount: favoriteList.length,
                ),
              )


            ],
          );
        } else {
          return Text('sss');
        }
      },
    );
  }
}

class FavoriteList extends StatefulWidget {
  final double weight;

  const FavoriteList(this.weight);

  @override
  _FavoriteListState createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.weight,
      child: Center(child: Text('No favorites saved')),
    );
  }
}

class DefaultCityCard extends StatefulWidget {
  final Weather weather;
  final List<Favorite> favoriteList;

  const DefaultCityCard(this.weather, this.favoriteList);

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
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4270c7), Color(0xFFf6f5fc)])),
          // color: Color(0xFF4270e7),
          // height: 30,
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
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.favorite),
                      )
                    ],
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _format,
                      textAlign: TextAlign.start,
                      // widget.weather.weather[0].description,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: WeatherIcon(widget.weather, Colors.black, 42),
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
                                builder: (_) => BlocProvider.value(
                                  value: BlocProvider.of<FavoriteBloc>(context),
                                  child:Details(widget.weather, widget.favoriteList)
                                ),
                              ),
                            );
                          },
                          child: Row(
                              children: [
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Text(
            'Favorites:',
            style: TextStyle(fontSize: 20),
          ),
        )
      ],
    );
  }
}

class WeatherIcon extends StatelessWidget {
  final Weather weather;
  final Color color;
  final double size;

  const WeatherIcon(this.weather, this.color, this.size);

  @override
  Widget build(BuildContext context) {
    switch (weather.weather[0].main) {
      case 'Thunderstorm':
        return BoxedIcon(
          WeatherIcons.thunderstorm,
          color: color,
          size: size,
        );
      case 'Drizzle':
        return BoxedIcon(
          WeatherIcons.raindrops,
          color: color,
          size: size,
        );
      case 'Rain':
        return BoxedIcon(
          WeatherIcons.rain,
          color: color,
          size: size,
        );
      case 'Snow':
        return BoxedIcon(
          WeatherIcons.snow,
          color: color,
          size: size,
        );
      case 'Clear':
        return BoxedIcon(
          WeatherIcons.day_sunny,
          color: color,
          size: size,
        );
      case 'Clouds':
        return BoxedIcon(
          WeatherIcons.cloudy,
          color: color,
          size: size,
        );
      default:
        return BoxedIcon(
          WeatherIcons.fog,
          color: color,
          size: size,
        );
    }
  }
}
