import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:gravitychamber/services/global.dart';
import 'package:gravitychamber/widgets/duration_picker.dart';

class settingsPage extends StatefulWidget {
  @override
  _settingsPageState createState() => _settingsPageState();
}

class _settingsPageState extends State<settingsPage> {


  void retrieveDuration(int type) async {
    Duration resultingDuration = await showDurationPicker(
      context: context,
      initialTime: new Duration(minutes: 30),
    );
    if(type==0){
      globalObjects.setting.workDur = resultingDuration ?? globalObjects.setting.workDur;
    }else{
      globalObjects.setting.breakDur = resultingDuration ?? globalObjects.setting.breakDur;
    }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              ListTile(
                title: Text("Work duration"),
                subtitle: Text("${globalObjects.setting.workDur.toString().substring(2,4)} minutes"),
                onTap: (){
                  retrieveDuration(0);
                },
              ),
              ListTile(
                title: Text("Break duration"),
                subtitle: Text("${globalObjects.setting.breakDur.toString().substring(2,4)} minutes"),
                onTap: (){
                  retrieveDuration(1);
                },
              ),
              ListTile(
                title: Text("RESET DATA"),
                subtitle: Text("ALL DATA WILL BE LOST!"),
                onTap: () async {
                  await globalObjects.resetDB();
                  Phoenix.rebirth(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
