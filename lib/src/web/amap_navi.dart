import 'package:amap_base/src/interface/navi/amap_navi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

AMapNavi createNavi()=>AMapWebNavi();

class AMapWebNavi extends AMapNavi{
  static AMapWebNavi _instance;

  AMapWebNavi._();

  factory AMapWebNavi() {
    if (_instance == null) {
      _instance = AMapWebNavi._();
      return _instance;
    } else {
      return _instance;
    }
  }

  @override
  void startNavi({
    @required double lat,
    @required double lon,
    int naviType = AMapNavi.drive,
  }) {
    debugPrint('Navigation is not support by web js api, only show the route planning.');
  }
}
