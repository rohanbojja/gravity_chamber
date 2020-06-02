import 'package:flutter/material.dart';
import 'package:gravitychamber/models/Task.dart';
import 'package:gravitychamber/services/global.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class statsPage extends StatefulWidget {
  @override
  _statsPageState createState() => _statsPageState();
}

class Activity{
  String name;
  Duration duration;
  DateTime timeStamp;
  Activity(String name, int duration, {int mse}){
    this.name = name;
    this.duration = Duration(seconds: duration);
    this.timeStamp = DateTime.fromMillisecondsSinceEpoch(mse);
  }
}

class _statsPageState extends State<statsPage> {
  List<Map<String, dynamic>> statList;
  var seriesList = List<charts.Series<Activity,String>>();
  var seriesListDate = List<charts.Series<Activity,String>>();
  int cc=0;
  bool todayOnly = false;

  List<charts.Series<Activity, String>> _createData() {
    var data = List<Activity>();
    var tempMap ={};
    statList.forEach((element) {
      if(tempMap.containsKey(element["name"])){
        tempMap[element["name"]] += element["duration"];
      }else{
        tempMap[element["name"]] = element["duration"];
      }
    });

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
    var tempMap ={};
    var tempMap2 ={};
    statList.forEach((element) {
      if(element["work"]==0){
        if(tempMap.containsKey(element["name"])){
          tempMap[element["name"]] += element["duration"];
        }else{
          tempMap[element["name"]] = element["duration"];
        }
      }else{
        if(tempMap2.containsKey(element["name"])){
          tempMap2[element["name"]] += element["duration"];
        }else{
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
    statList = await globalObjects.allStats();

    //Fix stat list (Create aggregate for tasks)
    seriesList = _createData();
    seriesListDate = _createDataDate();
    print("${seriesList.length}");
    setState(() {

    });
  }

  Future<bool> reInit() async{
    statList = await globalObjects.allStats();
    var tempList = List<Map<String,dynamic>>();
    statList.forEach((element) {
      var entryDate = DateTime.fromMillisecondsSinceEpoch(element["milsinceepoch"]);
      var todayDate = DateTime.now();
      if(entryDate.year == todayDate.year && entryDate.month == todayDate.month && entryDate.day == todayDate.day){
        tempList.add(element);
      }
    });
    if(todayOnly){
      statList = tempList;
    }
    print("CURRENT: ${statList.length}");
    //Fix stat list (Create aggregate for tasks)
    seriesList = _createData();
    seriesListDate = _createDataDate();
    setState(() {

    });
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
            RaisedButton(child: Text("Toggle"), onPressed: (){
              todayOnly = !todayOnly;
              reInit();
              setState(() {

              });
            },),
            Text("${todayOnly ? "Only today's data" :"Stats since epoch"}"),
            Container(
              height: 300,
              child: charts.PieChart(seriesList,
                  animate: true,
                  defaultRenderer: new charts.ArcRendererConfig(arcRendererDecorators: [
                    new charts.ArcLabelDecorator(
                        labelPosition: charts.ArcLabelPosition.inside)
                  ]),),
            ),
            Container(
              height: 200,
              child: charts.BarChart(
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
