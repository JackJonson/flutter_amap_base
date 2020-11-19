import 'package:amap_base/src/interface/navi/amap_navi.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class AMapMobileNavi extends AMapNavi{
  static final _channel = MethodChannel('me.yohom/navi');

  static AMapMobileNavi _instance;

  AMapMobileNavi._();

  factory AMapMobileNavi() {
    if (_instance == null) {
      _instance = AMapMobileNavi._();
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
    _channel.invokeMethod(
      'navi#startNavi',
      {'lat': lat, 'lon': lon, 'naviType': naviType},
    );
  }
}
