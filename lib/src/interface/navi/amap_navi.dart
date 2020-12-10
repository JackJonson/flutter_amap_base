import 'package:meta/meta.dart';

import 'amap_navi_stub.dart'
    if (dart.library.html) 'package:amap_base/src/web/amap_navi.dart'
    if (dart.library.io) 'package:amap_base/src/navi/amap_navi.dart';

AMapNavi createNavigation() => createNavi();

class AMapNavi {
  static const drive = 0;
  static const walk = 1;
  static const ride = 2;

  void startNavi({
    @required double lat,
    @required double lon,
    String title,
    int naviType = drive,
  }) {
    createNavigation()
        .startNavi(lat: lat, lon: lon, title: title, naviType: naviType);
  }
}
