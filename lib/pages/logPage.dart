import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gravitychamber/services/global.dart';

class logPage extends StatefulWidget {
  @override
  _logPageState createState() => _logPageState();
}



class _logPageState extends State<logPage> {
  List<Map<String, dynamic>> statList;
  int cc=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    custInit();
  }

  Future<void> custInit() async {
    statList = await globalObjects.allStats();
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
                    var TS = DateTime.fromMillisecondsSinceEpoch(statList.elementAt(index)["milsinceepoch"]);
                    return ListTile(
                      title: Text("${statList.elementAt(index)["name"]}"),
                      subtitle: Text("${TS.toString()} ${statList.elementAt(index)["duration"]} ${statList.elementAt(index)["work"]}"),
                    );
                  },
                )),
          ),
          Flexible(
            flex: 1,
            child: RaisedButton(
              onPressed: (){
                var fakeLabels = ["Gaming", "Coding", "Music", "Gym"];
                globalObjects.logData(fakeLabels[Random().nextInt(4)], Random().nextInt(60),Random().nextInt(2));
                cc+=1;
                setState(() {

                });
              },
              child: Text("FAKE DATA GEN"),
            ),
          )
        ]),
      ),
    );
  }
}
