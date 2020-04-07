import 'dart:convert';

import 'package:amap_base/src/map/model/latlng.dart';

/// Android全部有效, iOS部分有效
class CameraPosition {
  CameraPosition({
    this.target = const LatLng(39.8994731, 116.4142794),
    this.zoom = 10,
    this.tilt = 0,
    double bearing = 360,
  }) : this.bearing =
            (bearing <= 0.0 ? bearing % 360.0 + 360.0 : bearing) % 360.0;

  /// 目标位置的屏幕中心点经纬度坐标。默认北京 [Android, iOS]
  LatLng target;

  /// 目标可视区域的缩放级别。 [Android, iOS]
  double zoom;

  /// 目标可视区域的倾斜度，以角度为单位。 [Android]
  double tilt;

  /// 可视区域指向的方向，以角度为单位，从正北向逆时针方向计算，从0 度到360 度。 [Android]
  double bearing;

  Map<String, Object> toJson() {
    return {
      'target': target.toJson(),
      'zoom': zoom,
      'tilt': tilt,
      'bearing': bearing,
    };
  }

  CameraPosition.fromJson(Map<String, Object> json) {
    target =
        json['target'] != null ? LatLng.fromJson(json['target']) : null;
    zoom = json['zoom'] as num;
    tilt = json['tilt'] as num;
    bearing = json['bearing'] as num;
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraPosition &&
          runtimeType == other.runtimeType &&
          target == other.target &&
          zoom == other.zoom &&
          tilt == other.tilt &&
          bearing == other.bearing;

  @override
  int get hashCode =>
      target.hashCode ^ zoom.hashCode ^ tilt.hashCode ^ bearing.hashCode;

  @override
  String toString() {
    return 'CameraPosition{target: $target, zoom: $zoom, tilt: $tilt, bearing: $bearing}';
  }
}
