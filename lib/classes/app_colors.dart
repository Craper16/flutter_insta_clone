import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

final _brightness = SchedulerBinding.instance.window.platformBrightness;

class AppColors {
  final primary = _brightness == Brightness.dark
      ? CupertinoColors.black
      : CupertinoColors.white;
  final secondary = _brightness == Brightness.dark
      ? CupertinoColors.white
      : CupertinoColors.black;
  final accent = CupertinoColors.activeBlue;
}

final appColors = AppColors();
