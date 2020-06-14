import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'Task.g.dart';

@HiveType(typeId: 0)
class Task{
  @HiveField(0)
  String name;
  @HiveField(1)
  Color color;
  @HiveField(2)
  Duration goal;

  Task({String name, Color color, Duration goal}){
   this.name = name;
   this.color  = color;
   this.goal = goal;
  }
}