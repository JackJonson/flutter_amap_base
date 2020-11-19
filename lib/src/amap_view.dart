import 'dart:convert';

import 'package:amap_base/amap_base.dart';
import 'package:amap_base/src/common/misc.dart';
import 'package:amap_base/src/map/model/amap_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'amap_view_stub.dart'
    if (dart.library.html) 'package:amap_base/src/web/html_element_view.dart'
    if (dart.library.io) 'package:amap_base/src/map/amap_view.dart';

typedef void MapCreatedCallback(AMapController controller);

Widget buildAMapView({
  Key key,
  MapCreatedCallback onAMapViewCreated,
  PlatformViewHitTestBehavior hitTestBehavior,
  TextDirection layoutDirection,
  AMapOptions aMapOptions,
}) =>
    buildTargetAMapView();
