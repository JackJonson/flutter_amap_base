import 'dart:async';

import 'package:amap_base/src/interface/location/amap_location_stub.dart'
    if (dart.library.html) 'package:amap_base/src/web/amap_location.dart'
    if (dart.library.io) 'package:amap_base/src/location/amap_location.dart';
import 'package:amap_base/src/location/model/location.dart';
import 'package:amap_base/src/location/model/location_client_options.dart';

AMapLocation createAMapLocation() => createLocation();

class AMapLocation {
  /// 初始化
  Future init({String key}) {
    return createAMapLocation().init(key:key);
  }

  /// 只定位一次
  Future<Location> getLocation(LocationClientOptions options) {
    return createAMapLocation().getLocation(options);
  }

  /// 开始定位, 返回定位 结果流
  Stream<Location> startLocate(LocationClientOptions options) {
    return createAMapLocation().startLocate(options);
  }

  /// 结束定位, 但是仍然可以打开, 其实严格说是暂停
  Future stopLocate() {
    return createAMapLocation().stopLocate();
  }
}
