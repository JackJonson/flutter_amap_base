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
import 'package:amap_base/src/web/poisearch_model.dart';
import 'package:flutter/material.dart';
import 'package:js/js.dart';
import 'package:rxdart/rxdart.dart';

import 'amapjs.dart';

class AMapWebController extends AMapController {
  final AMap _aMap;
  Geolocation _geolocation;
  MarkerOptions _markerOptions;
  PlaceSearchOptions _placeSearchOptions;
  BehaviorSubject<TouchEvent> _touchController;
  BehaviorSubject<CameraPosition> _cameraController;
  BehaviorSubject<MarkerOptionsN.MarkerOptions> _markerController;
  static const String _kType =
      '010000|010100|020000|030000|040000|050000|050100|060000|060100|060200|060300|060400|070000|080000|080100|080300|080500|080600|090000|090100|090200|090300|100000|100100|110000|110100|120000|120200|120300|130000|140000|141200|150000|150100|150200|160000|160100|170000|170100|170200|180000|190000|200000';

  AMapWebController(this._aMap) {
    _placeSearchOptions = PlaceSearchOptions(
      extensions: 'all',
      type: _kType,
      pageIndex: 1,
      pageSize: 50,
    );
    _touchController = BehaviorSubject<TouchEvent>();
    _cameraController = BehaviorSubject<CameraPosition>();
    _markerController = BehaviorSubject<MarkerOptionsN.MarkerOptions>();

    ///触摸事件-开始
    _aMap.on('touchstart', allowInterop((event) {
      _touchController.add(
        TouchEvent(
          TouchEvent.ACTION_DOWN,
          event.pixel.getX(),
          event.pixel.getY(),
          event.pixel.getX(),
          event.pixel.getY(),
        ),
      );
    }));

    ///触摸事件-移动
    _aMap.on('touchmove', allowInterop((event) {
      _touchController.add(
        TouchEvent(
          TouchEvent.ACTION_MOVE,
          event?.pixel?.getX(),
          event?.pixel?.getY(),
          event?.pixel?.getX(),
          event?.pixel?.getY(),
        ),
      );
    }));

    ///触摸事件-结束
    _aMap.on('touchend', allowInterop((event) {
      _touchController.add(
        TouchEvent(
          TouchEvent.ACTION_UP,
          event.pixel.getX(),
          event.pixel.getY(),
          event.pixel.getX(),
          event.pixel.getY(),
        ),
      );
    }));

    ///移动事件-开始
    _aMap.on('movestart', allowInterop((event) {
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

    _aMap.on('mapmove', allowInterop((event) {
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


    /// 定位插件初始化
    _geolocation = Geolocation(GeolocationOptions(
      timeout: 15000,
      buttonPosition: 'RB',
      buttonOffset: Pixel(10, 20),
      zoomToAccuracy: true,
    ));

    _aMap.addControl(_geolocation);
    _aMap.addControl(ToolBar());
    location();
  }

  onMarkerClick(MapsEvent event) {
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
        _aMap.setCenter(result.position);
      } else {
        /// 异常查询：https://lbs.amap.com/faq/js-api/map-js-api/position-related/43361
        /// Get geolocation time out：浏览器定位超时，包括原生的超时，可以适当增加超时属性的设定值以减少这一现象，
        /// 另外还有个别浏览器（如google Chrome浏览器等）本身的定位接口是黑洞，通过其请求定位完全没有回应，也会超时返回失败。
        debugPrint(result.message);
      }
    }));
    return Future.value();
  }

  /// city：cityName（中文或中文全拼）、cityCode均可
  Future<void> search(String keyWord, {city = ''}) async {
    final PlaceSearch placeSearch = PlaceSearch(_placeSearchOptions);
    placeSearch.setCity(city);
    placeSearch.search(keyWord, searchResult);
    return Future.value();
  }

  Future<void> move(String lat, String lon) async {
    final LngLat lngLat = LngLat(double.parse(lon), double.parse(lat));
    _aMap.setCenter(lngLat);
    // if (_markerOptions == null) {
    //   _markerOptions = MarkerOptions(
    //       position: lngLat,
    //       icon: AMapIcon(IconOptions(
    //         size: Size(26, 34),
    //         imageSize: Size(26, 34),
    //         image:
    //             'https://a.amap.com/jsapi_demos/static/demo-center/icons/poi-marker-default.png',
    //       )),
    //       offset: Pixel(-13, -34),
    //       anchor: 'bottom-center');
    // } else {
    //   _markerOptions.position = lngLat;
    // }
    _aMap.clearMap();
    _aMap.add(Marker(_markerOptions));
    return Future.value();
  }

  /// 根据经纬度搜索
  void searchNearBy(LngLat lngLat) {
    final PlaceSearch placeSearch = PlaceSearch(_placeSearchOptions);
    placeSearch.searchNearBy('', lngLat, 2000, searchResult);
  }

  Function(String status, SearchResult result) get searchResult =>
      allowInterop((status, result) {
        final List<PoiSearch> list = <PoiSearch>[];
        if (status == 'complete') {
          if (result is SearchResult) {
            result.poiList?.pois?.forEach((dynamic poi) {
              if (poi is Poi) {
                final PoiSearch poiSearch = PoiSearch(
                  cityCode: poi.citycode,
                  cityName: poi.cityname,
                  provinceName: poi.pname,
                  title: poi.name,
                  adName: poi.adname,
                  provinceCode: poi.pcode,
                  latitude: poi.location.getLat().toString(),
                  longitude: poi.location.getLng().toString(),
                );
                list.add(poiSearch);
              }
            });
          }
        } else if (status == 'no_data') {
          debugPrint('无返回结果');
        } else {
          debugPrint(result.toString());
        }

        /// 默认点移动到搜索结果的第一条
        if (list.isNotEmpty) {
          _aMap.setZoom(17);
          move(list[0].latitude, list[0].longitude);
        }

        // if (_widget.onPoiSearched != null) {
        //   _widget.onPoiSearched(list);
        // }
      });

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

  @override
  Future addMarker(MarkerOptionsN.MarkerOptions options,
      {bool lockedToScreen = false, bool openAnimation = true}) async {
    // TODO: implement addMarker
    Marker marker = Marker(
      MarkerOptions(
        map: _aMap,
        position: LngLat(options.position.longitude, options.position.latitude),
        icon: AMapIcon(
          IconOptions(
              image: "https://webapi.amap.com/theme/v1.3/markers/n/mark_b.png"),
        ),
      ),
    );
    marker.on('click', allowInterop(onMarkerClick));
    _aMap.clearMap();
    _aMap.add(marker);
  }

  @override
  Future addMarkers(List<MarkerOptionsN.MarkerOptions> optionsList,
      {bool moveToCenter = true,
      bool clear = false,
      bool clearLast = false,
      bool openAnimation = true}) async {
    // TODO: implement addMarkers
    List<Marker> mpList = [];
    Marker marker;
    for (MarkerOptionsN.MarkerOptions op in optionsList) {
      marker = Marker(
        MarkerOptions(
          map: _aMap,
          position: LngLat(op.position.longitude, op.position.latitude),
          icon: AMapIcon(
            IconOptions(
                image:
                    "https://webapi.amap.com/theme/v1.3/markers/n/mark_b.png"),
          ),
        ),
      );
      marker.on('click', allowInterop(onMarkerClick));
      mpList.add(marker);
    }
    _aMap.clearMap();
    _aMap.add(mpList);
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
