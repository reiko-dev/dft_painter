import 'package:dft_drawer/domain/entities/shape.dart';
import 'package:flutter/foundation.dart';

class Drawing {
  Drawing(this._shapes, this._strokeWidth, this._fourierList);

  //properties
  final List<Shape> _shapes;
  final double _strokeWidth;
  final List<Map<String, dynamic>> _fourierList;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Drawing &&
          runtimeType == other.runtimeType &&
          _strokeWidth == other._strokeWidth &&
          listEquals(_fourierList, other._fourierList) &&
          listEquals(_shapes, other._shapes);

  @override
  int get hashCode =>
      _shapes.hashCode + _strokeWidth.hashCode + _fourierList.hashCode;
}
