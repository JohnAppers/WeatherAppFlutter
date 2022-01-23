import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_flutter/WeatherDayView.dart';

import 'generated/l10n.dart';

const String _currentWeatherUrl = 'http://api.weatherapi.com/v1/forecast.json?key=c7ffb83ec19b44c4bc1105324210712&q=';
const String _endUrl = '&days=7&aqi=no&alerts=no';

class WeatherGlobalView extends StatefulWidget {
  const WeatherGlobalView({Key? key}) : super(key: key);
  static const String routeName = 'globalViewScreen';

  @override
  _WeatherGlobalViewState createState() => _WeatherGlobalViewState();
}

class _WeatherGlobalViewState extends State<WeatherGlobalView> {
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _locationData;
  Location location = Location();

  //Data
  String lastChecked = "";
  String stringLocation = "";
  int isDay = 1;
  double currentTemp = 0;
  double avgTemp = 0;
  double nextTemp = 0;
  double afterTemp = 0;
  String currentState = "";
  String nextState = "";
  String afterState = "";

  bool firstRun = true;
  var weatherMap = <String, dynamic>{};

  @override
  Widget build(BuildContext context) {
    _loadData();
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).weatherApp),
        actions: [
          IconButton(
            onPressed: () {_refreshInfo();},
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end:Alignment.bottomCenter,
                colors: [Colors.white,Colors.grey.shade200]
            )
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 30,
              right: 30
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _iconPrevision(),
              _currentTemperature(),
              _currentLocation(),
              _daysPrevision(),
            ],
          ),
        ),
      ),
    );
  }

  _iconPrevision() {
    if(firstRun){
      return const Padding(
          padding: EdgeInsets.all(20.0),
          child: Icon(
          Icons.wb_cloudy_outlined,
          size: 80
          )
      );
    }
    else{
      if(isDay == 1){
        return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Icon(
                Icons.wb_sunny_outlined,
                size: 80
            )
        );
      }
      else{
        return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Icon(
                Icons.wb_cloudy_outlined,
                size: 80
            )
        );
      }
    }
  }

  _currentTemperature() {
    return Row(
      children: [
        Text(
          (currentTemp.toString() + 'ºC'),
          style: const TextStyle(
              fontSize: 40
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 10),
          child: Text(
            lastChecked,
            style: const TextStyle(
              fontSize: 12
            ),
          ),
        ),
      ],
    );
  }

  _currentLocation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.place),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(stringLocation),
          )
        ],
      ),
    );
  }

  _refreshInfo() {
    _fetchLocation();
    _fetchPrevisions();
  }

  _daysPrevision() {
    return Container(
      height: 390,
      decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black),
            bottom: BorderSide(color: Colors.black),
          )
      ),
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: 3,
          itemBuilder: (context, index) {
            return SizedBox(
              height: 130,
              child: GestureDetector(
                onTap: () => {
                  if(!firstRun){
                    Navigator.pushNamed(
                      context,
                      WeatherDayView.routeName,
                      arguments: ScreenArguments(
                        weatherMap['forecast']['forecastday'][index],
                        index,
                      ),
                    )
                  }
                },
                child: Card(
                  color: Colors.blueGrey,
                  child: Row(
                    children:[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          left: 20,
                        ),
                        child: Text(
                          _getDay(index),
                          style: TextStyle(
                            fontSize: 30,
                            fontStyle: FontStyle.italic
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 100,
                            top: 10,
                            bottom: 10,
                            right: 10,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getTemp(index)+'ºC',
                              style: TextStyle(
                                fontSize: 25
                              ),
                            ),
                            Text(
                              _getStatus(index),
                              style: TextStyle(
                                  fontSize: 14
                              ),
                            ),
                          ],
                        )
                      )
                    ],
                  ),
                )
              ),
            );
          }
      ),
    );
  }

  Future<void> _fetchLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
    }

    await _getCoordinates();
  }

  Future<void> _getCoordinates() async {
    _locationData = await location.getLocation();
  }

  Future<void> _fetchPrevisions() async {
    if(_locationData == null) {
      return;
    }
    try {
      String query = _currentWeatherUrl + _locationData!.latitude.toString()
          + ',' + _locationData!.longitude.toString() + _endUrl;
      http.Response response = await http.get(Uri.parse(query));

      if (response.statusCode == HttpStatus.ok) {
        debugPrint(response.body);
        weatherMap = json.decode(response.body);
        currentTemp = await weatherMap['current']['temp_c'];
        avgTemp = await weatherMap['forecast']['forecastday'][0]['day']['avgtemp_c'];
        currentState = await weatherMap['forecast']['forecastday'][0]['day']['condition']['text'];
        nextTemp = await weatherMap['forecast']['forecastday'][1]['day']['avgtemp_c'];
        nextState = await weatherMap['forecast']['forecastday'][1]['day']['condition']['text'];
        afterTemp = await weatherMap['forecast']['forecastday'][2]['day']['avgtemp_c'];
        afterState = await weatherMap['forecast']['forecastday'][2]['day']['condition']['text'];
        stringLocation = (await weatherMap['location']['region'] as String) + ', '
          + (await weatherMap['location']['country'] as String);
        isDay = await weatherMap['current']['is_day'] as int;
        _saveTime();
        _saveData(weatherMap);
        firstRun = false;
        setState(() {});
      }
    } catch (ex) {
      debugPrint('Something went wrong: $ex');
    }
  }

  void _saveData(Map<String, dynamic> weatherMap) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('isDay', isDay);
    await prefs.setDouble('currentTemp', currentTemp);
    await prefs.setString('lastChecked', lastChecked);
    await prefs.setString('stringLocation', stringLocation);
    await prefs.setDouble('avgTemp', avgTemp);
    await prefs.setDouble('nextTemp', nextTemp);
    await prefs.setDouble('afterTemp', afterTemp);
    await prefs.setString('currentState', currentState);
    await prefs.setString('nextState', nextState);
    await prefs.setString('afterState', afterState);
  }

  Future<void> _loadData() async{
    if(firstRun){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      isDay = prefs.getInt('isDay')??1;
      currentTemp = await prefs.getDouble('currentTemp')??0;
      lastChecked = await prefs.getString('lastChecked')??"";
      stringLocation = await prefs.getString('stringLocation')??"";
      avgTemp = await prefs.getDouble('avgTemp')??0;
      nextTemp = await prefs.getDouble('nextTemp')??0;
      afterTemp = await prefs.getDouble('afterTemp')??0;
      currentState = await prefs.getString('currentState')??"";
      nextState = await prefs.getString('nextState')??"";
      afterState = await prefs.getString('afterState')??"";
      firstRun = false;
      setState(() {

      });
    }
  }

  void _saveTime(){
    DateTime now = DateTime.now();
    lastChecked = S.of(context).lastChecked + now.day.toString() + '/' + now.month.toString()
      + '/' + now.year.toString() + ' - ';
    if(now.hour < 10){
      lastChecked += '0';
    }
    lastChecked += now.hour.toString() + ':';
    if(now.minute < 10){
      lastChecked += '0';
    }
    lastChecked += now.minute.toString();
  }

  String _getDay(int daysForward){
    var date = DateTime.now();
    date = date.add(Duration(days: daysForward));
    return DateFormat('EEEE').format(date);
  }

  String _getTemp(int day) {
    if(day == 0){
      return avgTemp.toString();
    }
    if(day == 1){
      return nextTemp.toString();
    }
    else{
      return afterTemp.toString();
    }
  }

  String _getStatus(int day) {
    if(day == 0){
      return currentState;
    }
    if(day == 1){
      return nextState;
    }
    else{
      return afterState;
    }
  }
}
