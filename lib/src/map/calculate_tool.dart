import 'dart:async';
import 'dart:convert';

import 'package:amap_base/src/interface/map/calculate_tool.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../map/model/latlng.dart';

CalculateTools createCalculateTools()=>CalculateMobileTools();

class CalculateMobileTools extends CalculateTools{
  static const _channel = MethodChannel('me.yohom/tool');

  static CalculateMobileTools _instance;

  CalculateMobileTools._();

  factory CalculateMobileTools() {
    if (_instance == null) {
      _instance = CalculateMobileTools._();
      return _instance;
    } else {
      return _instance;
    }
  }

  /// 转换坐标系
  ///
  /// [lat] 纬度
  /// [lon] 经度
  ///
  /// [type] 原坐标类型, 这部分请查阅高德地图官方文档
  @override
  Future<LatLng> convertCoordinate({
    @required double lat,
    @required double lon,
    @required LatLngType type,
  }) async {
    int intType = LatLngType.values.indexOf(type);

    String result = await _channel.invokeMethod(
      'tool#convertCoordinate',
      {
        'lat': lat,
        'lon': lon,
        'type': intType,
      },
    );

    if (result == null) {
      return null;
    }

    return LatLng.fromJson(jsonDecode(result));
  }

  @override
  Future<double> calcDistance(LatLng latLng1, LatLng latLng2) async {
    Map<String, dynamic> params = {
      "p1": latLng1.toJson(),
      "p2": latLng2.toJson(),
    };

    double length = await _channel.invokeMethod("tool#calcDistance", params);
    return length;
  }
}
