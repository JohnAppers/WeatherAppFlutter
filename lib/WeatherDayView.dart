import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WeatherDayView extends StatelessWidget {
  const WeatherDayView({Key? key}) : super(key: key);
  static const String routeName = 'dayViewScreen';

  @override
  Widget build(BuildContext context) {
    final String day = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(),
      body: Container(),
    );
  }
}
