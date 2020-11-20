import 'dart:async';
import 'dart:convert';

import 'package:amap_base/src/common/log.dart';
import 'package:amap_base/src/interface/location/amap_location.dart';
import 'package:amap_base/src/location/model/location.dart';
import 'package:amap_base/src/location/model/location_client_options.dart';
import 'package:flutter/services.dart';

AMapLocation createLocation()=>AMapWebLocation();

class AMapWebLocation extends AMapLocation{
  static AMapWebLocation _instance;

  AMapWebLocation._();

  factory AMapWebLocation() {
    if (_instance == null) {
      _instance = AMapWebLocation._();
      return _instance;
    } else {
      return _instance;
    }
  }

  /// 初始化
  @override
  Future init() {

  }

  /// 只定位一次
  @override
  Future<Location> getLocation(LocationClientOptions options) {
    L.p('getLocation dart端参数: options.toJsonString() -> ${options.toJsonString()}');

    // _locationChannel.invokeMethod(
    //     'location#startLocate', {'options': options.toJsonString()});
    //
    // return _locationEventChannel
    //     .receiveBroadcastStream()
    //     .map((result) => result as String)
    //     .map((resultJson) => Location.fromJson(jsonDecode(resultJson)))
    //     .first;
  }

  /// 开始定位, 返回定位 结果流
  @override
  Stream<Location> startLocate(LocationClientOptions options) {
    print('startLocate dart端参数: options.toJsonString() -> ${options.toJsonString()}');

    // _locationChannel.invokeMethod(
    //     'location#startLocate', {'options': options.toJsonString()});
    //
    // return _locationEventChannel
    //     .receiveBroadcastStream()
    //     .map((result) => result as String)
    //     .map((resultJson) => Location.fromJson(jsonDecode(resultJson)));
  }

  /// 结束定位, 但是仍然可以打开, 其实严格说是暂停
  @override
  Future stopLocate() {
    // return _locationChannel.invokeMethod('location#stopLocate');
  }
}
