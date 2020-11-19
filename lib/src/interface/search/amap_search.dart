import 'dart:async';

import 'package:amap_base/amap_base.dart';
import 'package:amap_base/src/search/model/bus_station_result.dart';
import 'package:amap_base/src/search/model/drive_route_result.dart';
import 'package:amap_base/src/search/model/poi_item.dart';
import 'package:amap_base/src/search/model/poi_result.dart';
import 'package:amap_base/src/search/model/regeocode_result.dart';

abstract class AMapSearch {

  /// 搜索poi
  Future<PoiResult> searchPoi(PoiSearchQuery query);

  /// 搜索poi 周边搜索
  Future<PoiResult> searchPoiBound(PoiSearchQuery query);

  /// 搜索poi 多边形搜索
  Future<PoiResult> searchPoiPolygon(PoiSearchQuery query);

  /// 按id搜索poi
  Future<PoiItem> searchPoiId(String id);

  /// 道路沿途直线检索POI
  Future<RoutePoiResult> searchRoutePoiLine(RoutePoiSearchQuery query);

  /// 道路沿途多边形检索POI
  Future<RoutePoiResult> searchRoutePoiPolygon(RoutePoiSearchQuery query);

  /// 计算驾驶路线
  Future<DriveRouteResult> calculateDriveRoute(RoutePlanParam param);

  /// 地址转坐标 [name]表示地址，第二个参数表示查询城市，中文或者中文全拼，citycode、adcode
  Future<GeocodeResult> searchGeocode(String name, String city);

  /// 逆地理编码（坐标转地址）
  Future<ReGeocodeResult> searchReGeocode(
    LatLng point,
    double radius,
    int latLonType,
  );

  /// 距离测量 参考[链接](https://lbs.amap.com/api/android-sdk/guide/computing-equipment/distancesearch)
  ///
  /// type 分别对应
  Future<List<int>> distanceSearch(
      List<LatLng> origins, LatLng target, DistanceSearchType type);

  /// 公交站点查询
  ///
  /// [stationName] 公交站点名
  /// [city] 所在城市名或者城市区号
  Future<BusStationResult> searchBusStation(String stationName, String city);
}

enum DistanceSearchType {
  line,
  driver,
}
