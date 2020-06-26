import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gravitychamber/components/AnimatedCard.dart';
import 'package:gravitychamber/pages/taskPage.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:gravitychamber/components/TaskList.dart';
import 'package:gravitychamber/pages/logPage.dart';
import 'package:gravitychamber/pages/settingsPage.dart';
import 'package:gravitychamber/pages/statsPage.dart';
import 'package:gravitychamber/pages/timerPage.dart';
import 'package:persist_theme/data/models/theme_model.dart';
import 'package:persist_theme/ui/switches/dark_mode.dart';
import 'package:persist_theme/persist_theme.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/Task.dart';

var myTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Montserrat',
  accentColor: Colors.black,
  primaryColor: Colors.white,
  primarySwatch: Colors.green,
  cursorColor: Color(0xFF3C5AFD),
  toggleableActiveColor: Colors.amber,
);

var myThemeDark = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Montserrat',
  accentColor: Colors.white,
  primaryColor: Colors.black,
  primarySwatch: Colors.grey,
  canvasColor: Colors.black,
  cursorColor: Color(0xFF3C5AFD),
  toggleableActiveColor: Colors.amber,
);

GetIt getIt = new GetIt.asNewInstance();
void main() {
  getIt.registerSingleton<TaskList>(TaskList());
  runApp(MyApp());
}

final _model =
    ThemeModel(customLightTheme: myTheme, customDarkTheme: myThemeDark);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListenableProvider<ThemeModel>(
        create: (_) => _model..init(),
        child: Consumer<ThemeModel>(
          builder: (context, model, child) {
            return MaterialApp(
              title: 'Gravity Chamber',
              theme: _model.theme,
              home: MyHomePage(title: 'Gravity Chamber'),
            );
          },
        ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var box = Hive.box("log");
  final taskList = getIt.get<TaskList>();
  //Textcontrollers
  TextEditingController _addLabelController = TextEditingController();
  TextEditingController _goalTextController = TextEditingController();
  Color pickerColor = Colors.cyanAccent;
  Color currentColor = Colors.cyanAccent;
  Duration dur1, dur2;

  //START INIT
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    custInit();
  }

  Future<void> custInit() async {
    //await globalObjects.initialiseDB();
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    var box = await Hive.openBox('tasks');
    await Hive.openBox("log");
    taskList.load();
//    taskList = await globalObjects.allTasks();
  }
  //END INIT

  void _startTask(int index) {}

  Color randomColor() {
    Random random = new Random();
    int randomNumber = random.nextInt(5);
    List<Color> clr = [
      Colors.cyan,
      Colors.lightGreen,
      Colors.deepPurple,
      Colors.pink,
      Colors.deepOrange
    ];
    return clr[randomNumber];
  }

  Future<void> _addTask() async {
    Task t  = new Task(goal: Duration(hours: 3),color: Colors.grey);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new TaskPage(t)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(),
              accountName: Text(
                "Some dude",
                style: Theme.of(context).textTheme.headline6,
              ),
              accountEmail: Text(
                "Some email",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text("Log"),
              onTap: () => {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => logPage()))
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => settingsPage()))
              },
            ),
            ListTile(
              leading: Icon(Icons.multiline_chart),
              title: Text("Statistics"),
              onTap: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => statsPage()))
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text("About"),
              onTap: () => {
                showAboutDialog(
                  applicationIcon: Icon(Icons.done_outline),
                  context: context,
                  children: [Text("Yet Another Time Management Application.")],
                  applicationVersion: "1.0.0ALPHA",
                ),
              },
            ),
            DarkModeSwitch()
          ],
        ),
      ),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.reply_all,
            ),
            onPressed: () {
              taskList.add(Task(
                  name: "Music",
                  color: randomColor(),
                  goal: Duration(minutes: 30)));
              taskList.add(Task(
                  name: "Work",
                  color: randomColor(),
                  goal: Duration(minutes: 30)));
              taskList.add(Task(
                  name: "Coding",
                  color: randomColor(),
                  goal: Duration(minutes: 30)));
              taskList.add(Task(
                  name: "Youtube",
                  color: randomColor(),
                  goal: Duration(minutes: 30)));
            },
          )
        ],
        //iconTheme: IconThemeData(color: Colors.green),
        centerTitle: true,
        title: Text(
          'Tasks',
          style: Theme.of(context).textTheme.headline4,
        ),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, a
      ),
      body: StreamBuilder(
          stream: taskList.stream$,
          builder: (BuildContext context, AsyncSnapshot snap) {
            print("STREAM ${snap.data}");
            var obj = snap.data as Map;
            if (obj != null && obj.length > 0) {
              var tmp = [];
              obj.forEach((key, value) {
                tmp.add(key);
              });
              print("AS LIST $tmp");
              return SingleChildScrollView(
                child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: obj.length ?? 0,
                  itemBuilder: (context, index) {
                    var curTask = obj[tmp[index]] as Task;
                    var uq = UniqueKey();
                    print("${curTask.name} $uq");
                    return AnimatedCard(
                      curTask: curTask,
                      cb1: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => new timerPage())),
                        taskList.startTask(curTask.name)
                      },
                      cb2: () => {
                        taskList.remove(curTask.name),
                      },
                      cb3: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => new TaskPage(curTask))),
                      },
                      uq: uq,
                    );
                  },
                ),
              );
            } else {
              return Center(
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text("Add a task to get started!")),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add a task',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
