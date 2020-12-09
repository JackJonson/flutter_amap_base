import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:amap_base/amap_base.dart';
import 'package:amap_base/src/common/log.dart';
import 'package:amap_base/src/interface/map/amap_controller.dart';
import 'package:amap_base/src/map/model/marker_options.dart';
import 'package:amap_base/src/map/model/my_location_style.dart';
import 'package:amap_base/src/map/model/polyline_options.dart';
import 'package:amap_base/src/map/model/ui_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'model/touch_event.dart';

class AMapMobileController extends AMapController{
  final MethodChannel _mapChannel;
  final EventChannel _markerClickedEventChannel;
  final EventChannel _cameraChangeEventChannel;
  final EventChannel _mapTouchEventChannel;

  AMapMobileController.withId(int id)
      : _mapChannel = MethodChannel('me.yohom/map$id'),
        _markerClickedEventChannel = EventChannel('me.yohom/marker_clicked$id'),
        _mapTouchEventChannel = EventChannel('me.yohom/map_touch'),
        _cameraChangeEventChannel = EventChannel('me.yohom/camera_changed');

  void dispose() {}

  ///region dart -> native
  @override
  Future setMyLocationStyle(MyLocationStyle style) {
    final _styleJson =
    jsonEncode(style?.toJson() ?? MyLocationStyle().toJson());

    debugPrint('方法setMyLocationStyle dart端参数: styleJson -> $_styleJson');
    return _mapChannel.invokeMethod(
      'map#setMyLocationStyle',
      {'myLocationStyle': _styleJson},
    );
  }

  @override
  Future setUiSettings(UiSettings uiSettings) {
    final _uiSettings = jsonEncode(uiSettings.toJson());

    debugPrint('方法setUiSettings dart端参数: _uiSettings -> $_uiSettings');
    return _mapChannel.invokeMethod(
      'map#setUiSettings',
      {'uiSettings': _uiSettings},
    );
  }
  @override
  Future addMarker(MarkerOptions options, {
    bool lockedToScreen = false,
    bool openAnimation = true,
  }) {
    final _optionsJson = options.toJsonString();
    debugPrint('方法addMarker dart端参数: _optionsJson -> $_optionsJson');
    return _mapChannel.invokeMethod(
      'marker#addMarker',
      {
        'markerOptions': _optionsJson,
        'lockedToScreen': lockedToScreen,
        'openAnimation': openAnimation,
      },
    );
  }
  @override
  Future addMarkers(List<MarkerOptions> optionsList, {
    bool moveToCenter = true,
    bool clear = false,
    bool clearLast = false,
    bool openAnimation = true,
  }) {
    final _optionsListJson =
    jsonEncode(optionsList.map((it) => it.toJson()).toList());
    debugPrint('方法addMarkers dart端参数: _optionsListJson -> $_optionsListJson');
    return _mapChannel.invokeMethod(
      'marker#addMarkers',
      {
        'moveToCenter': moveToCenter,
        'markerOptionsList': _optionsListJson,
        'clear': clear,
        'clearLast': clearLast,
        'openAnimation': openAnimation,
      },
    );
  }
  @override
  Future showIndoorMap(bool enable) {
    return _mapChannel.invokeMethod(
      'map#showIndoorMap',
      {'showIndoorMap': enable},
    );
  }
  @override
  Future setMapType(int mapType) {
    return _mapChannel.invokeMethod(
      'map#setMapType',
      {'mapType': mapType},
    );
  }
  @override
  Future setLanguage(int language) {
    return _mapChannel.invokeMethod(
      'map#setLanguage',
      {'language': language},
    );
  }
  @override
  Future clearMarkers() {
    return _mapChannel.invokeMethod('marker#clear');
  }
  @override
  Future clearMap() {
    return _mapChannel.invokeMethod('map#clear');
  }

  /// 设置缩放等级
  @override
  Future setZoomLevel(int level) {
    debugPrint('setZoomLevel dart端参数: level -> $level');

    return _mapChannel.invokeMethod(
      'map#setZoomLevel',
      {'zoomLevel': level},
    );
  }

  /// 设置地图中心点
  @override
  Future setPosition({
    @required LatLng target,
    double zoom = 10,
    double tilt = 0,
    double bearing = 0,
  }) {
    debugPrint(
        'setPosition dart端参数: target -> $target, zoom -> $zoom, tilt -> $tilt, bearing -> $bearing');

    return _mapChannel.invokeMethod(
      'map#setPosition',
      {
        'target': target.toJsonString(),
        'zoom': zoom,
        'tilt': tilt,
        'bearing': bearing,
      },
    );
  }

  /// 限制地图的显示范围
  @override
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
  }) {
    debugPrint(
        'setPosition dart端参数: swLatLng -> $swLatLng, neLatLng -> $neLatLng, center -> $center, deltaLat -> $deltaLat, deltaLng -> $deltaLng');

    return _mapChannel.invokeMethod(
      'map#setMapStatusLimits',
      {
        'swLatLng': swLatLng.toJsonString(),
        'neLatLng': neLatLng.toJsonString(),
        'center': center.toJsonString(),
        'deltaLat': deltaLat,
        'deltaLng': deltaLng,
      },
    );
  }

  /// 添加线
  @override
  Future addPolyline(PolylineOptions options) {
    debugPrint('addPolyline dart端参数: options -> $options');

    return _mapChannel.invokeMethod(
      'map#addPolyline',
      {'options': options.toJsonString()},
    );
  }

  /// 移动镜头到当前的视角
  @override
  Future zoomToSpan(List<LatLng> bound, {
    bool isMoveCenter = true,
    int padding = 80,
  }) {
    final boundJson =
    jsonEncode(bound?.map((it) => it.toJson())?.toList() ?? List());

    debugPrint('zoomToSpan dart端参数:isMoveCenter -> $isMoveCenter, bound -> $boundJson');

    return _mapChannel.invokeMethod(
      'map#zoomToSpan',
      {
        'bound': boundJson,
        'isMoveCenter': isMoveCenter,
        'padding': padding,
      },
    );
  }

  /// 移动指定LatLng到中心
  @override
  Future changeLatLng(LatLng target) {
    debugPrint('changeLatLng dart端参数: target -> $target');

    return _mapChannel.invokeMethod(
      'map#changeLatLng',
      {'target': target.toJsonString()},
    );
  }

  /// 获取中心点
  @override
  Future<LatLng> getCenterLatlng() async {
    String result = await _mapChannel.invokeMethod("map#getCenterPoint");
    return LatLng.fromJson(json.decode(result));
  }

  /// 截图
  ///
  /// 可能会抛出 [PlatformException]
  @override
  Future<Uint8List> screenShot() async {
    try {
      var result = await _mapChannel.invokeMethod("map#screenshot");
      if (result is List<dynamic>) {
        return Uint8List.fromList(result.map((i) => i as int).toList());
      } else if (result is Uint8List) {
        return result;
      }
      throw PlatformException(code: "不支持的类型");
    } catch (e) {
      if (e is PlatformException) {
        L.d(e.code);
        throw e;
      }
      throw Error();
    }
  }

  /// 设置自定义样式的文件路径
  @override
  Future setCustomMapStylePath(String path) {
    debugPrint('setCustomMapStylePath dart端参数: path -> $path');

    return _mapChannel.invokeMethod(
      'map#setCustomMapStylePath',
      {'path': path},
    );
  }

  /// 使能自定义样式
  @override
  Future setMapCustomEnable(bool enabled) {
    debugPrint('setMapCustomEnable dart端参数: enabled -> $enabled');

    return _mapChannel.invokeMethod(
      'map#setMapCustomEnable',
      {'enabled': enabled},
    );
  }

  /// 使用在线自定义样式
  @override
  Future setCustomMapStyleID(String styleId) {
    debugPrint('setCustomMapStyleID dart端参数: styleId -> $styleId');

    return _mapChannel.invokeMethod(
      'map#setCustomMapStyleID',
      {'styleId': styleId},
    );
  }

  //endregion

  /// marker点击事件流
  @override
  Stream<MarkerOptions> get markerClickedEvent =>
      _markerClickedEventChannel
          .receiveBroadcastStream()
          .map((data) => MarkerOptions.fromJson(jsonDecode(data)));

  /// camera change事件流
  @override
  Stream<CameraPosition> get cameraChangeEvent =>
      _cameraChangeEventChannel
          .receiveBroadcastStream()
          .map((data) => CameraPosition.fromJson(jsonDecode(data)));

  /// map touch事件流
  @override
  Stream<TouchEvent> get mapTouchEvent =>
      _mapTouchEventChannel
          .receiveBroadcastStream()
          .map((data) => TouchEvent.fromJson(jsonDecode(data)));
}
