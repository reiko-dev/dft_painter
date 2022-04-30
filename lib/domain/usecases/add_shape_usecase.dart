import 'package:dft_drawer/view/models/drawing_model.dart';
import 'package:dft_drawer/view/models/shape_model.dart';
import 'package:flutter/material.dart';

class AddShapeUsecase {
  bool call(
    DrawingModel drawing, {
    Color color = Colors.white,
    required List<Offset> points,
    double strokeWidth = 1,
  }) {
    drawing.shapes.add(
        ShapeModel(color: color, points: points, strokeWidth: strokeWidth));
    return true;
  }
}
