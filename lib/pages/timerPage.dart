import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'dart:async';

import 'package:gravitychamber/services/global.dart';

class timerPage extends StatefulWidget {
  @override
  _timerPageState createState() => _timerPageState();
}

class _timerPageState extends State<timerPage> {
  int minutes;
  Duration dur;
  Timer _timer;
  bool _break=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    custInit();
  }

  void custInit(){
    dur = globalObjects.currentTask.workDur;
    _startTimer();
  }
  void _startTimer(){
    FlutterBeep.beep();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => {
        if(dur.inSeconds == 0 && !_break){
          //Send a notification / ALERT
          _timer.cancel(),
          _break = true,
          _startBreak(),
          FlutterBeep.playSysSound(41),
        }else if(dur.inSeconds == 0){
          FlutterBeep.beep(false),
          _timer.cancel(),
          Navigator.of(context).pop(false),
        },
        setState((){
          dur = dur - Duration(seconds: 1);
        })
    });
  }
  Future<bool> _startBreak() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Start your break?'),
        actions: <Widget>[
          new OutlineButton(
            onPressed: () => {
              Navigator.of(context).pop(false),
              dur = globalObjects.currentTask.breakDur,
              setState((){})
            },
            child: new Text('No'),
          ),
          new RaisedButton(
            onPressed: () => {
              Navigator.of(context).pop(true),
              dur = globalObjects.currentTask.breakDur,
              _startTimer()
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
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
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
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
                  child: Text("${globalObjects.currentTask.name}",style: Theme.of(context).textTheme.headline5,),
                ),
                Flexible(
                  flex: 15,
                  child: Text("${dur.toString().substring(2,7)}",style: Theme.of(context).textTheme.headline1,),
                ),
                Flexible(
                  flex: 1,
                  child: Center(
                    child: ButtonBar(
                      children: [
                        OutlineButton(child: Text("Pause"), onPressed: _timer?.isActive? () {
                          _timer.cancel();
                          setState(() {

                          });
                        } : null,),
                        RaisedButton(child: Text("Start"),onPressed: _timer?.isActive? null : _startTimer,),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
