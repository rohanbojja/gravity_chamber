import 'package:gravitychamber/models/Settings.dart';
import 'package:gravitychamber/models/Task.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GlobalObjects {
  Task currentTask;
  Settings setting = Settings();
  Database db;

  Future<void> initialiseDB() async {
    _onCreate(Database db, int version) async {
      // Database is created, create the table
      await db.execute(
          "CREATE TABLE Tasks (id INTEGER PRIMARY KEY, name TEXT)");
      await db.execute(
          "CREATE TABLE Stats (id INTEGER PRIMARY KEY, name TEXT, duration INTEGER, milsinceepoch INTEGER, work INTEGER)"); //0 -> work 1-> break
    }

    db = await openDatabase('tasks_stats.db',version: 1,
        onCreate: _onCreate);
  }

  Future<bool> addTask(String taskName ) async{
    await db.insert("Tasks",{
      "name":"$taskName"
    });
  }

  Future<List<Task>> allTasks() async{
    List<Task> taskList = List<Task>();
    
    List<Map<String,dynamic>> query = await db.query("tasks");
    query.forEach((element) {
      taskList.add(Task(name: element["name"]));
    });
    print("HELLO ${taskList.length}");
    return taskList;
  }

  Future<List<Map<String,dynamic>>> allStats() async{
    List<Map<String,dynamic>> statList = List<Map<String,dynamic>>();

    List<Map<String,dynamic>> query = await db.query("stats");
    query.forEach((element) {
      statList.add(element);
    });
    print("HELLO ${statList.length}");
    return statList;
  }

  Future<bool> resetDB() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tasks_stats.db");
    await db.close();
    await deleteDatabase(path);
    await initialiseDB();
  }


  Future<bool> removeTask(String taskName) async{
    await db.delete("Tasks",where: "name = ?", whereArgs: ["$taskName"]);
    return true;
  }
  Future<bool> logData(String taskName, int durationInSeconds, int work) async{
    var now = DateTime.now().millisecondsSinceEpoch;
    await db.insert("Stats",{
      "name":"$taskName",
      "duration": durationInSeconds,
      "milsinceepoch": now,
      "work": work
    });
    return true;
  }
}
GlobalObjects globalObjects = GlobalObjects()..setting.workDur=Duration(minutes: 25)..setting.breakDur=Duration(minutes: 5);