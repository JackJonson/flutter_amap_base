import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

abstract class AMapNavi {
  static const drive = 0;
  static const walk = 1;
  static const ride = 2;

  void startNavi({
    @required double lat,
    @required double lon,
    int naviType = drive,
  });
}
