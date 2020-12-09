import 'dart:async';
import 'dart:convert';

import 'package:amap_base/src/common/log.dart';
import 'package:amap_base/src/interface/location/amap_location.dart';
import 'package:amap_base/src/location/model/location.dart';
import 'package:amap_base/src/location/model/location_client_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

AMapLocation createLocation()=>AMapMobileLocation();

class AMapMobileLocation extends AMapLocation{
  static AMapMobileLocation _instance;

  static const _locationChannel = MethodChannel('me.yohom/location');
  static const _locationEventChannel = EventChannel('me.yohom/location_event');

  AMapMobileLocation._();

  factory AMapMobileLocation() {
    if (_instance == null) {
      _instance = AMapMobileLocation._();
      return _instance;
    } else {
      return _instance;
    }
  }

  /// 初始化
  @override
  Future init() {
    return _locationChannel.invokeMethod('location#init');
  }

  /// 只定位一次
  @override
  Future<Location> getLocation(LocationClientOptions options) {
    debugPrint('getLocation dart端参数: options.toJsonString() -> ${options.toJsonString()}');

    _locationChannel.invokeMethod(
        'location#startLocate', {'options': options.toJsonString()});

    return _locationEventChannel
        .receiveBroadcastStream()
        .map((result) => result as String)
        .map((resultJson) => Location.fromJson(jsonDecode(resultJson)))
        .first;
  }

  /// 开始定位, 返回定位 结果流
  @override
  Stream<Location> startLocate(LocationClientOptions options) {
    debugPrint('startLocate dart端参数: options.toJsonString() -> ${options.toJsonString()}');

    _locationChannel.invokeMethod(
        'location#startLocate', {'options': options.toJsonString()});

    return _locationEventChannel
        .receiveBroadcastStream()
        .map((result) => result as String)
        .map((resultJson) => Location.fromJson(jsonDecode(resultJson)));
  }

  /// 结束定位, 但是仍然可以打开, 其实严格说是暂停
  @override
  Future stopLocate() {
    return _locationChannel.invokeMethod('location#stopLocate');
  }
}
