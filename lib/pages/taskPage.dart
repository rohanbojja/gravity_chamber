import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gravitychamber/components/TaskList.dart';
import 'package:gravitychamber/main.dart';
import 'package:gravitychamber/models/Task.dart';
import 'package:gravitychamber/widgets/duration_picker.dart';

class TaskPage extends StatefulWidget {
  Task receivedTask;
  TaskPage(@required this.receivedTask);
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  TextEditingController _labelTextController = TextEditingController();
  Duration _goalDuration = Duration(minutes: 30);
  var taskList = getIt<TaskList>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    custInit();
  }

  void custInit() {
    _labelTextController.text = widget.receivedTask.name;
    _goalDuration = widget.receivedTask.goal;
    setState(() {});
    _labelTextController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Card(
            color: widget.receivedTask.color,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    "${_labelTextController.text}",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: TextField(
                      controller: _labelTextController,
                      decoration:
                      InputDecoration(hintText: "Name of the task. ex: Work"),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: OutlineButton(
                      color: Theme.of(context).primaryColorDark,
                      child: Text("Daily goal: $_goalDuration h/m/s", style: Theme.of(context).textTheme.overline,),
                      onPressed: () async {
                        _goalDuration = await showDurationPicker(
                          context: context,
                          initialTime: new Duration(minutes: 30),
                        ) ?? _goalDuration;
                        Task t = widget.receivedTask;
                        t.goal = _goalDuration;
                        t.name = _labelTextController.text;
                        setState(() {

                        });
                      },
                    ),
                  ),
                  ButtonBar(
                    children: [
                      RaisedButton(child: Text("Discard"),
                      onPressed: (){
                        Navigator.of(context).pop();
                      },),
                      RaisedButton(
                        child: Text("Save"),
                        onPressed: (){
                          Task t = widget.receivedTask;
                          t.goal = _goalDuration;
                          t.name = _labelTextController.text;
                          taskList.update(t);
                          setState(() {

                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
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
