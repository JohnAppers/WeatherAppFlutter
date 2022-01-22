import 'package:flutter/material.dart';

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
        AnimationScreen.routeName: (_) => const WeatherDayView(),
        WeatherGlobalView.routeName: (_) => const WeatherGlobalView(),
      },
    );
  }
}

