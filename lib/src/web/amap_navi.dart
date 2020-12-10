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
    String title,
    int naviType = AMapNavi.drive,
  }) {

    String url='https://uri.amap.com/navigation?to=$lon,$lat,$title&mode=car&policy=3&src=mypage&coordinate=gaode&callnative=1';
    // String url='https://uri.amap.com/marker?position=$lon,$lat&name=$title&src=智维保&coordinate=gaode&callnative=1';

    launch(url,);
    // debugPrint('Navigation is not support by web js api, only show the route planning.');
  }
}
