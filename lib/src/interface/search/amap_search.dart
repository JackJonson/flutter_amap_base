import 'dart:async';

import 'package:amap_base/src/map/model/latlng.dart';
import 'package:amap_base/src/search/model/bus_station_result.dart';
import 'package:amap_base/src/search/model/drive_route_result.dart';
import 'package:amap_base/src/search/model/geocode_result.dart';
import 'package:amap_base/src/search/model/poi_item.dart';
import 'package:amap_base/src/search/model/poi_result.dart';
import 'package:amap_base/src/search/model/poi_search_query.dart';
import 'package:amap_base/src/search/model/regeocode_result.dart';
import 'package:amap_base/src/search/model/route_plan_param.dart';
import 'package:amap_base/src/search/model/route_poi_result.dart';
import 'package:amap_base/src/search/model/route_poi_search_query.dart';
import 'package:amap_base/src/interface/search/amap_search_stub.dart'
    if (dart.library.html) 'package:amap_base/src/web/amap_search.dart'
    if (dart.library.io) 'package:amap_base/src/search/amap_search.dart';

AMapSearch createAMapSearch() => createSearch();

class AMapSearch {
  /// 搜索poi
  Future<PoiResult> searchPoi(PoiSearchQuery query) {
    return createAMapSearch().searchPoi(query);
  }

  /// 搜索poi 周边搜索
  Future<PoiResult> searchPoiBound(PoiSearchQuery query) {
    return createAMapSearch().searchPoiBound(query);
  }

  /// 搜索poi 多边形搜索
  Future<PoiResult> searchPoiPolygon(PoiSearchQuery query) {
    return createAMapSearch().searchPoiPolygon(query);
  }

  /// 按id搜索poi
  Future<PoiItem> searchPoiId(String id) {
    return createAMapSearch().searchPoiId(id);
  }

  /// 道路沿途直线检索POI
  Future<RoutePoiResult> searchRoutePoiLine(RoutePoiSearchQuery query) {
    return createAMapSearch().searchRoutePoiLine(query);
  }

  /// 道路沿途多边形检索POI
  Future<RoutePoiResult> searchRoutePoiPolygon(RoutePoiSearchQuery query) {
    return createAMapSearch().searchRoutePoiPolygon(query);
  }

  /// 计算驾驶路线
  Future<DriveRouteResult> calculateDriveRoute(RoutePlanParam param) {
    return createAMapSearch().calculateDriveRoute(param);
  }

  /// 地址转坐标 [name]表示地址，第二个参数表示查询城市，中文或者中文全拼，citycode、adcode
  Future<GeocodeResult> searchGeocode(String name, String city) {
    return createAMapSearch().searchGeocode(name, city);
  }

  /// 逆地理编码（坐标转地址）
  Future<ReGeocodeResult> searchReGeocode(
    LatLng point,
    double radius,
    int latLonType,
  ) {
    return createAMapSearch().searchReGeocode(point, radius, latLonType);
  }

  /// 距离测量 参考[链接](https://lbs.amap.com/api/android-sdk/guide/computing-equipment/distancesearch)
  ///
  /// type 分别对应
  Future<List<int>> distanceSearch(
      List<LatLng> origins, LatLng target, DistanceSearchType type) {
    return createAMapSearch().distanceSearch(origins, target, type);
  }

  /// 公交站点查询
  ///
  /// [stationName] 公交站点名
  /// [city] 所在城市名或者城市区号
  Future<BusStationResult> searchBusStation(String stationName, String city) {
    return createAMapSearch().searchBusStation(stationName, city);
  }
}

enum DistanceSearchType {
  line,
  driver,
}
