import 'dart:async';
import 'dart:typed_data';

import 'package:amap_base/src/interface/map/amap_controller.dart';
import 'package:amap_base/src/map/model/camera_position.dart';
import 'package:amap_base/src/map/model/latlng.dart';
import 'package:amap_base/src/map/model/marker_options.dart' as MarkerOptionsN;
import 'package:amap_base/src/map/model/my_location_style.dart';
import 'package:amap_base/src/map/model/polyline_options.dart';
import 'package:amap_base/src/map/model/touch_event.dart';
import 'package:amap_base/src/map/model/ui_settings.dart';
import 'package:amap_base/src/web/amap_location.dart';
import 'package:amap_base/src/web/poisearch_model.dart';
import 'package:flutter/material.dart';
import 'package:js/js.dart';
import 'package:rxdart/rxdart.dart';

import 'amapjs.dart';

///Flutter web DomCanvas绘制引擎绘制marker时会出现缩放地图后marker移动到地图中心点的情况
///所以web端添加的marker暂时都为CircleMarker，定位成功后暂时不添加的marker
class AMapWebController extends AMapController {
  final AMap _aMap;
  Geolocation _geolocation;
  List<CircleMarker> markerList = [];
  BehaviorSubject<TouchEvent> _touchController;
  BehaviorSubject<CameraPosition> _cameraController;
  BehaviorSubject<MarkerOptionsN.MarkerOptions> _markerController;

  AMapWebController(this._aMap) {
    _touchController = BehaviorSubject<TouchEvent>();
    _cameraController = BehaviorSubject<CameraPosition>();
    _markerController = BehaviorSubject<MarkerOptionsN.MarkerOptions>();

    ///触摸事件-开始
    _aMap.on('dragstart', allowInterop((event) {
      _touchController.add(
        TouchEvent(
          TouchEvent.ACTION_DOWN,
          null,
          null,
          null,
          null,
        ),
      );
    }));

    ///触摸事件-移动
    _aMap.on('dragging', allowInterop((event) {
      _touchController.add(
        TouchEvent(
          TouchEvent.ACTION_MOVE,
          null,
          null,
          null,
          null,
        ),
      );
    }));

    ///触摸事件-结束
    _aMap.on('dragend', allowInterop((event) {
      _touchController.add(
        TouchEvent(
          TouchEvent.ACTION_UP,
          null,
          null,
          null,
          null,
        ),
      );
    }));

    ///移动事件-开始
    // _aMap.on('movestart', allowInterop((event) {
    //   _cameraController.add(
    //     CameraPosition(
    //       target: LatLng(
    //         _aMap.getCenter().getLat(),
    //         _aMap.getCenter().getLng(),
    //       ),
    //       zoom: _aMap.getZoom().toDouble(),
    //     ),
    //   );
    // }));

    _aMap.on('moveend', allowInterop((event) {
      _cameraController.add(
        CameraPosition(
          target: LatLng(
            _aMap.getCenter().getLat(),
            _aMap.getCenter().getLng(),
          ),
          zoom: _aMap.getZoom().toDouble(),
        ),
      );
    }));

    // _aMap.on('zoomchange', allowInterop((event) {
    //   debugPrint('zoomChange');
    //   if(markerList?.isNotEmpty??false){
    //     for(Marker marker in markerList){
    //       _aMap.remove(marker);
    //       marker.setPosition(marker.getPosition());
    //       _aMap.add(marker);
    //     }
    //   }
    // },),);

    /// 定位插件初始化
    /// 加载插件
    _aMap.plugin('AMap.Geolocation', allowInterop(() {
      /// 定位插件初始化
      _geolocation = Geolocation(
        GeolocationOptions(
          timeout: 15000,
          buttonPosition: 'RB',
          buttonOffset: Pixel(10, 20),
          zoomToAccuracy: true,
          showMarker: false,
          panToLocation: true,
          circleOptions: CircleOptions(
            radius: 50,
            fillColor: '#4398fd',
            fillOpacity: 0.1,
            strokeWeight: 0.5,
            strokeColor: '#4398fd',
            strokeStyle: 'solid',
          ),
        ),
      );
      _aMap.addControl(_geolocation);
      location();
    }));

    // _aMap.addControl(ToolBar());
    // 取消进入地图获取定位功能，如需使用，使用amap_location工具类定位
  }

  onMarkerClick(MapsEvent event) {
    print('onMarkerClick event.target:${event.target.getPosition().getLat()}');
    Marker op = event.target;
    _markerController.add(
      MarkerOptionsN.MarkerOptions(
        position: LatLng(op.getPosition().getLat(), op.getPosition().getLng()),
        title: op.getTitle(),
        snippet: op.getContent(),
      ),
    );
  }

  Future<void> location() async {
    _geolocation.getCurrentPosition(allowInterop((status, result) {
      if (status == 'complete') {
        _aMap.setZoom(17);
        // changeLatLng(LatLng(
        //   result.position.getLat(),
        //   result.position.getLng(),
        // ));
      } else {
        /// 异常查询：https://lbs.amap.com/faq/js-api/map-js-api/position-related/43361
        /// Get geolocation time out：浏览器定位超时，包括原生的超时，可以适当增加超时属性的设定值以减少这一现象，
        /// 另外还有个别浏览器（如google Chrome浏览器等）本身的定位接口是黑洞，通过其请求定位完全没有回应，也会超时返回失败。
        debugPrint(result.message);
      }
    }));
    return Future.value();
  }

  @override
  // TODO: implement mapTouchEvent
  Stream<TouchEvent> get mapTouchEvent => _touchController.stream;

  @override
  // TODO: implement cameraChangeEvent
  Stream<CameraPosition> get cameraChangeEvent => _cameraController.stream;

  @override
  // TODO: implement markerClickedEvent
  Stream<MarkerOptionsN.MarkerOptions> get markerClickedEvent =>
      _markerController.stream;

  @override
  Future<Uint8List> screenShot() async {
    // TODO: implement screenShot
  }

  @override
  Future setCustomMapStyleID(String styleId) async {
    // TODO: implement setCustomMapStyleID
  }

  @override
  Future setCustomMapStylePath(String path) async {
    // TODO: implement setCustomMapStylePath
  }

  @override
  Future setLanguage(int language) async {
    // TODO: implement setLanguage
  }

  @override
  Future setMapCustomEnable(bool enabled) async {
    // TODO: implement setMapCustomEnable
  }

  @override
  Future setMapStatusLimits(
      {LatLng swLatLng,
      LatLng neLatLng,
      LatLng center,
      double deltaLat,
      double deltaLng}) async {
    // TODO: implement setMapStatusLimits
  }

  @override
  Future setMapType(int mapType) async {
    // TODO: implement setMapType
  }

  @override
  Future setMyLocationStyle(MyLocationStyle style) async {
    // TODO: implement setMyLocationStyle
  }

  @override
  Future setPosition(
      {LatLng target,
      double zoom = 10,
      double tilt = 0,
      double bearing = 0}) async {
    // TODO: implement setPosition
  }

  @override
  Future setUiSettings(UiSettings uiSettings) async {
    // TODO: implement setUiSettings
  }

  @override
  Future setZoomLevel(int level) async {
    // TODO: implement setZoomLevel
    _aMap.setZoom(level);
  }

  @override
  Future showIndoorMap(bool enable) async {
    // TODO: implement showIndoorMap
  }

  @override
  Future zoomToSpan(List<LatLng> bound,
      {bool isMoveCenter = true, int padding = 80}) async {
    // TODO: implement zoomToSpan
    List<LngLat> overlayList = [];
    for (LatLng l in bound) {
      overlayList.add(LngLat(l.longitude, l.latitude));
    }
    // _aMap.setFitView(overlayList, false, [], 17);
    _aMap.setFitView();
  }

  ///Flutter web DomCanvas绘制引擎绘制marker时会出现缩放地图后marker移动到地图中心点的情况
  ///所以web端添加的marker暂时都为CircleMarker
  @override
  Future addMarker(MarkerOptionsN.MarkerOptions options,
      {bool lockedToScreen = false, bool openAnimation = true}) async {
    CircleMarker circle = CircleMarker(
      CircleMarkerOptions(
        center: LngLat(options.position.longitude, options.position.latitude),
        radius: 7,
        //半径
        strokeColor: "#FFFFFF",
        //线颜色
        strokeOpacity: 1,
        //线透明度
        strokeWeight: 3,
        //线粗细度
        fillColor: options.markerFillColor ?? "#589afa",
        //填充颜色
        fillOpacity: 1,
        extData: options.markerId,
      ),
    );
    _aMap.add(circle);

    circle.on('click', allowInterop((MapsEvent event) {
      print('onMarkerClick event.target:${event.lnglat.getLat()}');
      CircleMarker op = event.target;
      _markerController.add(
        MarkerOptionsN.MarkerOptions(
          position: LatLng(op.getCenter().getLat(), op.getCenter().getLng()),
        ),
      );
    }));
    markerList.add(circle);
  }

  ///Flutter web DomCanvas绘制引擎绘制marker时会出现缩放地图后marker移动到地图中心点的情况
  ///所以web端添加的marker暂时都为CircleMarker
  @override
  Future addMarkers(List<MarkerOptionsN.MarkerOptions> optionsList,
      {bool moveToCenter = true,
      bool clear = false,
      bool clearLast = false,
      bool openAnimation = true}) async {
    if (clearLast && (markerList?.isNotEmpty ?? false)) {
      for (CircleMarker m in markerList) {
        _aMap.remove(m);
      }
      markerList.clear();
    }
    if (clear || (optionsList?.isEmpty ?? true)) {
      markerList.clear();
      _aMap.clearMap();
    }

    for (MarkerOptionsN.MarkerOptions op in optionsList) {
      CircleMarker circle = CircleMarker(
        CircleMarkerOptions(
          center: LngLat(op.position.longitude, op.position.latitude),
          radius: 7,
          //半径
          strokeColor: "#FFFFFF",
          //线颜色
          strokeOpacity: 1,
          //线透明度
          strokeWeight: 3,
          //线粗细度
          fillColor: op.markerFillColor ?? "#589afa",
          //填充颜色
          fillOpacity: 1,
          extData: op.markerId,
        ),
      );
      _aMap.add(circle);
      circle.on('click', allowInterop((MapsEvent event) {
        print('onMarkerClick event.target:${event.lnglat.getLat()}');
        CircleMarker op = event.target;
        _markerController.add(
          MarkerOptionsN.MarkerOptions(
            position: LatLng(op.getCenter().getLat(), op.getCenter().getLng()),
          ),
        );
      }));
      markerList.add(circle);
    }
  }

  @override
  Future<LatLng> getCenterLatlng() {
    // TODO: implement getCenterLatlng
    LngLat l = _aMap.getCenter();
    return Future.value(LatLng(l.getLat(), l.getLng()));
  }

  @override
  Future addPolyline(PolylineOptions options) async {
    // TODO: implement addPolyline
  }

  @override
  Future changeLatLng(LatLng target) async {
    // TODO: implement changeLatLng
    _aMap.panTo(LngLat(target.longitude, target.latitude));
  }

  @override
  Future clearMap() async {
    // TODO: implement clearMap
  }

  @override
  Future clearMarkers() async {
    // TODO: implement clearMarkers
    _aMap.clearMap();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _aMap.destroy();
  }
}
