import 'package:flutter/material.dart';
import 'package:weather_flutter/WeatherDayView.dart';

import 'WeatherGlobalView.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: WeatherGlobalView.routeName,
      routes: {
        WeatherDayView.routeName: (_) => const WeatherDayView(),
        WeatherGlobalView.routeName: (_) => const WeatherGlobalView(),
      },
    );
  }
}

