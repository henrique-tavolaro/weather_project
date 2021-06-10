import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather_project/data/models/weather.dart';
import 'package:weather_project/utils/constants.dart';


class NetworkService {
  Future<Weather> fetchWeather(String cityName) async {
    var response = await http.get(
      Uri.parse('http://api.openweathermap.org/data/2.5/weather?q=$cityName&units=metric&appid=$API_KEY')
    );
    //
    if(response.statusCode == 200){
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error getting data');
    }
  }
}