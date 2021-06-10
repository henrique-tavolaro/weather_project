import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_project/bloc/FetchDataBloc.dart';
import 'package:weather_project/data/source/NetworkService.dart';
import 'package:weather_project/screens/HomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<FetchDataBloc>(
        create: (BuildContext context) {
          return FetchDataBloc(NetworkService());
        },
        child: HomePage(),
      ),

    );
  }
}

