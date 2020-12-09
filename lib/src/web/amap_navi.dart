import 'package:amap_base/src/interface/navi/amap_navi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';

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
    String url='https://uri.amap.com/navigation?from=,我的位置&to=$lon,$lat,目的地&mode=car&policy=3&src=mypage&coordinate=gaode&callnative=0';
    launch(url);
    // debugPrint('Navigation is not support by web js api, only show the route planning.');
  }
}
