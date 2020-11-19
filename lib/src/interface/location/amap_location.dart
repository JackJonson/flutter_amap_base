import 'dart:async';
import 'dart:convert';

import 'package:amap_base/src/common/log.dart';
import 'package:amap_base/src/location/model/location.dart';
import 'package:amap_base/src/location/model/location_client_options.dart';
import 'package:flutter/services.dart';

abstract class AMapLocation {
  /// 初始化
  Future init();

  /// 只定位一次
  Future<Location> getLocation(LocationClientOptions options);

  /// 开始定位, 返回定位 结果流
  Stream<Location> startLocate(LocationClientOptions options);

  /// 结束定位, 但是仍然可以打开, 其实严格说是暂停
  Future stopLocate();
}
