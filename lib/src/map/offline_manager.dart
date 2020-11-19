import 'dart:async';

import 'package:amap_base/src/interface/map/offline_manager.dart';
import 'package:flutter/services.dart';

class OfflineManagerMobile extends OfflineManager {
  static OfflineManagerMobile _instance;

  static const _channel = MethodChannel('me.yohom/offline');

  OfflineManagerMobile._();

  factory OfflineManagerMobile() {
    if (_instance == null) {
      _instance = OfflineManagerMobile._();
      return _instance;
    } else {
      return _instance;
    }
  }

  /// 打开离线地图管理页
  @override
  Future openOfflineManager() {
    return _channel.invokeMethod('offline#openOfflineManager');
  }
}
