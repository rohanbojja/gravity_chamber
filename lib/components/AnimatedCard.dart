import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gravitychamber/components/TaskList.dart';
import 'package:gravitychamber/main.dart';
import 'package:gravitychamber/models/Task.dart';

class AnimatedCard extends StatefulWidget {
  final Task curTask;
  final VoidCallback cb1;
  final VoidCallback cb2;
  final VoidCallback cb3;
  final UniqueKey uq;

  const AnimatedCard({@required Task this.curTask,VoidCallback this.cb1,VoidCallback this.cb2,VoidCallback this.cb3,@required UniqueKey this.uq});
  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> with TickerProviderStateMixin {
  bool isSelected = false;
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);
  Animation _animation;
  var _height=64.0;
  var _x=16.0;
  var tc;
  @override
  void initState() {
    super.initState();
    print("Init state!  ");
    currentColor = widget.curTask.color;
  }
  void upd(){
    print("${widget.curTask.color.toString()}");
    setState(() {

    });
  }
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }
  @override
  Widget build(BuildContext context) {
    currentColor = widget.curTask.color;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: GestureDetector(
        onTap: (){
          print("Card selection: $isSelected");
          setState(() {
            if(isSelected){
            }else{
            }
            isSelected=!isSelected;
          });
        },
        child: Dismissible(
          child: ExpansionTileCard(
            borderRadius: BorderRadius.circular(5),
            baseColor: widget.curTask.color,
            expandedColor: currentColor.withAlpha(255),
            title: Text(widget.curTask.name, style: TextStyle(color: Colors.white),),
            children: [
              Divider(),
              LinearProgressIndicator(
                backgroundColor: Theme.of(context).primaryColorLight,
                value: 0.5,
              ),
              ButtonBar(
                children: [
                  IconButton(
                    icon: Icon(Icons.color_lens),
                    onPressed: (){
                      showDialog(
                        context: context,
                        child: AlertDialog(
                          title: const Text('Pick a color!'),
                          content: SingleChildScrollView(
                             child: BlockPicker(
                               pickerColor: currentColor,
                               onColorChanged: changeColor,
                             ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: const Text('Got it'),
                              onPressed: () {
                                print("Updated!");
                                var tsk = getIt<TaskList>();
                                currentColor = pickerColor;
                                widget.curTask.color = currentColor;
                                tsk.updateHive();
                                Navigator.of(context).pop();
                                upd();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: (){
                      print("Edit");
                      widget.cb3();
                    },
                  ),

                ],
              )
            ],
          ),
          background: Container(
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 16),child: Align(alignment: Alignment.centerLeft ,child: Icon(Icons.access_time,color: Colors.white,))),
            color: Colors.green,
          ),
          secondaryBackground: Container(
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 16),child: Align(alignment: Alignment.centerRight ,child: Icon(Icons.delete_sweep,color: Colors.white,))),
            color: Colors.red,
          ),
          key: widget.uq,
          onDismissed: (direction) async => {
            if (direction ==
                DismissDirection.startToEnd)
              {
                print("STE"),
                widget.cb1(),
              }
            else
              {
              print("ETS"),
                widget.cb2(),
              }
          },
        ),
      ),
    );
  }
}
