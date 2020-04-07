import 'dart:convert';

///Touch event model
class TouchEvent {
  ///Action down
  static const int ACTION_DOWN = 1;
  ///Action move
  static const int ACTION_MOVE = 2;
  ///Action up
  static const int ACTION_UP = 3;
  ///Action cancel
  static const int ACTION_CANCEL = 4;

  ///Touch action
  final int action;
  ///The axis x position of touch point
  final double x;
  ///The axis y position of touch point
  final double y;
  ///The raw axis x position of touch point
  final double rawX;
  ///The raw axis y position of touch point
  final double rawY;

  const TouchEvent(
    this.action,
    this.x,
    this.y,
    this.rawX,
    this.rawY,
  );

  Map<String, Object> toJson() {
    return {
      'action': action,
      'x': x,
      'y': y,
      'rawX': rawX,
      'rawY': rawY,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  TouchEvent.fromJson(Map<String, dynamic> json)
      : action = json['action'] as int,
        x = json['x'] as double,
        y = json['y'] as double,
        rawX = json['rawX'] as double,
        rawY = json['rawY'] as double;

  TouchEvent copyWith({
    double latitude,
    double longitude,
  }) {
    return TouchEvent(
      action ?? this.action,
      x ?? this.x,
      y ?? this.y,
      rawX ?? this.rawX,
      rawY ?? this.rawY,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TouchEvent &&
          runtimeType == other.runtimeType &&
          action == other.action &&
          x == other.x &&
          y == other.y &&
          rawX == other.rawX &&
          rawY == other.rawY;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() {
    return 'TouchEvent{action: $action, x: $x, y: $y, rawX: $rawX, rawY: $rawY}';
  }
}
