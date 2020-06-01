import 'package:flutter/material.dart';
class Task{
  String name;
  Color color = Colors.cyanAccent;
  int id;
  Duration workDur;
  Duration breakDur;
  Task({String name, Duration dur1, Duration dur2, Color color }){
   this.name = name;
   this.workDur = dur1;
   this.breakDur = dur2;
   this.color = color;
  }
}