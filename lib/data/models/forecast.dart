// To parse this JSON data, do
//
//     final forecast = forecastFromJson(jsonString);

import 'dart:convert';

Forecast forecastFromJson(String str) => Forecast.fromJson(json.decode(str));

String forecastToJson(Forecast data) => json.encode(data.toJson());

class Forecast {
  Forecast(
    this.cod,
    this.message,
    this.cnt,
    this.list,
    this.city,
  );

  String cod;
  int message;
  int cnt;
  List<ListElement> list;
  City city;

  factory Forecast.fromJson(Map<String, dynamic> json) => Forecast(
    json["cod"],
    json["message"],
    json["cnt"],
    List<ListElement>.from(json["list"].map((x) => ListElement.fromJson(x))),
    City.fromJson(json["city"]),
  );

  Map<String, dynamic> toJson() => {
    "cod": cod,
    "message": message,
    "cnt": cnt,
    "list": List<dynamic>.from(list.map((x) => x.toJson())),
    "city": city.toJson(),
  };
}

class City {
  City(
    this.id,
    this.name,
    this.coord,
    this.country,
    this.timezone,
    this.sunrise,
    this.sunset,
  );

  int id;
  String name;
  Coord coord;
  String country;
  int timezone;
  int sunrise;
  int sunset;

  factory City.fromJson(Map<String, dynamic> json) => City(
    json["id"],
    json["name"],
    Coord.fromJson(json["coord"]),
    json["country"],
    json["timezone"],
    json["sunrise"],
    json["sunset"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "coord": coord.toJson(),
    "country": country,
    "timezone": timezone,
    "sunrise": sunrise,
    "sunset": sunset,
  };
}

class Coord {
  Coord(
    this.lat,
    this.lon,
  );

  double lat;
  double lon;

  factory Coord.fromJson(Map<String, dynamic> json) => Coord(
    json["lat"].toDouble(),
    json["lon"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lon": lon,
  };
}

class ListElement {
  ListElement(
    this.dt,
    this.main,
    this.weather,
    this.clouds,
    this.wind,
    this.visibility,
    this.pop,
    // this.rain,
    this.sys,
    this.dtTxt,
  );

  int dt;
  Main main;
  List<ForecastWeather> weather;
  Clouds clouds;
  Wind wind;
  int visibility;
  double pop;
  // Rain rain;
  Sys sys;
  DateTime dtTxt;

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
    json["dt"],
    Main.fromJson(json["main"]),
    List<ForecastWeather>.from(json["weather"].map((x) => ForecastWeather.fromJson(x))),
    Clouds.fromJson(json["clouds"]),
    Wind.fromJson(json["wind"]),
    json["visibility"],
    json["pop"].toDouble(),
    // Rain.fromJson(json["rain"]),
    Sys.fromJson(json["sys"]),
    DateTime.parse(json["dt_txt"]),
  );

  Map<String, dynamic> toJson() => {
    "dt": dt,
    "main": main.toJson(),
    "weather": List<dynamic>.from(weather.map((x) => x.toJson())),
    "clouds": clouds.toJson(),
    "wind": wind.toJson(),
    "visibility": visibility,
    "pop": pop,
    // "rain": rain.toJson(),
    "sys": sys.toJson(),
    "dt_txt": dtTxt.toIso8601String(),
  };
}

class Clouds {
  Clouds(
    this.all,
  );

  int all;

  factory Clouds.fromJson(Map<String, dynamic> json) => Clouds(
    json["all"],
  );

  Map<String, dynamic> toJson() => {
    "all": all,
  };
}

class Main {
  Main(
    this.temp,
    this.feelsLike,
    this.tempMin,
    this.tempMax,
    this.pressure,
    this.seaLevel,
    this.grndLevel,
    this.humidity,
    this.tempKf,
  );

  double temp;
  double feelsLike;
  double tempMin;
  double tempMax;
  int pressure;
  int seaLevel;
  int grndLevel;
  int humidity;
  double tempKf;

  factory Main.fromJson(Map<String, dynamic> json) => Main(
    json["temp"].toDouble(),
    json["feels_like"].toDouble(),
    json["temp_min"].toDouble(),
    json["temp_max"].toDouble(),
    json["pressure"],
    json["sea_level"],
    json["grnd_level"],
    json["humidity"],
    json["temp_kf"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "temp": temp,
    "feels_like": feelsLike,
    "temp_min": tempMin,
    "temp_max": tempMax,
    "pressure": pressure,
    "sea_level": seaLevel,
    "grnd_level": grndLevel,
    "humidity": humidity,
    "temp_kf": tempKf,
  };
}
//
// class Rain {
//   Rain(
//     this.the3H,
//   );
//
//   double the3H;
//
//   factory Rain.fromJson(Map<String, dynamic> json) => Rain(
//     json["3h"].toDouble(),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "3h": the3H,
//   };
// }

class Sys {
  Sys(
    this.pod,
  );

  String pod;

  factory Sys.fromJson(Map<String, dynamic> json) => Sys(
    json["pod"],
  );

  Map<String, dynamic> toJson() => {
    "pod": pod,
  };
}

class ForecastWeather {
  ForecastWeather(
    this.id,
    this.main,
    this.description,
    this.icon,
  );

  int id;
  String main;
  String description;
  String icon;

  factory ForecastWeather.fromJson(Map<String, dynamic> json) => ForecastWeather(
    json["id"],
    json["main"],
    json["description"],
    json["icon"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "main": main,
    "description": description,
    "icon": icon,
  };
}

class Wind {
  Wind(
    this.speed,
    this.deg,
    this.gust,
  );

  double speed;
  int deg;
  double gust;

  factory Wind.fromJson(Map<String, dynamic> json) => Wind(
    json["speed"].toDouble(),
    json["deg"],
    json["gust"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "speed": speed,
    "deg": deg,
    "gust": gust,
  };
}
