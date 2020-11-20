import 'dart:async';

import 'package:amap_base/src/interface/map/offline_manager_stub.dart'
     if(dart.library.html) 'package:amap_base/src/web/offline_manager.dart'
     if(dart.library.io) 'package:amap_base/src/map/offline_manager.dart';

OfflineManager createOffline()=>createOfflineManager();

class OfflineManager {
  /// 打开离线地图管理页
  Future openOfflineManager(){
    return createOffline().openOfflineManager();
  }
}
