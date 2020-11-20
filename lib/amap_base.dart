library amap_base;

import 'dart:async';

export 'amap_base.dart';
export 'src/amap_view.dart';
export 'src/common/permissions.dart';
export 'src/common/permissions.dart';
export 'src/common/permissions.dart';
export 'src/interface/location/amap_location.dart';
export 'src/interface/map/amap_controller.dart';
export 'src/interface/map/calculate_tool.dart';
export 'src/interface/map/offline_manager.dart';
export 'src/interface/navi/amap_navi.dart';
export 'src/interface/search/amap_search.dart';
export 'src/location/amap_location.dart';
export 'src/location/model/location.dart';
export 'src/location/model/location_client_options.dart';
export 'src/map/amap_controller.dart';
export 'src/map/calculate_tool.dart';
export 'src/map/model/amap_options.dart';
export 'src/map/model/camera_position.dart';
export 'src/map/model/latlng.dart';
export 'src/map/model/marker_options.dart';
export 'src/map/model/my_location_style.dart';
export 'src/map/model/polyline_options.dart';
export 'src/map/model/route_overlay.dart';
export 'src/map/model/touch_event.dart';
export 'src/map/model/ui_settings.dart';
export 'src/map/offline_manager.dart';
export 'src/navi/amap_navi.dart';
export 'src/search/amap_search.dart';
export 'src/search/model/drive_route_result.dart';
export 'src/search/model/geocode_result.dart';
export 'src/search/model/poi_item.dart';
export 'src/search/model/poi_result.dart';
export 'src/search/model/poi_search_query.dart';
export 'src/search/model/regeocode_result.dart';
export 'src/search/model/route_plan_param.dart';
export 'src/search/model/route_poi_result.dart';
export 'src/search/model/route_poi_search_query.dart';
export 'src/search/model/search_bound.dart';
import 'package:amap_base/src/amap_base_stub.dart'
    if(dart.library.html) 'package:amap_base/src/web/amap.dart'
    if(dart.library.io) 'package:amap_base/src/common/amap.dart';


AMap createAMap()=>createAM();

class AMap {
  Map<String, List<String>> assetManifest;
  Future init(String key) async {
    return createAMap().init(key);
  }

  @Deprecated('使用init方法初始化的时候设置key')
  Future setKey(String key) {
    return createAMap().setKey(key);
  }
}
