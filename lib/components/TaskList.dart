import 'package:gravitychamber/models/Task.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/subjects.dart';
import 'package:flutter/material.dart';

class TaskList{
  BehaviorSubject _taskMap = BehaviorSubject.seeded({});
  BehaviorSubject _CurrentTask = BehaviorSubject.seeded("");


  load()
  {
    var box = Hive.box("tasks");
    box?.toMap()["tasks"]?.forEach((v) {
      String name;
      Color color;
      Duration goal;
      _taskMap.value["${v["name"]}"] = Task(name: v["name"],color: Color((v["color"])), goal: Duration(seconds: v["goal"]) );
    });
    print ("HIVE LOAD: ${box.toMap()}");
    _taskMap.add(taskMap);
  }
  Stream get stream$ => _taskMap.stream; //Pass to streambuilders
  Map get taskMap =>_taskMap.value;
  String get currentTask => _CurrentTask.value; //Current task
  set currentTask(String t) => _CurrentTask.value = t; //Set current task


  //Custom adapter
  makeList(){
    var l =[];
    taskMap.forEach((k,v){
      l.add({
        "name" : k,
        "color": v.color.value,
        "goal": v.goal.inSeconds
      });
    });
    return l;
  }

  void updateHive(){
    var box = Hive.box("tasks");
    box.put("tasks", makeList());
    print ("CURRENT: $_taskMap");
    print ("HIVE: ${box.toMap()}");
    _taskMap.add(taskMap);
  }

  Future<void> deleteDB() async {
    await Hive.box("tasks").clear();
  }

  remove(String t){
    if(_taskMap.value.containsKey(t)) {
      print("BF: ${_taskMap.value}");
      taskMap.remove(t);
      print("AF: ${_taskMap.value}");
      _taskMap.add(taskMap);
      updateHive();
    }
  }
  add(Task t){
    //Add the name to a list and send an update event through the stream
    print("Task received ${t.name}");
    if(!taskMap.containsKey(t.name)){
      taskMap[t.name] = t;
      _taskMap.add(taskMap);
      print("Task exists ${_taskMap.value.containsKey(t.name)}");
      updateHive();
    }
  }

  update(Task t){
    //Add the name to a list and send an update event through the stream
    print("Task received for update ${t.name}");
    if(taskMap.containsKey(t.name)){
      taskMap[t.name] = t;
      _taskMap.add(taskMap);
      print("Task update ${_taskMap.value.containsKey(t.name)}");
      updateHive();
    }
  }

  startTask(String t){
    currentTask = t;
    //Hack to make list view work with dismissible
    var tempTask  = taskMap[t];
    taskMap.remove(t);
    taskMap[t] = tempTask;
    _taskMap.add(taskMap);
  }
}