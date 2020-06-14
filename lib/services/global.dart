import 'package:gravitychamber/models/Settings.dart';

class GlobalObjects {
  Settings setting = Settings();
}
GlobalObjects globalObjects = GlobalObjects()..setting.workDur=Duration(seconds: 2)..setting.breakDur=Duration(seconds: 2);