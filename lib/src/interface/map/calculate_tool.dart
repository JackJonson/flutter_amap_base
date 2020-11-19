import 'dart:async';

import 'package:amap_base/src/map/model/latlng.dart';
import 'package:meta/meta.dart';

abstract class CalculateTools {

  /// 转换坐标系
  ///
  /// [lat] 纬度
  /// [lon] 经度
  ///
  /// [type] 原坐标类型, 这部分请查阅高德地图官方文档
  Future<LatLng> convertCoordinate({
    @required double lat,
    @required double lon,
    @required LatLngType type,
  });

  Future<double> calcDistance(LatLng latLng1, LatLng latLng2);
}

enum LatLngType {
  gps,
  baidu,
  mapBar,
  mapABC,
  soSoMap,
  aliYun,
  google,
}
