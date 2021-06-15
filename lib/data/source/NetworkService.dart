import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather_project/data/models/forecast.dart';
import 'package:weather_project/data/models/weather.dart';
import 'package:weather_project/utils/constants.dart';


class NetworkService {
  Future<Weather> fetchWeather(String cityName) async {
    var response = await http.get(
      Uri.parse('http://api.openweathermap.org/data/2.5/weather?q=$cityName&units=metric&appid=$API_KEY')
    );

    if(response.statusCode == 200){
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error getting data');
    }
  }


  Future<Forecast> fetchForecast(String cityName) async {
    var response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&units=metric&cnt=24&appid=$API_KEY')
    );

    if(response.statusCode == 200){


      var json = jsonDecode(response.body);
      // print('1: ${json.toString()}');

      // for(dynamic i in json['list']){
      //   Forecast.fromJson(i);
      //
      //   list.add(i);
      // }
      // print('list $list');
      String zi = Forecast.fromJson(jsonDecode(response.body)).toString();
      print('2 $zi');
      return Forecast.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('error: ${response.statusCode}');
    }
  }

}