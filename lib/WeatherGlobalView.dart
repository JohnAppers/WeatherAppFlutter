import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

const String _currentWeatherUrl = 'api.weatherapi.com/v1/current.json?key=c7ffb83ec19b44c4bc1105324210712&q=';

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

  var weatherMap = <String, dynamic>{};
  int currentTemp = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        actions: [
          IconButton(
            onPressed: _refreshInfo(),
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
              _location(),
              _hoursPrevision(),
              _weekPrevision(),
            ],
          ),
        ),
      ),
    );
  }

  _iconPrevision() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Icon(
        Icons.cloud,
        size: 100,
      ),
    );
  }

  _currentTemperature() {
    return Text(
      (currentTemp.toString() + 'ºC'),
      style: const TextStyle(
          fontSize: 50
      ),
    );
  }

  _location() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: const [
          Icon(Icons.place),
          Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text('Aveiro, PT'),
          )
        ],
      ),
    );
  }

  _refreshInfo() {
    _fetchLocation();
    _fetchPrevisions();
    setState(() {});
  }

  _hoursPrevision() {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black),
            bottom: BorderSide(color: Colors.black),
          )
      ),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 12,
          itemBuilder: (context, index) {
            return SizedBox(
              width: 70,
              child: Card(
                child: Center(
                  child: Text('$index'),
                ),
              ),
            );
          }
      ),
    );
  }

  _weekPrevision() {
    return Expanded(
      child: Container(
        height: 100,
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: 7,
            itemBuilder: (context, index) {
              return SizedBox(
                height: 50,
                child: Card(
                  child: Center(
                    child: Text('$index'),
                  ),
                ),
              );
            }
        ),
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

    setState(() {});
  }

  Future<void> _getCoordinates() async {
    _locationData = await location.getLocation();
  }

  Future<void> _fetchPrevisions() async {
    try {
      String query = _currentWeatherUrl + _locationData!.latitude.toString()
          + ',' + _locationData!.longitude.toString();
      http.Response response = await http.get(Uri.parse(query));

      if (response.statusCode == HttpStatus.ok) {
        debugPrint(response.body);
        weatherMap = json.decode(response.body);
        currentTemp = weatherMap['current']['temp_c'] as int;
      }
    } catch (ex) {
      debugPrint('Something went wrong: $ex');
    }
  }
}
