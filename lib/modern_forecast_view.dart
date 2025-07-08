import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weatherapp/app/data/models/weather_details_model.dart';

class ModernForecastView extends StatelessWidget {
  final List<Forecast> forecasts;

  const ModernForecastView({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecasts.length,
        itemBuilder: (context, index) {
          final forecast = forecasts[index];
          return Container(
            width: 120,
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  DateFormat.E().format(forecast.date),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                Icon(
                  WeatherIcons.fromCondition(forecast.description),
                  color: Colors.white,
                  size: 40,
                ),
                Text(
                  '${forecast.temp.toStringAsFixed(1)}°C',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Define Forecast class if it doesn't exist
class Forecast {
  final DateTime date;
  final String description;
  final double temp;

  Forecast({required this.date, required this.description, required this.temp});
}

// Define WeatherIcons class if it doesn't exist
class WeatherIcons {
  static const IconData sunny = IconData(0xe30d, fontFamily: 'WeatherIcons');
  static const IconData cloudy = IconData(0xe312, fontFamily: 'WeatherIcons');
  static const IconData rainy = IconData(0xe319, fontFamily: 'WeatherIcons');

  static IconData fromCondition(String description) {
    switch (description.toLowerCase()) {
      case 'sunny':
        return sunny;
      case 'cloudy':
        return cloudy;
      case 'rainy':
        return rainy;
      default:
        return sunny;
    }
  }
}
