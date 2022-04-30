import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ShapeModel {
  factory ShapeModel({
    Color color = Colors.white,
    List<Offset> points = const [],
    double strokeWidth = 1,
  }) {
    return ShapeModel._internal([...points], color, strokeWidth);
  }

  ShapeModel._internal(this._points, this.color, this.strokeWidth)
      : assert(strokeWidth > 0);

  //Each list is painted drawing lines from the first to the last point.
  List<Offset> _points;
  Color color;
  double strokeWidth;

  List<Offset> get points => _points;

  addPoint(Offset point) {
    _points.add(point);
  }

  @override
  operator ==(other) =>
      other is ShapeModel &&
      other.runtimeType == runtimeType &&
      listEquals(points, other.points);

  @override
  int get hashCode => points.hashCode + color.hashCode + strokeWidth.hashCode;
}
