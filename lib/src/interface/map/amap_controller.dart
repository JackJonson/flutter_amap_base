import 'dart:async';
import 'dart:typed_data';

import 'package:amap_base/amap_base.dart';
import 'package:amap_base/src/map/model/marker_options.dart';
import 'package:amap_base/src/map/model/my_location_style.dart';
import 'package:amap_base/src/map/model/polyline_options.dart';
import 'package:amap_base/src/map/model/ui_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

abstract class AMapController {

  void dispose();

  //region dart -> native
  Future setMyLocationStyle(MyLocationStyle style);

  Future setUiSettings(UiSettings uiSettings);

  Future addMarker(MarkerOptions options, {
    bool lockedToScreen = false,
    bool openAnimation = true,
  }){}

  Future addMarkers(List<MarkerOptions> optionsList, {
    bool moveToCenter = true,
    bool clear = false,
    bool clearLast = false,
    bool openAnimation = true,
  }){}

  Future showIndoorMap(bool enable);

  Future setMapType(int mapType);

  Future setLanguage(int language);

  Future clearMarkers();

  Future clearMap();

  /// 设置缩放等级
  Future setZoomLevel(int level);

  /// 设置地图中心点
  Future setPosition({
    @required LatLng target,
    double zoom = 10,
    double tilt = 0,
    double bearing = 0,
  });

  /// 限制地图的显示范围
  Future setMapStatusLimits({
    /// 西南角 [Android]
    @required LatLng swLatLng,

    /// 东北角 [Android]
    @required LatLng neLatLng,

    /// 中心 [iOS]
    @required LatLng center,

    /// 纬度delta [iOS]
    @required double deltaLat,

    /// 经度delta [iOS]
    @required double deltaLng,
  });

  /// 添加线
  Future addPolyline(PolylineOptions options);

  /// 移动镜头到当前的视角
  Future zoomToSpan(List<LatLng> bound, {
    bool isMoveCenter = true,
    int padding = 80,
  });

  /// 移动指定LatLng到中心
  Future changeLatLng(LatLng target);

  /// 获取中心点
  Future<LatLng> getCenterLatlng();

  /// 截图
  ///
  /// 可能会抛出 [PlatformException]
  Future<Uint8List> screenShot();

  /// 设置自定义样式的文件路径
  Future setCustomMapStylePath(String path);

  /// 使能自定义样式
  Future setMapCustomEnable(bool enabled);

  /// 使用在线自定义样式
  Future setCustomMapStyleID(String styleId);

  //endregion

  /// marker点击事件流
  Stream<MarkerOptions> get markerClickedEvent=>null;

  /// camera change事件流
  Stream<CameraPosition> get cameraChangeEvent;

  /// map touch事件流
  Stream<TouchEvent> get mapTouchEvent;
}
