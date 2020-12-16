import 'dart:async';

import 'package:amap_base/src/interface/map/calculate_tool.dart';
import 'package:js/js.dart';
import 'package:meta/meta.dart';

import '../map/model/latlng.dart';
import 'amapjs.dart';

CalculateTools createCalculateTools() => CalculateWebTools();

class CalculateWebTools extends CalculateTools {
  static CalculateWebTools _instance;

  CalculateWebTools._();

  factory CalculateWebTools() {
    if (_instance == null) {
      _instance = CalculateWebTools._();
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
    Completer<LatLng> completer = Completer();
    switch (type) {
      case LatLngType.gps:
        convertFrom(LngLat(lon, lat), 'gps',
            allowInterop((status, ConvertorResult result) {
          if (result.locations?.isNotEmpty ?? false) {
            completer.complete(
              LatLng(
                result.locations[0].getLat(),
                result.locations[0].getLng(),
              ),
            );
          } else {
            completer.completeError('convert coordinate failed');
          }
        }));
        break;
      case LatLngType.baidu:
        convertFrom(LngLat(lon, lat), 'baidu',
            allowInterop((status, ConvertorResult result) {
          if (result.locations?.isNotEmpty ?? false) {
            completer.complete(
              LatLng(
                result.locations[0].getLat(),
                result.locations[0].getLng(),
              ),
            );
          } else {
            completer.completeError('convert coordinate failed');
          }
        }));
        break;
      case LatLngType.mapBar:
        convertFrom(LngLat(lon, lat), 'mapbar',
            allowInterop((status, ConvertorResult result) {
          if (result.locations?.isNotEmpty ?? false) {
            completer.complete(
              LatLng(
                result.locations[0].getLat(),
                result.locations[0].getLng(),
              ),
            );
          } else {
            completer.completeError('convert coordinate failed');
          }
        }));
        break;
      default:
        completer
            .completeError('convert coordinate failed, unknown coordinate');
        break;
    }
    return completer.future;
  }

  @override
  Future<double> calcDistance(LatLng latLng1, LatLng latLng2) async {
    double distance = GeometryUtil.distance(
      LngLat(latLng1.longitude, latLng1.latitude),
      LngLat(latLng2.longitude, latLng2.latitude),
    );
    return Future.value(distance);
  }
}
