library amap_base;

import 'dart:async';

import 'package:amap_base/amap_base.dart';
import 'package:amap_base/src/web/amap_location.dart';

AMap createAM()=>AMapWeb();

class AMapWeb extends AMap{

  static AMapWeb _instance;

  String key='4e479545913a3a180b3cffc267dad646';

  AMapWeb._();

  factory AMapWeb() {
    if (_instance == null) {
      _instance = AMapWeb._();
      return _instance;
    } else {
      return _instance;
    }
  }

  Future init(String k) async {
    if(k?.isNotEmpty??false){
      key=k;
    }
    await AMapWebLocation().init(key:key);
  }

}
