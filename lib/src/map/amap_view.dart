
import 'dart:convert';

import 'package:amap_base/src/amap_view.dart';
import 'package:amap_base/src/common/misc.dart';
import 'package:amap_base/src/map/amap_controller.dart';
import 'package:amap_base/src/map/model/amap_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

Widget buildTargetAMapView({
  Key key,
  MapCreatedCallback onAMapViewCreated,
  PlatformViewHitTestBehavior hitTestBehavior = PlatformViewHitTestBehavior.opaque,
  TextDirection layoutDirection,
  AMapOptions aMapOptions = const AMapOptions(),
})=>AMapView(onAMapViewCreated: onAMapViewCreated,hitTestBehavior: hitTestBehavior,layoutDirection: layoutDirection,amapOptions: aMapOptions,);


const _viewType = 'me.yohom/AMapView';

class AMapView extends StatelessWidget {
  const AMapView({
    Key key,
    this.onAMapViewCreated,
    this.hitTestBehavior = PlatformViewHitTestBehavior.opaque,
    this.layoutDirection,
    this.amapOptions = const AMapOptions(),
  }) : super(key: key);

  final MapCreatedCallback onAMapViewCreated;
  final PlatformViewHitTestBehavior hitTestBehavior;
  final TextDirection layoutDirection;
  final AMapOptions amapOptions;

  @override
  Widget build(BuildContext context) {
    devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    final gestureRecognizers = <Factory<OneSequenceGestureRecognizer>>[
      Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
    ].toSet();

    final String params = jsonEncode(amapOptions.toJson());
    final messageCodec = StandardMessageCodec();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: _viewType,
        hitTestBehavior: hitTestBehavior,
        gestureRecognizers: gestureRecognizers,
        onPlatformViewCreated: _onViewCreated,
        layoutDirection: layoutDirection,
        creationParams: params,
        creationParamsCodec: messageCodec,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: _viewType,
        hitTestBehavior: hitTestBehavior,
        gestureRecognizers: gestureRecognizers,
        onPlatformViewCreated: _onViewCreated,
        layoutDirection: layoutDirection,
        creationParams: params,
        creationParamsCodec: messageCodec,
      );
    } else {
      return Text(
        '$defaultTargetPlatform is not yet supported by the maps plugin',
      );
    }
  }

  void _onViewCreated(int id) {
    final controller = AMapMobileController.withId(id);
    if (onAMapViewCreated != null) {
      onAMapViewCreated(controller);
    }
  }
}