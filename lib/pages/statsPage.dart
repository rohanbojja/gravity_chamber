import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:gravitychamber/models/Task.dart';
import 'package:gravitychamber/services/global.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:hive/hive.dart';

class statsPage extends StatefulWidget {
  @override
  _statsPageState createState() => _statsPageState();
}

class Activity {
  String name;
  Duration duration;
  DateTime timeStamp;
  Activity(String name, int duration, {int mse}) {
    this.name = name;
    this.duration = Duration(seconds: duration);
    this.timeStamp = DateTime.fromMillisecondsSinceEpoch(mse);
  }
}

class _statsPageState extends State<statsPage> {
  var box = Hive.box("log");
  DateTime _selectedDate = DateTime.now();
  var statList;
  var seriesList = List<charts.Series<Activity, String>>();
  var seriesListDate = List<charts.Series<Activity, String>>();
  int cc = 0;
  bool _dayOnly = false;

  List<charts.Series<Activity, String>> _createData() {
    var data = List<Activity>();
    var tempMap = {};
    statList.forEach((key, element) {
      if (tempMap.containsKey(element["name"])) {
        tempMap[element["name"]] += element["duration"];
      } else {
        tempMap[element["name"]] = element["duration"];
      }
    });
//
    tempMap.forEach((key, value) {
      data.add(Activity(key, value, mse: 0));
    });
    return [
      new charts.Series<Activity, String>(
        id: 'Tasks',
        domainFn: (Activity act, _) => act.name,
        measureFn: (Activity act, _) => act.duration.inSeconds,
        data: data,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (Activity act, _) => '${act.name}',
      )
    ];
  }

  List<charts.Series<Activity, String>> _createDataDate() {
    var data = List<Activity>();
    var data2 = List<Activity>();
    var tempMap = {};
    var tempMap2 = {};
    statList.forEach((key, element) {
      if (element["break"] == 1) {
        if (tempMap.containsKey(element["name"])) {
          tempMap[element["name"]] += element["duration"];
        } else {
          tempMap[element["name"]] = element["duration"];
        }
      } else {
        if (tempMap2.containsKey(element["name"])) {
          tempMap2[element["name"]] += element["duration"];
        } else {
          tempMap2[element["name"]] = element["duration"];
        }
      }
    });

    tempMap.forEach((key, value) {
      data.add(Activity(key, value, mse: 0));
    });

    tempMap2.forEach((key, value) {
      data2.add(Activity(key, value, mse: 0));
    });

    return [
      new charts.Series<Activity, String>(
        id: 'Work',
        domainFn: (Activity act, _) => act.name,
        measureFn: (Activity act, _) => act.duration.inSeconds,
        data: data,
        colorFn: (_, __) => charts.MaterialPalette.indigo.shadeDefault,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (Activity act, _) => '${act.name}: ${act.duration}',
      ),
      new charts.Series<Activity, String>(
        id: 'Break',
        domainFn: (Activity act, _) => act.name,
        measureFn: (Activity act, _) => act.duration.inSeconds,
        data: data2,
        colorFn: (_, __) => charts.MaterialPalette.cyan.shadeDefault,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (Activity act, _) => '${act.name}: ${act.duration}',
      )
    ];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    custInit();
  }

  Future<void> custInit() async {
//    statList = await globalObjects.allStats(); TODO
    statList = box.toMap();
    if (statList != null) {
      print("STATLIST: $statList");
      //Fix stat list (Create aggregate for tasks)
      seriesList = _createData();
      seriesListDate = _createDataDate();
      print("${seriesList.length}");
      setState(() {});
    }
  }

  Future<bool> reInit() async {
//    statList = await globalObjects.allStats(); TODO
    statList = await box.toMap();
    if (statList != null) {
      var tempList = Map();
      statList.forEach((key, element) {
        var temp = element;
        //print("KEY: $key");
        temp["ts"] = DateTime.fromMillisecondsSinceEpoch(int.parse(key));
        var entryDate = temp["ts"];
        var selectedDate = _selectedDate;
        if (entryDate.year == selectedDate.year &&
            entryDate.month == selectedDate.month &&
            entryDate.day == selectedDate.day) {
          tempList[key] = element;
        }
      });
      if (_dayOnly) {
        statList = tempList;
      }
      print("STATLIST $_selectedDate: $statList");
      //Fix stat list (Create aggregate for tasks)
      seriesList = _createData();
      seriesListDate = _createDataDate();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Statistics"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: RaisedButton(
                child: Text("Single day / All-time"),
                onPressed: () {
                  _dayOnly = !_dayOnly;
                  reInit();
                  setState(() {});
                },
              ),
            ),
            _dayOnly
                ? Center(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_left),
                            onPressed: () {
                              _selectedDate = _selectedDate.subtract(Duration(days: 1));
                              reInit();
                              setState(() {});
                            },
                          ),
                          OutlineButton(
                            child: Text("${_selectedDate}"),
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime(2018, 3, 5),
                                  maxTime: DateTime.now(),
                                  onChanged: (date) {
                                print('change $date');
                              }, onConfirm: (date) {
                                _selectedDate = date;
                                print('confirm $date');
                                reInit();
                                setState(() {

                                });
                              },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_right),
                            onPressed: () {
                              _selectedDate = _selectedDate.add(Duration(days: 1));
                              reInit();
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                : Text("Stats since the beginning of time"),
            Container(
              height: 300,
              child: statList.length == 0
                  ? Center(child: Text("No stats available"))
                  : charts.PieChart(
                      seriesList,
                      animate: true,
                      defaultRenderer: new charts.ArcRendererConfig(
                          arcRendererDecorators: [
                            new charts.ArcLabelDecorator(
                                labelPosition: charts.ArcLabelPosition.inside)
                          ]),
                    ),
            ),
            Container(
              height: 200,
              child: statList.length == 0
                  ? Center(child: Text("No stats available"))
                  : charts.BarChart(
                      seriesListDate,
                      barGroupingType: charts.BarGroupingType.stacked,
                      animate: true,
                      vertical: false,
                      customSeriesRenderers: [
                        new charts.PointRendererConfig(
                            // ID used to link series to this renderer.
                            customRendererId: 'customPoint')
                      ],
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}
