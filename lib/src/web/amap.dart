library amap_base;

import 'dart:async';

import 'package:amap_base/amap_base.dart';
import 'package:amap_base/src/web/amap_location.dart';

AMap createAM()=>AMapWeb();

class AMapWeb extends AMap{

  static AMapWeb _instance;

  AMapWeb._();

  factory AMapWeb() {
    if (_instance == null) {
      _instance = AMapWeb._();
      return _instance;
    } else {
      return _instance;
    }
  }

  Future init(String key) async {
    // 加载asset相关信息, 供区分图片分辨率用, 因为native端的加载asset方法无法区分分辨率, 这是一个变通方法
    // assetManifest =
    //     await rootBundle.loadStructuredData<Map<String, List<String>>>(
    //   'AssetManifest.json',
    //   (String jsonData) {
    //     if (jsonData == null)
    //       return SynchronousFuture<Map<String, List<String>>>(null);
    //
    //     final Map<String, dynamic> parsedJson = json.decode(jsonData);
    //     final Iterable<String> keys = parsedJson.keys;
    //     final Map parsedManifest = Map<String, List<String>>.fromIterables(
    //       keys,
    //       keys.map<List<String>>((key) => List<String>.from(parsedJson[key])),
    //     );
    //     return SynchronousFuture<Map<String, List<String>>>(parsedManifest);
    //   },
    // );

    await AMapWebLocation().init();
  }

  @Deprecated('使用init方法初始化的时候设置key')
  Future setKey(String key) {

  }
}
