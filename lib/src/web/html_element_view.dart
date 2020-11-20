import 'dart:async';
import 'dart:typed_data';

import 'package:amap_base/amap_base.dart';
import 'package:amap_base/src/amap_view.dart';
import 'package:amap_base/src/map/model/amap_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// https://github.com/deakjahn/flutter_dropzone
// https://github.com/flutter/flutter/issues/56181

Widget buildTargetAMapView({
  Key key,
  MapCreatedCallback onAMapViewCreated,
  PlatformViewHitTestBehavior hitTestBehavior =
      PlatformViewHitTestBehavior.opaque,
  TextDirection layoutDirection,
  AMapOptions aMapOptions = const AMapOptions(),
}) =>
    HtmlElementViewEx(
      viewType: DateTime.now().toIso8601String(),
      onAMapViewCreated: onAMapViewCreated,
      aMapOptions: aMapOptions,
    );

class HtmlElementViewEx extends HtmlElementView{
  final MapCreatedCallback onAMapViewCreated; //!!!
  final AMapOptions aMapOptions;

  const HtmlElementViewEx(
      {Key key,
      @required String viewType,
      this.onAMapViewCreated,
      this.aMapOptions})
      : super(key: key, viewType: viewType);

  @override
  Widget build(BuildContext context) => PlatformViewLink(
        viewType: viewType,
        onCreatePlatformView: _createHtmlElementView,
        surfaceFactory:
            (BuildContext context, PlatformViewController controller) =>
                PlatformViewSurface(
          controller: controller,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        ),
      );

  _HtmlElementViewControllerEx _createHtmlElementView(
      PlatformViewCreationParams params) {
    final _HtmlElementViewControllerEx controller =
        _HtmlElementViewControllerEx(params.id, viewType);
    controller._initialize().then((_) {
      params.onPlatformViewCreated(params.id);
      if (onAMapViewCreated != null) {
        onAMapViewCreated(controller);
      }
    });
    return controller;
  }

  void _onViewCreated(int id) {
    final controller = AMapMobileController.withId(id);
    if (onAMapViewCreated != null) {
      onAMapViewCreated(controller);
    }
  }
}

class _HtmlElementViewControllerEx extends PlatformViewController
    implements AMapController {
  @override
  final int viewId;
  final String viewType;
  bool _initialized = false;

  _HtmlElementViewControllerEx(this.viewId, this.viewType);

  Future<void> _initialize() async {
    await SystemChannels.platform_views
        .invokeMethod<void>('create', {'id': viewId, 'viewType': viewType});
    _initialized = true;
  }

  @override
  Future<void> clearFocus() {}

  @override
  Future<void> dispatchPointerEvent(PointerEvent event) {}

  @override
  Future<void> dispose() {
    if (_initialized)
      SystemChannels.platform_views.invokeMethod<void>('dispose', viewId);
  }

  @override
  Future addMarker(MarkerOptions options,
      {bool lockedToScreen = false, bool openAnimation = true}) {
    // TODO: implement addMarker
    throw UnimplementedError();
  }

  @override
  Future addMarkers(List<MarkerOptions> optionsList,
      {bool moveToCenter = true,
      bool clear = false,
      bool clearLast = false,
      bool openAnimation = true}) {
    // TODO: implement addMarkers
    throw UnimplementedError();
  }

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
    throw UnimplementedError();
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
  Future<LatLng> getCenterLatlng() {
    // TODO: implement getCenterLatlng
    throw UnimplementedError();
  }

  @override
  // TODO: implement mapTouchEvent
  Stream<TouchEvent> get mapTouchEvent => throw UnimplementedError();

  @override
  // TODO: implement markerClickedEvent
  Stream<MarkerOptions> get markerClickedEvent => throw UnimplementedError();

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
}
