import 'package:gravitychamber/models/Task.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/subjects.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TaskList{
  BehaviorSubject _TaskList = BehaviorSubject.seeded([]);
  BehaviorSubject _CurrentTask = BehaviorSubject.seeded(Task());
  Stream get stream$ => _TaskList.stream;
  List get current => _TaskList.value;
  set current(List t) => {
    _TaskList.value = t ?? []
  };
  String get currentTask => _CurrentTask.value;
  set currentTask(String t) => _CurrentTask.value = t;

  void updateHive(){
    var box = Hive.box("tasks");
    box.put("tasks", current);
  }

  remove(String t){
    if(current.contains(t)) {
      current.remove(t);
      _TaskList.add(current);
      updateHive();
    }
  }
  add(String t){
    if(!current.contains(t)) {
      current.add(t);
      _TaskList.add(current);
      updateHive();
    }
  }


}