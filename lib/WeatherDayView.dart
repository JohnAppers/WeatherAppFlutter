import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScreenArguments {
  final Map<String, dynamic> weatherMap;
  final int day;

  ScreenArguments(this.weatherMap, this.day);
}

class WeatherDayView extends StatefulWidget {
  WeatherDayView({Key? key}) : super(key: key);
  static const String routeName = 'dayViewScreen';

  @override
  _WeatherDayViewState createState() => _WeatherDayViewState();
}

class _WeatherDayViewState extends State<WeatherDayView> {
  //Data
  double minTemp = 0;
  double maxTemp = 0;
  late ScreenArguments args;
  bool firstRun = true;
  String state = "";

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    _loadData();
    return Scaffold(
      appBar: AppBar(),
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
            top:30,
            left: 30,
            right: 30
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _avgTemperature(),
              _hourPrevision(),
            ],
          )
        )
      ),
    );
  }

  _avgTemperature() {
    return Center(
      child: Column(
        children: [
          Text(
            ("Min.: " + minTemp.toString() + 'ºC'),
            style: const TextStyle(
                fontSize: 30
            ),
          ),
          Text(
            ("Max.: " + maxTemp.toString() + 'ºC'),
            style: const TextStyle(
                fontSize: 30
            ),
          ),
          Text(
            (state),
            style: const TextStyle(
                fontSize: 30
            ),
          ),
        ],
      ),
    );
  }

  _hourPrevision() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Container(
          decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black),
                bottom: BorderSide(color: Colors.black),
              )
          ),
          height: 100,
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: 24,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 80,
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
                            _getHour(index),
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
                  ),
                );
              }
          ),
        ),
      ),
    );
  }

  Future<void> _loadData() async {
    if(firstRun){
      minTemp = await args.weatherMap['day']['mintemp_c'];
      maxTemp = await args.weatherMap['day']['maxtemp_c'];
      state = await args.weatherMap['day']['condition']['text'];
      setState(() {

      });
      firstRun = false;
    }
  }

  String _getHour(int index) {
    var date = DateTime(2000,1,1,(0+index));
    return DateFormat('HH:mm').format(date);
  }

  String _getTemp(int index) {
    double temp = args.weatherMap['hour'][index]['temp_c'];
    String st = temp.toString();
    return st;
  }

  String _getStatus(int index) {
    return args.weatherMap['hour'][index]['condition']['text'];
  }
}
