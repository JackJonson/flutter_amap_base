@JS('AMap')
library amap;

import 'package:js/js.dart';

/// 高德地图js，文档：https://lbs.amap.com/api/javascript-api/guide/abc/prepare
@JS('Map')
class AMap {
  external AMap(dynamic /*String|DivElement*/ container, MapOptions opts);

  /// 设置中心点
  external setCenter(LngLat center);

  /// 设置地图显示的缩放级别，参数 zoom 可设范围：[2, 20]
  external setZoom(num zoom);

  /// 添加覆盖物/图层。参数为单个覆盖物/图层，或覆盖物/图层的数组。
  external add(dynamic /*Array<any> | Marker*/ features);

  /// 删除覆盖物/图层。参数为单个覆盖物/图层，或覆盖物/图层的数组。
  external remove(dynamic /*Array | Marker*/ features);

  /// 删除所有覆盖物
  external clearMap();

  /// 加载插件
  external plugin(dynamic /*String|List*/ name, void Function() callback);

  /// 添加控件，参数可以是插件列表中的任何插件对象，如：ToolBar、OverView、Scale等
  external addControl(Control control);

  /// 销毁地图，并清空地图容器
  external destroy();

  ///移动地图到某个点
  external panTo(LngLat target);

  ///根据地图上添加的覆盖物分布情况，自动缩放地图到合适的视野级别，参数均可缺省
  external setFitView();

  ///获取中心点经纬度
  external LngLat getCenter();

  ///获取地图的缩放级别
  ///获取当前地图缩放级别,在PC上，默认取值范围为[3,18]；在移动设备上，默认取值范围为[3-19]
  ///3D地图会返回浮点数，2D视图为整数。（3D地图自V1.4.0开始支持）
  external int getZoom();

  ///设置地图的事件
  external on(String eventName, void Function(MapsEvent event) callback);
}

@JS()
class Geolocation extends Control {
  external Geolocation(GeolocationOptions opts);

  external getCurrentPosition(
      Function(String status, GeolocationResult result) callback);
}

@JS()
class PlaceSearch {
  external PlaceSearch(PlaceSearchOptions opts);

  external search(
      String keyword, Function(String status, SearchResult result) callback);

  /// 根据中心点经纬度、半径以及关键字进行周边查询 radius取值范围：0-50000
  external searchNearBy(String keyword, LngLat center, num radius,
      Function(String status, SearchResult result) callback);

  external setType(String type);

  external setPageIndex(int pageIndex);

  external setPageSize(int pageSize);

  external setCity(String city);
}

@JS()
class LngLat {
  external LngLat(num lng, num lat);

  external num getLng();

  external num getLat();

  external bool equals(LngLat lngLat);

  external String toString();
}

@JS()
class Pixel {
  external Pixel(num x, num y);

  external num getX();

  external num getY();
}

@JS()
class Marker {
  external Marker(MarkerOptions opts);

  external String getAnchor();

  external Pixel getOffset();

  external LngLat getPosition();

  external void setPosition(LngLat lnglat);

  external String getLabel();

  external String getContent();

  external String getTitle();

  external String setMap(AMap map);

  ///设置marker的事件
  external on(String eventName, void Function(MapsEvent event) callback);
}

@JS()
class Control {
  external Control();
}

@JS()
class Scale extends Control {
  external Scale();
}

@JS()
class ToolBar extends Control {
  external ToolBar();
}

@JS('Icon')
class AMapIcon {
  external AMapIcon(IconOptions options);
}

@JS()
class Size {
  external Size(num width, num height);
}

///地图事件类
@JS()
@anonymous
class MapsEvent {
  ///发生事件时光标所在处的经纬度坐标
  external LngLat get lnglat;

  ///发生事件时光标所在处的像素坐标
  external dynamic get target;

  ///发生事件的目标对象，不同类型返回target不同。例如，事件对象是Marker，则target表示目标对象为Marker，事件对象是其他，则随之改变
  external Pixel get pixel;

  ///事件类型
  external String get type;
}

@JS()
@anonymous
class MapOptions {
  external factory MapOptions({
    /// 初始中心经纬度
    LngLat center,
    bool resizeEnable,

    /// 地图显示的缩放级别
    num zoom,

    ///是否开启地图热点和标注的hover效果。PC端默认是true，移动端默认是false
    bool isHotspot,

    /// 地图视图模式, 默认为‘2D’
    String /*‘2D’|‘3D’*/ viewMode,
  });

  external LngLat get center;

  external num get zoom;

  external String get viewMode;
}

@JS()
@anonymous
class MarkerOptions {
  external factory MarkerOptions({
    /// 要显示该marker的地图对象
    AMap map,
    dynamic content,
    /// 点标记在地图上显示的位置
    dynamic position,
    dynamic icon,
    String title,
    Pixel offset,
    String anchor,
  });

  external LngLat get position;

  external set position(LngLat v);
}

@JS()
class Circle {
  external Circle(CircleOptions opt);

  ///设置覆盖物的事件
  external on(String eventName, void Function(MapsEvent event) callback);
}

@JS()
@anonymous
class CircleOptions {
  external factory CircleOptions({
    /// 要显示该marker的地图对象
    AMap map,

    /// 点标记在地图上显示的位置
    dynamic center,
    num radius,
    String strokeColor,
    double strokeOpacity,
    num strokeWeight,
    String fillColor,
    double fillOpacity,
    String strokeStyle,
    dynamic extData,
  });

  external void setCenter(LngLat lnglat);

  external LngLat getCenter(LngLat v);
}

@JS()
class CircleMarker {
  external CircleMarker(CircleMarkerOptions opt);

  external LngLat getCenter();
  ///设置覆盖物的事件
  external on(String eventName, void Function(MapsEvent event) callback);
}

@JS()
@anonymous
class CircleMarkerOptions {
  external factory CircleMarkerOptions({
    /// 要显示该marker的地图对象
    AMap map,

    /// 点标记在地图上显示的位置
    dynamic center,
    num radius,
    String strokeColor,
    double strokeOpacity,
    num strokeWeight,
    String fillColor,
    double fillOpacity,
    String strokeStyle,
    dynamic extData,
  });

  external void setCenter(LngLat lnglat);

  external LngLat getCenter(LngLat v);

  external dynamic get extData;
}

@JS()
@anonymous
class GeolocationOptions {
  external factory GeolocationOptions(
      {

      /// 是否使用高精度定位，默认：true
      bool enableHighAccuracy,

      /// 设置定位超时时间，默认：无穷大
      int timeout,

      /// 定位按钮的停靠位置的偏移量，默认：Pixel(10, 20)
      Pixel buttonOffset,

      ///  定位成功后调整地图视野范围使定位位置及精度范围视野内可见，默认：false
      bool zoomToAccuracy,

      ///  定位按钮的排放位置,  RB表示右下
      String buttonPosition,

      ///定位成功后在定位到的位置显示点标记，默认：true
      bool showMarker,

      ///定位成功后用圆圈表示定位精度范围，默认：true
      bool showCircle,

      ///定位成功后将定位到的位置作为地图中心点，默认：true
      bool panToLocation,

      ///定位成功后定位位置marker配置
      MarkerOptions markerOptions,

      ///精度范围的圆圈配置
      CircleOptions circleOptions});
}

@JS()
@anonymous
class PlaceSearchOptions {
  external factory PlaceSearchOptions({
    ///此项默认值：base，返回基本地址信息
    /// 取值：all，返回基本+详细信息
    String extensions,
    String type,
    int pageSize,
    int pageIndex,
  });
}

@JS()
@anonymous
class IconOptions {
  external factory IconOptions({
    Size size,
    String image,
    Size imageSize,
  });
}

///定位结果信息类
@JS()
@anonymous
class GeolocationResult {
  ///定位结果
  external LngLat get position;

  ///精度范围，单位：米
  external String get message;

  ///定位结果的来源，可能的值有:'html5'、'ip'、'sdk'
  external num get accuracy;

  ///形成当前定位结果的一些信息
  external String get location_type;

  ///是否经过坐标纠偏
  external bool get isConverted;

  ///状态信息 "SUCCESS"
  external String get info;

  ///地址
  external String get formattedAddress;

  ///地址信息，详情参考Geocoder
  external AddressComponent get addressComponent;

  ///定位点附近的POI信息，extensions等于'base'的时候为空
  external List get pois;

  ///定位点附近的道路信息，extensions等于'base'的时候为空
  external List get roads;

  ///定位点附近的道路交叉口信息，extensions等于'base'的时候为空
  external List get crosses;
}

///定位结果信息中的地址相关类
@JS()
@anonymous
class AddressComponent {
  ///所在省（省编码在城市编码表中可查询到）
  external String get province;

  ///所在城市
  external String get city;

  ///所在城市编码
  external String get citycode;

  ///所在区
  external String get district;

  ///所在区域编码
  external String get adcode;

  ///所在乡镇
  external String get township;

  ///所在街道
  external String get street;

  ///门牌号
  external String get streetNumber;

  ///所在社区
  external String get neighborhood;

  ///社区类型
  external String get neighborhoodType;

  ///所在楼/大厦
  external String get building;

  ///楼类型
  external String get buildingType;

  ///仅逆地理编码时返回，所属商圈信息
  external String get businessAreas;
}

@JS()
@anonymous
class SearchResult {
  external PoiList get poiList;

  /// 成功状态说明
  external String get info;
}

@JS()
@anonymous
class PoiList {
  external List<dynamic> get pois;

  /// 查询结果总数
  external int get count;
}

@JS()
@anonymous
class Poi {
  external String get citycode;

  external String get cityname;

  external String get pname;

  external String get pcode;

  external LngLat get location;

  external String get adname;

  external String get name;

  external String get address;
}

@JS()
@anonymous
class GeometryUtil {
  external static double distance(LngLat p1, LngLat p2);
}

@JS()
@anonymous
class ConvertorResult {
  external List<LngLat> get locations;

  external String get info;
}

///其他坐标点转换为高德坐标系
external convertFrom(dynamic /*LngLat | Array<LngLat>*/ l, String type,
    Function(String status, ConvertorResult result) callback);
