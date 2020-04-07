//
// Created by Yohom Bao on 2018/11/25.
//

#import "AMapViewFactory.h"
#import "MAMapView.h"
#import "MapModels.h"
#import "AMapBasePlugin.h"
#import "UnifiedAssets.h"
#import "MJExtension.h"
#import "NSString+Color.h"
#import "FunctionRegistry.h"
#import "MapHandlers.h"

static NSString *mapChannelName = @"me.yohom/map";
static NSString *markerClickedChannelName = @"me.yohom/marker_clicked";
static NSString *cameraChangeEventChannelName = @"me.yohom/camera_changed";
static NSString *touchEventChannelName = @"me.yohom/map_touch";

@interface MarkerEventHandler : NSObject <FlutterStreamHandler>
@property(nonatomic) FlutterEventSink sink;
@end

@interface CameraChangeEventHandler : NSObject <FlutterStreamHandler>
@property(nonatomic) FlutterEventSink sink;
@end

@interface TouchEventEventHandler : NSObject <FlutterStreamHandler>
@property(nonatomic) FlutterEventSink sink;
@end

@implementation MarkerEventHandler {
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
  _sink = events;
  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  return nil;
}
@end

@implementation CameraChangeEventHandler {
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
  _sink = events;
  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  return nil;
}
@end

@implementation TouchEventEventHandler {
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
  _sink = events;
  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  return nil;
}
@end

@implementation AMapViewFactory {
}

- (NSObject <FlutterMessageCodec> *)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject <FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                     viewIdentifier:(int64_t)viewId
                                          arguments:(id _Nullable)args {
  UnifiedAMapOptions *options = [UnifiedAMapOptions mj_objectWithKeyValues:(NSString *) args];

  AMapView *view = [[AMapView alloc] initWithFrame:frame
                                           options:options
                                    viewIdentifier:viewId];
  return view;
}

@end

@implementation AMapView {
  CGRect _frame;
  int64_t _viewId;
  UnifiedAMapOptions *_options;
  FlutterMethodChannel *_methodChannel;
  FlutterEventChannel *_markerClickedEventChannel;
  FlutterEventChannel *_cameraChangeEventChannel;
  FlutterEventChannel *_touchEventChannel;
  MAMapView *_mapView;
  MarkerEventHandler *_eventHandler;
  CameraChangeEventHandler *_cameraHandler;
  TouchEventEventHandler *_touchHandler;
    CameraPosition *_cameraData;
  bool _panAnn;
}

- (instancetype)initWithFrame:(CGRect)frame
                      options:(UnifiedAMapOptions *)options
               viewIdentifier:(int64_t)viewId {
  self = [super init];
  if (self) {
    _frame = frame;
    _viewId = viewId;
    _options = options;

    _mapView = [[MAMapView alloc] initWithFrame:_frame];
    [self setup];
  }
  return self;
}

- (UIView *)view {
  return _mapView;
}

- (void)setup {
  //region 初始化地图配置
  // 尽可能地统一android端的api了, ios这边的配置选项多很多, 后期再观察吧
  // 因为android端的mapType从1开始, 所以这里减去1
  _mapView.mapType = (MAMapType) (_options.mapType - 1);
  _mapView.showsScale = _options.scaleControlsEnabled;
  _mapView.zoomEnabled = _options.zoomGesturesEnabled;
  _mapView.showsCompass = _options.compassEnabled;
  _mapView.scrollEnabled = _options.scrollGesturesEnabled;
  _mapView.cameraDegree = _options.camera.tilt;
  _mapView.rotateEnabled = _options.rotateGesturesEnabled;
  if (_options.camera.target) {
    _mapView.centerCoordinate = [_options.camera.target toCLLocationCoordinate2D];
  }
  _mapView.zoomLevel = _options.camera.zoom;
  // fixme: logo位置设置无效
  CGPoint logoPosition = CGPointMake(0, _mapView.bounds.size.height);
  if (_options.logoPosition == 0) { // 左下角
    logoPosition = CGPointMake(0, _mapView.bounds.size.height);
  } else if (_options.logoPosition == 1) { // 底部中央
    logoPosition = CGPointMake(_mapView.bounds.size.width / 2, _mapView.bounds.size.height);
  } else if (_options.logoPosition == 2) { // 底部右侧
    logoPosition = CGPointMake(_mapView.bounds.size.width, _mapView.bounds.size.height);
  }
  _mapView.logoCenter = logoPosition;
  _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  //endregion

  _methodChannel = [FlutterMethodChannel methodChannelWithName:[NSString stringWithFormat:@"%@%lld", mapChannelName, _viewId]
                                               binaryMessenger:[AMapBasePlugin registrar].messenger];
  __weak __typeof__(self) weakSelf = self;
  [_methodChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    NSObject <MapMethodHandler> *handler = [MapFunctionRegistry mapMethodHandler][call.method];
    if (handler) {
      __typeof__(self) strongSelf = weakSelf;
      [[handler initWith:strongSelf->_mapView] onMethodCall:call :result];
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
  _mapView.delegate = weakSelf;

  _eventHandler = [[MarkerEventHandler alloc] init];
  _cameraHandler = [[CameraChangeEventHandler alloc] init];
  _touchHandler = [[TouchEventEventHandler alloc] init];
  _markerClickedEventChannel = [FlutterEventChannel eventChannelWithName:[NSString stringWithFormat:@"%@%lld", markerClickedChannelName, _viewId]
                                                         binaryMessenger:[AMapBasePlugin registrar].messenger];
  [_markerClickedEventChannel setStreamHandler:_eventHandler];
  _cameraChangeEventChannel = [FlutterEventChannel eventChannelWithName:[NSString stringWithFormat:@"%@", cameraChangeEventChannelName]
                                                            binaryMessenger:[AMapBasePlugin registrar].messenger];
  [_cameraChangeEventChannel setStreamHandler:_cameraHandler];
  _touchEventChannel = [FlutterEventChannel eventChannelWithName:[NSString stringWithFormat:@"%@", touchEventChannelName]
                                                              binaryMessenger:[AMapBasePlugin registrar].messenger];
  [_touchEventChannel setStreamHandler:_touchHandler];
}

#pragma MAMapViewDelegate

/// 点击annotation回调
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
  if ([view.annotation isKindOfClass:[MarkerAnnotation class]]) {
    MarkerAnnotation *annotation = (MarkerAnnotation *) view.annotation;
    _panAnn = true;
    _cameraData = nil;
    _eventHandler.sink([annotation.markerOptions mj_JSONString]);
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent*)event{
    [super touchesBegan:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:_mapView];
    CGPoint windowPoint = [touch locationInView:nil];
    winPoint *winP = [[winPoint alloc]init];
    winP.action = 1;
    winP.x = point.x + 0.00000000001;
    winP.y = point.y + 0.00000000001;
    winP.rawX = windowPoint.x + 0.00000000001;
    winP.rawY = windowPoint.y + 0.00000000001;
    _touchHandler.sink([winP mj_JSONString]);
}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{
    [super touchesMoved:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:_mapView];
    CGPoint windowPoint = [touch locationInView:nil];
    winPoint *winP = [[winPoint alloc]init];
    winP.action = 2;
    winP.x = point.x + 0.00000000001;
    winP.y = point.y + 0.00000000001;
    winP.rawX = windowPoint.x + 0.00000000001;
    winP.rawY = windowPoint.y + 0.00000000001;
    _touchHandler.sink([winP mj_JSONString]);
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event{
    [super touchesEnded:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:_mapView];
    CGPoint windowPoint = [touch locationInView:nil];
    winPoint *winP = [[winPoint alloc]init];
    winP.action = 3;
    winP.x = point.x + 0.00000000001;
    winP.y = point.y + 0.00000000001;
    winP.rawX = windowPoint.x + 0.00000000001;
    winP.rawY = windowPoint.y + 0.00000000001;
    _touchHandler.sink([winP mj_JSONString]);
}

-(void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event{
    [super touchesCancelled:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:_mapView];
    CGPoint windowPoint = [touch locationInView:nil];
    winPoint *winP = [[winPoint alloc]init];
    winP.action = 4;
    winP.x = point.x + 0.00000000001;
    winP.y = point.y + 0.00000000001;
    winP.rawX = windowPoint.x + 0.00000000001;
    winP.rawY = windowPoint.y + 0.00000000001;
    _touchHandler.sink([winP mj_JSONString]);
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

/// 地图平移回调
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction{
    if (wasUserAction || nil == _cameraData) {
        CLLocationCoordinate2D coor = mapView.centerCoordinate;
        LatLng *latlng = [LatLng new];
        latlng.latitude = coor.latitude;
        latlng.longitude = coor.longitude;
        CGFloat zoom = mapView.zoomLevel;
        _cameraData = [[CameraPosition alloc]init];
        _cameraData.target = latlng;
        _cameraData.zoom = zoom + 0.00000001;
        _cameraData.tilt = 0.00000001;
        _cameraData.bearing = 0.00000001;
        _cameraHandler.sink([_cameraData mj_JSONString]);
        if (!_panAnn ) {
            winPoint *winP = [[winPoint alloc]init];
            winP.action = 2;
            winP.x = [UIScreen mainScreen].bounds.size.width/2 + 0.00000000001;
            winP.y = [UIScreen mainScreen].bounds.size.height/2 + 0.00000000001;
            winP.rawX = [UIScreen mainScreen].bounds.size.width/2 + 0.00000000001;;
            winP.rawY = [UIScreen mainScreen].bounds.size.height/2 + 0.00000000001;
            _touchHandler.sink([winP mj_JSONString]);
        }else{
            _panAnn = false;
        }
    }
}

- (NSString *)tojson:(NSDictionary *)dict{
    NSError *error = nil;
    NSData *jsonData = nil;
    if (!self) {
        return nil;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *keyString = nil;
        NSString *valueString = nil;
        if ([key isKindOfClass:[NSString class]]) {
            keyString = key;
        }else{
            keyString = [NSString stringWithFormat:@"%@",key];
        }

        if ([obj isKindOfClass:[NSString class]]) {
            valueString = obj;
        }else{
            valueString = [NSString stringWithFormat:@"%@",obj];
        }

        [dic setObject:valueString forKey:keyString];
    }];
    jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if ([jsonData length] == 0 || error != nil) {
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

/// 渲染overlay回调
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay {
  // 绘制折线
  if ([overlay isKindOfClass:[PolylineOverlay class]]) {
    PolylineOverlay *polyline = (PolylineOverlay *) overlay;

    MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:polyline];

    UnifiedPolylineOptions *options = [polyline options];

    polylineRenderer.lineWidth = (CGFloat) (options.width * 0.5); // 相同的值, Android的线比iOS的粗
    polylineRenderer.strokeColor = [options.color hexStringToColor];
    polylineRenderer.lineJoinType = (MALineJoinType) options.lineJoinType;
    polylineRenderer.lineCapType = (MALineCapType) options.lineCapType;
    if (options.isDottedLine) {
      polylineRenderer.lineDashType = (MALineDashType) ((MALineCapType) options.dottedLineType + 1);
    } else {
      polylineRenderer.lineDashType = kMALineDashTypeNone;
    }

    return polylineRenderer;
  }

  return nil;
}

/// 渲染annotation, 就是Android中的marker
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
  if ([annotation isKindOfClass:[MAUserLocation class]]) {
    return nil;
  }

  if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
    static NSString *routePlanningCellIdentifier = @"RoutePlanningCellIdentifier";

    MAAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:routePlanningCellIdentifier];
    if (annotationView == nil) {
      annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                    reuseIdentifier:routePlanningCellIdentifier];
    }

    if ([annotation isKindOfClass:[MarkerAnnotation class]]) {
      UnifiedMarkerOptions *options = ((MarkerAnnotation *) annotation).markerOptions;
      annotationView.zIndex = (NSInteger) options.zIndex;
      if (options.icon != nil) {
        annotationView.image = [UIImage imageWithContentsOfFile:[UnifiedAssets getAssetPath:options.icon]];
      } else {
        annotationView.image = [UIImage imageWithContentsOfFile:[UnifiedAssets getDefaultAssetPath:@"images/default_marker.png"]];
      }
      annotationView.centerOffset = CGPointMake(options.anchorU, options.anchorV);
      annotationView.calloutOffset = CGPointMake(options.infoWindowOffsetX, options.infoWindowOffsetY);
      annotationView.draggable = options.draggable;
      annotationView.canShowCallout = false;
      annotationView.enabled = options.enabled;
      annotationView.highlighted = options.highlighted;
      annotationView.selected = options.selected;
    } else {
      if ([[annotation title] isEqualToString:@"起点"]) {
        annotationView.image = [UIImage imageWithContentsOfFile:[UnifiedAssets getDefaultAssetPath:@"images/amap_start.png"]];
      } else if ([[annotation title] isEqualToString:@"终点"]) {
        annotationView.image = [UIImage imageWithContentsOfFile:[UnifiedAssets getDefaultAssetPath:@"images/amap_end.png"]];
      }
    }

    if (annotationView.image != nil) {
      CGSize size = annotationView.imageView.frame.size;
      annotationView.frame = CGRectMake(annotationView.center.x + size.width / 2, annotationView.center.y, 36, 36);
      annotationView.centerOffset = CGPointMake(0, -18);
    }

    return annotationView;
  }

  return nil;
}

@end
