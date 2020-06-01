import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gravitychamber/pages/timerPage.dart';
import 'package:gravitychamber/services/global.dart';
import 'package:package_info/package_info.dart';

import 'models/Task.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gravity Chamber',
      theme: ThemeData(
        brightness: Brightness.dark,
        canvasColor: Colors.black,
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.lime,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Gravity Chamber'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Task> taskList = List<Task>();
  //Textcontrollers
  TextEditingController _addLabelController = TextEditingController();
  TextEditingController _dur1C = TextEditingController();
  TextEditingController _dur2C = TextEditingController();
  Color pickerColor = Colors.cyanAccent;
  Color currentColor = Colors.cyanAccent;
  Duration dur1,dur2;

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }
  //START color picker
  Future<void> showColorPicker() async {

// raise the [showDialog] widget
    await showDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: MaterialPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
//            showLabel: true,
//            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Got it'),
            onPressed: () {
              setState(() => currentColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
    Navigator.pop(context);
    _addLabel();
  }

  //END color picker


  Future<void> _addLabel() async {
    var newTask = await showDialog<Task>(context: context, builder: (BuildContext context){
      return SimpleDialog(
        title: Wrap(
          children: [InkWell(
            onTap: showColorPicker,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                height: 25,
                width: 25,
                color: pickerColor,
              ),
            ),
          ),Text("New task")]
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Wrap(
              children: [
                TextField(
                  controller: _dur1C,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: "Work duration, ex: 25"),
                ),
                TextField(
                  controller: _dur2C,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: "Break duration, ex: 5"),
                ),
                TextField(
                  controller: _addLabelController,
                  decoration: InputDecoration(hintText: "Label, ex: College work"),
                )
              ],
            ),
          ),
          ButtonBar(
            children: [
              OutlineButton(
                child: Text("Discard"),
                onPressed: () => {
                  Navigator.pop(context)
                },
              ),
              RaisedButton(
                child: Text("Add"),
                onPressed: () => {
                Navigator.pop(context, Task(name: _addLabelController.text, dur1: Duration(minutes: int.parse(_dur1C.text)),dur2: Duration(minutes: int.parse(_dur2C.text)), color: currentColor ))
              },
              )
            ],
          )
        ],
      );
    });
    setState(() {
      if(newTask!=null){
        taskList.add(newTask);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: ()=>{

              },
            ),
            ListTile(
              leading: Icon(Icons.multiline_chart),
              title: Text("Statistics"),
              onTap: ()=>{

              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text("About"),
              onTap: ()=>{
                showAboutDialog(
                  applicationIcon: Icon(Icons.done_outline),
                  context: context,
                  applicationVersion: "1.0.0",
                ),
              },
            )
          ],
        ),
      ),
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, a
        backgroundColor: Colors.black,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          children: <Widget>[
            Flexible(
              flex: 8,
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Tasks',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ),
                  SafeArea(
                    child: taskList.length==0? Padding(padding: EdgeInsets.symmetric(vertical: 32),child: Text("Add a task to get started!")) :  Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: taskList.length ?? 0,
                        itemBuilder: (context,index){
                          return Card(
                            child: Dismissible(
                              child: ListTile(
                                leading: Container(width:20, height: 20,color: taskList.elementAt(index).color),
                                title: Text(taskList.elementAt(index).name),
                              ),
                              background: Container(color: Colors.green,),
                              secondaryBackground: Container(color: Colors.red,),
                              key: UniqueKey(),
                              onDismissed: (direction) => {
                                if(direction==DismissDirection.startToEnd){
                                  globalObjects.currentTask = taskList.elementAt(index),
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => new timerPage())),
                                  taskList.add(taskList.elementAt(index)),
                                  taskList.removeAt(index),
                                  setState((){})
                                }else{

                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  )
                  ,
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLabel,
        tooltip: 'Add a label',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
