import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.black,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);

    int _background = int.parse(DateFormat('HH').format(_dateTime));
    String _backgroundColor;

    if (_background >= 18 || _background <= 5)
      _backgroundColor = "Night";
    else if (_background >= 11 && _background < 18)
      _backgroundColor = "Noon";
    else if (_background > 6 && _background <= 10)
      _backgroundColor = "Sunrise";
    else
      _backgroundColor = "Sunset";

    final minute = DateFormat('mm').format(_dateTime);

    int t = 1;
    double t2;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      t = 13;
      t2 = 15;
    } else {
      t = 4;
      t2 = 35;
    }

    double fontSize = MediaQuery.of(context).size.height / t;
    final offset = -fontSize / 7;
    TextStyle defaultStyle = TextStyle(
      color: colors[_Element.text],
      // fontFamily: 'PressStart2P',
      fontSize: fontSize,
      fontFamily: 'ProductSans',
      /* shadows: [
        Shadow(
          blurRadius: 10,
          color: Colors.grey,
          offset: Offset(5, 0),
        ),
      ],*/
    );

    TextStyle _timeStyle = TextStyle(
      fontFamily: 'ProductSans',
      fontSize: fontSize,
    );

    TextStyle _weatherStyle = TextStyle(
      fontFamily: 'ProductSans',
      fontSize: fontSize / 2.85,
    );

    return Scaffold(
      body: Stack(
        children: <Widget>[
          FlareActor(
            "assets/flare/background.flr",
            animation: _backgroundColor,
          ),
          Positioned(
            left: 10.0,
            top: 10.0,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        hour,
                        style: _timeStyle,
                      ),
                      Text(
                        ":",
                        style: _timeStyle,
                      ),
                      Text(
                        minute,
                        style: _timeStyle,
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.model.weatherString,
                        style: _weatherStyle,
                      ),
                      Center(
                        child: getWeatherIcon(widget.model.weatherCondition),
                      ),
                      SizedBox(
                        width: t2,
                      ),
                      Text(
                        widget.model.temperatureString,
                        style: _weatherStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Icon getWeatherIcon(weatherCondition) {
  switch (weatherCondition) {
    case WeatherCondition.foggy:
    case WeatherCondition.thunderstorm:
    case WeatherCondition.cloudy:
    case WeatherCondition.windy:
    case WeatherCondition.rainy:
      return Icon(
        Icons.wb_cloudy,
        size: 20.0,
      );
      break;
    case WeatherCondition.snowy:
      return Icon(
        Icons.ac_unit,
        size: 20.0,
      );
      break;
    case WeatherCondition.sunny:
      return Icon(
        Icons.wb_sunny,
        size: 20.0,
      );
      break;
    default:
      break;
  }
}
