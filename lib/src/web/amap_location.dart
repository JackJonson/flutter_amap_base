import 'dart:async';
import 'dart:convert';
import 'dart:js_util';

import 'package:amap_base/src/common/log.dart';
import 'package:amap_base/src/interface/location/amap_location.dart';
import 'package:amap_base/src/location/model/location.dart';
import 'package:amap_base/src/location/model/location_client_options.dart';
import 'package:amap_base/src/web/amap_controller.dart';
import 'package:amap_base/src/web/amapjs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:js/js.dart';
import 'package:rxdart/rxdart.dart';

import 'loaderjs.dart';

AMapLocation createLocation() => AMapWebLocation();

class AMapWebLocation extends AMapLocation {
  static AMapWebLocation _instance;

  AMap _aMap;
  Geolocation _geolocation;
  BehaviorSubject<Location> _streamController;
  Timer _timer;
  final List<String> plugins = <String>['AMap.Geolocation', 'AMap.ToolBar'];

  AMapWebLocation._() {}

  factory AMapWebLocation() {
    if (_instance == null) {
      _instance = AMapWebLocation._();
      return _instance;
    } else {
      return _instance;
    }
  }

  /// 初始化
  @override
  Future init() {
    var promise = load(LoaderOptions(
      key: '4e479545913a3a180b3cffc267dad646',
      version: '1.4.15',
      plugins: plugins,
    ));

    _streamController = BehaviorSubject<Location>();

    promiseToFuture(promise).then((value) {
      debugPrint('load success');
      MapOptions _mapOptions = MapOptions(
        zoom: 11,
        resizeEnable: true,
      );

      /// 无法使用id https://github.com/flutter/flutter/issues/40080
      _aMap = AMap('123', _mapOptions);

      /// 加载插件
      _aMap.plugin(plugins, allowInterop(() {
        _aMap.addControl(ToolBar());

        /// 定位插件初始化
        _geolocation = Geolocation(GeolocationOptions(
          timeout: 15000,
          buttonPosition: 'RB',
          buttonOffset: Pixel(10, 20),
          zoomToAccuracy: true,
          showMarker: false,
          showCircle: true,
        ));

        _aMap.addControl(_geolocation);
        debugPrint('Add geo plugin success');
      }));
    }, onError: (dynamic e) {
      debugPrint('初始化错误：$e');
    });
    return Future.value();
  }

  /// 只定位一次
  @override
  Future<Location> getLocation(LocationClientOptions options) async {
    debugPrint(
        'getLocation dart端参数: options.toJsonString() -> ${options.toJsonString()}');
    Completer _completer = new Completer();
    _geolocation.getCurrentPosition(allowInterop((status, result) {
      if (status == 'complete') {
        _completer.complete(result.position);
      } else {
        /// 异常查询：https://lbs.amap.com/faq/js-api/map-js-api/position-related/43361
        /// Get geolocation time out：浏览器定位超时，包括原生的超时，可以适当增加超时属性的设定值以减少这一现象，
        /// 另外还有个别浏览器（如google Chrome浏览器等）本身的定位接口是黑洞，通过其请求定位完全没有回应，也会超时返回失败。
        _completer.completeError(result.message);
        debugPrint(result.message);
      }
    }));

    LngLat lat = await _completer.future;
    return lat != null
        ? Future.value(
            Location(latitude: lat.getLat(), longitude: lat.getLng()))
        : null;
  }

  /// 开始定位, 返回定位 结果流
  @override
  Stream<Location> startLocate(LocationClientOptions options) {
    debugPrint(
        'startLocate dart端参数: options.toJsonString() -> ${options.toJsonString()}');
    if (options != null) {
      if (!options.isOnceLocation) {
        _timer = Timer.periodic(Duration(milliseconds: options.interval),
            (timer) async {
          _geolocation.getCurrentPosition(allowInterop((status, result) {
            if (status == 'complete') {
              _streamController.add(
                Location(
                  latitude: result.position.getLat(),
                  longitude: result.position.getLng(),
                  city: result.addressComponent.city,
                  address: result.formattedAddress,
                  district: result.addressComponent.district,
                  province: result.addressComponent.province,
                  street: result.addressComponent.street,
                  streetNum: result.addressComponent.streetNumber,
                ),
              );
            } else {
              /// 异常查询：https://lbs.amap.com/faq/js-api/map-js-api/position-related/43361
              /// Get geolocation time out：浏览器定位超时，包括原生的超时，可以适当增加超时属性的设定值以减少这一现象，
              /// 另外还有个别浏览器（如google Chrome浏览器等）本身的定位接口是黑洞，通过其请求定位完全没有回应，也会超时返回失败。
              debugPrint(result.message);
            }
          }));
        });
      }
      return _streamController.stream;
    }
    return null;
  }

  /// 结束定位, 但是仍然可以打开, 其实严格说是暂停
  @override
  Future stopLocate() {
    _timer?.cancel();
    if (!_streamController.isClosed) {
      _streamController.close();
    }
    return Future.value();
    // return _locationChannel.invokeMethod('location#stopLocate');
  }
}
