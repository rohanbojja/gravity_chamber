import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gravitychamber/services/global.dart';
import 'package:hive/hive.dart';

class logPage extends StatefulWidget {
  @override
  _logPageState createState() => _logPageState();
}



class _logPageState extends State<logPage> {
  var box = Hive.box("log");
  List statList = List();
  var statList2;
  int cc=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    custInit();
  }

  Future<void> custInit() async {
//    statList = await globalObjects.allStats(); TODO
    statList2 = box.toMap();
    statList2.forEach((key,element){
      var temp = element;
      print("KEY: $key");
      temp["ts"] = DateTime.fromMillisecondsSinceEpoch(int.parse(key));
      statList.add(temp);
    });
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Log"),
      ),
      body: SafeArea(
        child: Column(children: [
          Flexible(
            flex: 10,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ListView.builder(
                  itemCount: (statList?.length ?? 0),
                  itemBuilder: (context, index) {
                    var TS = statList.elementAt(index)["ts"];
                    return ListTile(
                      title: Text("${statList.elementAt(index)["name"]}"),
                      subtitle: Text("${TS.toString()} ${statList.elementAt(index)["duration"]} ${statList.elementAt(index)["break"]}"),
                    );
                  },
                )),
          ),
        ]),
      ),
    );
  }
}
