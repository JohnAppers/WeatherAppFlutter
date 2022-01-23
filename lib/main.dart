import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:weather_flutter/WeatherDayView.dart';

import 'WeatherGlobalView.dart';
import 'generated/l10n.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      initialRoute: WeatherGlobalView.routeName,
      routes: {
        WeatherDayView.routeName: (_) => WeatherDayView(),
        WeatherGlobalView.routeName: (_) => const WeatherGlobalView(),
      },
    );
  }
}

