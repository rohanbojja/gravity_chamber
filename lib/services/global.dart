import 'package:gravitychamber/models/Settings.dart';

class GlobalObjects {
  Settings setting = Settings();
}
GlobalObjects globalObjects = GlobalObjects()..setting.workDur=Duration(minutes: 25)..setting.breakDur=Duration(minutes: 5);