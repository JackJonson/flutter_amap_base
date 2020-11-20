import 'package:amap_base/amap_base.dart';
import 'package:amap_base/src/map/model/amap_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'amap_view_stub.dart'
    if (dart.library.html) 'package:amap_base/src/web/amap_view.dart'
    if (dart.library.io) 'package:amap_base/src/map/amap_view.dart';

typedef void MapCreatedCallback(AMapController controller);

Widget buildAMapView({
  Key key,
  MapCreatedCallback onAMapViewCreated,
  PlatformViewHitTestBehavior hitTestBehavior,
  TextDirection layoutDirection,
  AMapOptions aMapOptions,
}) =>
    buildTargetAMapView(
        key: key,
        onAMapViewCreated: onAMapViewCreated,
        hitTestBehavior: hitTestBehavior,
        layoutDirection: layoutDirection,
        aMapOptions: aMapOptions);

class AMapView extends StatelessWidget {
  final Key key;
  final MapCreatedCallback onAMapViewCreated;
  final PlatformViewHitTestBehavior hitTestBehavior;
  final TextDirection layoutDirection;
  final AMapOptions amapOptions;

  const AMapView({
    this.key,
    this.onAMapViewCreated,
    this.hitTestBehavior = PlatformViewHitTestBehavior.opaque,
    this.layoutDirection,
    this.amapOptions= const AMapOptions(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildAMapView(
      key: key,
      onAMapViewCreated: onAMapViewCreated,
      hitTestBehavior: hitTestBehavior,
      layoutDirection: layoutDirection,
      aMapOptions: amapOptions,
    );
  }
}
