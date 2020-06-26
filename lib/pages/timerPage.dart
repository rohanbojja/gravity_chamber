import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool notifInit =false;
  int minutes;
  Duration dur;
  Duration disp_dur;
  Timer _timer;
  bool _isBreak = false;
  final _taskList = getIt<TaskList>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    custInit();
  }

  Future<void> custInit() async {
    dur = globalObjects.setting.workDur;
    disp_dur = dur;
    _startTimer();
    setState(() {

    });
  }
  void logData(){
    var box = Hive.box("log");
    box.put("${DateTime.now().millisecondsSinceEpoch}", {
      "name" : _taskList.currentTask,
      "duration" : _isBreak==true? globalObjects.setting.breakDur.inSeconds:globalObjects.setting.workDur.inSeconds,
      "break" : _isBreak
    });
  }

  Future<void> notif(Duration dd, {String title, String body}) async {
    if(!notifInit){
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
      var initializationSettingsAndroid = AndroidInitializationSettings('mipmap/launcher_icon');
      var initializationSettingsIOS = IOSInitializationSettings();
      var initializationSettings = InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      notifInit=true;
    }
    print("SCHED: $dd,$title,$body");
    var scheduledNotificationDateTime =
    DateTime.now().add(dd);
    var androidPlatformChannelSpecifics =
    AndroidNotificationDetails('your other channel id',
        'your other channel name', 'your other channel description');
    var iOSPlatformChannelSpecifics =
    IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0,
        title,
        body,
        scheduledNotificationDateTime,
        platformChannelSpecifics, androidAllowWhileIdle: true);
  }


  void _startTimer() {
    var _tS = DateTime.now();
    if(_isBreak){
      notif(dur, title:"Great job! You're break is up.", body:"Time to get back to work!");
    }
    else{
      notif(dur, title:"Time to take a break!", body:"Chill for a bit?");
    }

    //FlutterBeep.beep();
    _timer = Timer.periodic(
        Duration(seconds: 1),
        (timer) => {
              setState(() {
                var elapsed = Duration(milliseconds: (DateTime.now().millisecondsSinceEpoch - _tS.millisecondsSinceEpoch));
                disp_dur = dur - elapsed;
                print(disp_dur);
                setState(() {

                });
              }),
              if (disp_dur.inSeconds == 0 && !_isBreak)
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
              else if (disp_dur.inSeconds == 0)
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
                      "${disp_dur.toString().substring(2,7)}",
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
