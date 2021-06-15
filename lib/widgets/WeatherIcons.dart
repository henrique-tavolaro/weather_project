import 'package:flutter/cupertino.dart';
import 'package:weather_icons/weather_icons.dart';

class WeatherIcon extends StatelessWidget {
  final String weather;
  final Color color;
  final double size;

  const WeatherIcon(this.weather, this.color, this.size);

  @override
  Widget build(BuildContext context) {
    switch (weather) {
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
