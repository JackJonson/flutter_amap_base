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
import 'package:js/js.dart';

import 'amapjs.dart';

class AMapWebController extends AMapController {
  AMapWebController(this._aMap) {
    _placeSearchOptions = PlaceSearchOptions(
      extensions: 'all',
      type: _kType,
      pageIndex: 1,
      pageSize: 50,
    );

    _aMap.on('click', allowInterop((event) {
      searchNearBy(LngLat(event.lnglat.getLng(), event.lnglat.getLat()));
    }));

    /// 定位插件初始化
    _geolocation = Geolocation(GeolocationOptions(
      timeout: 15000,
      buttonPosition: 'RB',
      buttonOffset: Pixel(10, 20),
      zoomToAccuracy: true,
    ));

    _aMap.addControl(_geolocation);
    location();
  }

  final AMap _aMap;
  Geolocation _geolocation;
  MarkerOptions _markerOptions;
  PlaceSearchOptions _placeSearchOptions;
  static const String _kType =
      '010000|010100|020000|030000|040000|050000|050100|060000|060100|060200|060300|060400|070000|080000|080100|080300|080500|080600|090000|090100|090200|090300|100000|100100|110000|110100|120000|120200|120300|130000|140000|141200|150000|150100|150200|160000|160100|170000|170100|170200|180000|190000|200000';

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
    if (_markerOptions == null) {
      _markerOptions = MarkerOptions(
          position: lngLat,
          icon: AMapIcon(IconOptions(
            size: Size(26, 34),
            imageSize: Size(26, 34),
            image:
                'https://a.amap.com/jsapi_demos/static/demo-center/icons/poi-marker-default.png',
          )),
          offset: Pixel(-13, -34),
          anchor: 'bottom-center');
    } else {
      _markerOptions.position = lngLat;
    }
    _aMap.clearMap();
    _aMap.add(Marker(_markerOptions));
    return Future.value();
  }

  @override
  Future<void> location() async {
    _geolocation.getCurrentPosition(allowInterop((status, result) {
      if (status == 'complete') {
        _aMap.setZoom(17);
        _aMap.setCenter(result.position);
        searchNearBy(result.position);
      } else {
        /// 异常查询：https://lbs.amap.com/faq/js-api/map-js-api/position-related/43361
        /// Get geolocation time out：浏览器定位超时，包括原生的超时，可以适当增加超时属性的设定值以减少这一现象，
        /// 另外还有个别浏览器（如google Chrome浏览器等）本身的定位接口是黑洞，通过其请求定位完全没有回应，也会超时返回失败。
        print(result.message);
      }
    }));
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
          print('无返回结果');
        } else {
          print(result);
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

  // @override
  // Future addMarker(MarkerOptions options, {bool lockedToScreen = false, bool openAnimation = true}) {
  //   // TODO: implement addMarker
  //   throw UnimplementedError();
  // }
  //
  // @override
  // Future addMarkers(List<MarkerOptions> optionsList, {bool moveToCenter = true, bool clear = false, bool clearLast = false, bool openAnimation = true}) {
  //   // TODO: implement addMarkers
  //   throw UnimplementedError();
  // }

  @override
  Future addPolyline(PolylineOptions options) {
    // TODO: implement addPolyline
    throw UnimplementedError();
  }

  @override
  // TODO: implement cameraChangeEvent
  Stream<CameraPosition> get cameraChangeEvent => throw UnimplementedError();

  @override
  Future changeLatLng(LatLng target) {
    // TODO: implement changeLatLng
    _aMap.panTo(LngLat(target.longitude, target.latitude));
    return Future.value();
  }

  @override
  Future clearMap() {
    // TODO: implement clearMap
    throw UnimplementedError();
  }

  @override
  Future clearMarkers() {
    // TODO: implement clearMarkers
    throw UnimplementedError();
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  Future<LatLng> getCenterLatlng() {
    // TODO: implement getCenterLatlng
    throw UnimplementedError();
  }

  @override
  // TODO: implement mapTouchEvent
  Stream<TouchEvent> get mapTouchEvent => throw UnimplementedError();

  // @override
  // TODO: implement markerClickedEvent
  // Stream<MarkerOptions> get markerClickedEvent => throw UnimplementedError();

  @override
  Future<Uint8List> screenShot() {
    // TODO: implement screenShot
    throw UnimplementedError();
  }

  @override
  Future setCustomMapStyleID(String styleId) {
    // TODO: implement setCustomMapStyleID
    throw UnimplementedError();
  }

  @override
  Future setCustomMapStylePath(String path) {
    // TODO: implement setCustomMapStylePath
    throw UnimplementedError();
  }

  @override
  Future setLanguage(int language) {
    // TODO: implement setLanguage
    throw UnimplementedError();
  }

  @override
  Future setMapCustomEnable(bool enabled) {
    // TODO: implement setMapCustomEnable
    throw UnimplementedError();
  }

  @override
  Future setMapStatusLimits(
      {LatLng swLatLng,
      LatLng neLatLng,
      LatLng center,
      double deltaLat,
      double deltaLng}) {
    // TODO: implement setMapStatusLimits
    throw UnimplementedError();
  }

  @override
  Future setMapType(int mapType) {
    // TODO: implement setMapType
    throw UnimplementedError();
  }

  @override
  Future setMyLocationStyle(MyLocationStyle style) {
    // TODO: implement setMyLocationStyle
    throw UnimplementedError();
  }

  @override
  Future setPosition(
      {LatLng target, double zoom = 10, double tilt = 0, double bearing = 0}) {
    // TODO: implement setPosition
    throw UnimplementedError();
  }

  @override
  Future setUiSettings(UiSettings uiSettings) {
    // TODO: implement setUiSettings
    throw UnimplementedError();
  }

  @override
  Future setZoomLevel(int level) {
    // TODO: implement setZoomLevel
    throw UnimplementedError();
  }

  @override
  Future showIndoorMap(bool enable) {
    // TODO: implement showIndoorMap
    throw UnimplementedError();
  }

  @override
  Future zoomToSpan(List<LatLng> bound,
      {bool isMoveCenter = true, int padding = 80}) {
    // TODO: implement zoomToSpan
    throw UnimplementedError();
  }

  @override
  Future addMarker(MarkerOptionsN.MarkerOptions options,
      {bool lockedToScreen = false, bool openAnimation = true}) {
    // TODO: implement addMarker
    _aMap.add(MarkerOptions(
        map: _aMap,
        position: LngLat(options.position.longitude, options.position.latitude),
        icon: AMapIcon(IconOptions(
            image:
                "https://webapi.amap.com/theme/v1.3/markers/n/mark_b.png"))));
  }

  @override
  Future addMarkers(List<MarkerOptionsN.MarkerOptions> optionsList,
      {bool moveToCenter = true,
      bool clear = false,
      bool clearLast = false,
      bool openAnimation = true}) {
    // TODO: implement addMarkers
    List<MarkerOptions> mpList = [];
    for (MarkerOptionsN.MarkerOptions op in optionsList) {
      mpList.add(MarkerOptions(
          map: _aMap,
          position: LngLat(op.position.longitude, op.position.latitude),
          icon: AMapIcon(IconOptions(
              image:
                  "https://webapi.amap.com/theme/v1.3/markers/n/mark_b.png"))));
    }
    _aMap.add(mpList);
  }

  @override
  // TODO: implement markerClickedEvent
  Stream<MarkerOptionsN.MarkerOptions> get markerClickedEvent =>
      throw UnimplementedError();
}
