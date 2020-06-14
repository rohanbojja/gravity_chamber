import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:gravitychamber/models/Task.dart';
import 'package:gravitychamber/pages/timerPage.dart';

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
  Animation _animation;
  var _height=64.0;
  var _x=16.0;
  var tc;
  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
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
            expandedColor: widget.curTask.color.withAlpha(255),
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
                      print("Change color");
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: (){
                      print("Ediot");
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
