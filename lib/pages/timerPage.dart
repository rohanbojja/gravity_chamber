import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:get_it/get_it.dart';
import 'package:gravitychamber/components/TaskList.dart';
import 'package:gravitychamber/main.dart';
import 'dart:async';

import 'package:gravitychamber/services/global.dart';
import 'package:hive/hive.dart';

class timerPage extends StatefulWidget {
  @override
  _timerPageState createState() => _timerPageState();
}

class _timerPageState extends State<timerPage> {
  int minutes;
  Duration dur;
  Timer _timer;
  bool _isBreak = false;
  final _taskList = getIt<TaskList>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    custInit();
  }

  void custInit() {
    dur = globalObjects.setting.workDur;
    _startTimer();
  }
  void logData(){
    var box = Hive.box("log");
    box.put("${DateTime.now().millisecondsSinceEpoch}", {
      "name" : _taskList.currentTask,
      "duration" : _isBreak==true? globalObjects.setting.breakDur.inSeconds:globalObjects.setting.workDur.inSeconds,
      "break" : _isBreak
    });
  }


  void _startTimer() {
    //FlutterBeep.beep();
    _timer = Timer.periodic(
        Duration(seconds: 1),
        (timer) => {
              setState(() {
                dur = dur - Duration(seconds: 1);
              }),
              if (dur.inSeconds == 0 && !_isBreak)
                {
                  //Send a notification / ALERT
                  _timer.cancel(),
                  //Log the work here
                  logData(),
                  _isBreak = true,
                  AwesomeDialog(
                      context: context,
                      animType: AnimType.BOTTOMSLIDE,
                      headerAnimationLoop: false,
                      dialogType: DialogType.SUCCES,
                      title: "Time to take a break!",
                      desc: 'Chill for a bit?',
                      btnOkOnPress: () {
                        debugPrint('OnClcik');
                        _startBreak();
                      },
                      btnCancelOnPress: () {
                        Navigator.of(context).pop(false);
                      },
                      onDissmissCallback: () {
                        dur = globalObjects.setting.breakDur;
                        setState(() {

                        });
                      },
                      btnOkIcon: Icons.check_circle,
                      btnOkText: "Yes",
                      btnCancelText: "NO!",
                      )
                    ..show()
                }
              else if (dur.inSeconds == 0)
                {
                  _timer.cancel(),
                  logData(),
                  AwesomeDialog(
                      context: context,
                      animType: AnimType.BOTTOMSLIDE,
                      headerAnimationLoop: false,
                      dialogType: DialogType.SUCCES,
                      title: "Great job! You're break is up.",
                      desc: 'Time to get back to work!',
                      btnOkOnPress: () {
                      },
                      btnOkIcon: Icons.check_circle,
                      onDissmissCallback: () {
                        debugPrint('Dialog Dissmiss from callback');
                        _timer.cancel();
                        Navigator.pop(context);
                      })
                    ..show(),
                },
            });
  }

  Future<bool> _startBreak() async {
    dur = globalObjects.setting.breakDur;
    _startTimer();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Do you want to discard?'),
            actions: <Widget>[
              new OutlineButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new RaisedButton(
                onPressed: () =>
                    {_timer.cancel(), Navigator.of(context).pop(true)},
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(
                      _isBreak==true? "Break":"${_taskList.currentTask}",
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  Flexible(
                    flex: 15,
                    child: Text(
                      "${dur.toString().substring(2, 7)}",
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Center(
                      child: ButtonBar(
                        children: [
                          OutlineButton(
                            child: Text("Pause"),
                            onPressed: _timer?.isActive
                                ? () {
                                    _timer.cancel();
                                    setState(() {});
                                  }
                                : null,
                          ),
                          RaisedButton(
                            child: Text("Start"),
                            onPressed: _timer?.isActive ? null : _startTimer,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
