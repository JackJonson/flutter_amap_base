
// ignore: avoid_web_libraries_in_flutter
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:js_util';
import 'dart:ui' as ui;

import 'package:amap_base/src/amap_view.dart';
import 'package:amap_base/src/map/model/amap_options.dart';
import 'package:amap_base/src/web/amap_controller.dart';
import 'package:amap_base/src/web/amapjs.dart';
import 'package:amap_base/src/web/loaderjs.dart';
import 'package:amap_base/src/web/poisearch_model.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:js/js.dart';

Widget buildTargetAMapView({
  Key key,
  MapCreatedCallback onAMapViewCreated,
  PlatformViewHitTestBehavior hitTestBehavior =
      PlatformViewHitTestBehavior.opaque,
  TextDirection layoutDirection,
  AMapOptions aMapOptions = const AMapOptions(),
}) =>
    AMap2DView(
      webKey: '4e479545913a3a180b3cffc267dad646',
      onAMap2DViewCreated:onAMapViewCreated,
    );


class AMap2DView extends StatefulWidget {

  const AMap2DView({
    Key key,
    this.isPoiSearch: true,
    this.onPoiSearched,
    this.onAMap2DViewCreated,
    this.webKey,
  }) :super(key: key);

  final bool isPoiSearch;
  final MapCreatedCallback onAMap2DViewCreated;
  final Function(List<PoiSearch>) onPoiSearched;
  final String webKey;

  @override
  AMap2DViewState createState() => AMap2DViewState();
}

class AMap2DViewState extends State<AMap2DView> {

  /// 加载的插件
  final List<String> plugins = <String>['AMap.Geolocation', 'AMap.PlaceSearch', 'AMap.Scale', 'AMap.ToolBar'];
  
  AMap _aMap;
  String _divId;
  DivElement _element;

  void _onPlatformViewCreated() {

    var promise = load(LoaderOptions(
      key: widget.webKey,
      version: '1.4.15',
      plugins: plugins,
    ));

    promiseToFuture(promise).then((value){
      MapOptions _mapOptions = MapOptions(
        zoom: 11,
        resizeEnable: true,
      );
      /// 无法使用id https://github.com/flutter/flutter/issues/40080
      _aMap = AMap(_element, _mapOptions);
      /// 加载插件
      _aMap.plugin(plugins, allowInterop(() {
        // _aMap.addControl(Scale());
        // _aMap.addControl(ToolBar());

        final AMapWebController controller = AMapWebController(_aMap);
        if (widget.onAMap2DViewCreated != null) {
          widget.onAMap2DViewCreated(controller);
        }
      }));

    }, onError: (dynamic e) {
      debugPrint('初始化错误：$e');
    });
  }

  @override
  void dispose() {
    _aMap.destroy();
    _aMap = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _divId = DateTime.now().toIso8601String();
    /// 先创建div并注册
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_divId, (int viewId) {
      _element = DivElement()
      //   ..style.width = '100%'
      //   ..style.height = '100%'
      //   ..style.margin = '0'
      ;

      return _element;
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      /// 创建地图
      _onPlatformViewCreated();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: _divId,
    );
  }
}