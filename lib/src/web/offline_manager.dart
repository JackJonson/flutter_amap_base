import 'dart:async';

import 'package:amap_base/src/interface/map/offline_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

OfflineManager createOfflineManager()=>OfflineManagerWeb();

class OfflineManagerWeb extends OfflineManager {
  static OfflineManagerWeb _instance;

  OfflineManagerWeb._();

  factory OfflineManagerWeb() {
    if (_instance == null) {
      _instance = OfflineManagerWeb._();
      return _instance;
    } else {
      return _instance;
    }
  }

  /// 打开离线地图管理页
  @override
  Future openOfflineManager() {
    debugPrint('Offline map not supported in web');
    return Future.value();
  }
}
