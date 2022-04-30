import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Shape {
  factory Shape({
    Color color = Colors.white,
    List<Offset> points = const [],
    double strokeWidth = 1,
  }) {
    return Shape._internal(color, points, strokeWidth);
  }
  Shape._internal(this.color, this.points, this.strokeWidth);

  //Each list is painted drawing lines from the first to the last point.
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  @override
  operator ==(other) =>
      other is Shape &&
      other.runtimeType == runtimeType &&
      listEquals(points, other.points);

  @override
  int get hashCode => points.hashCode + color.hashCode + strokeWidth.hashCode;
}
