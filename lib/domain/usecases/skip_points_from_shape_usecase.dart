import 'package:dft_drawer/view/models/shape_model.dart';
import 'package:flutter/material.dart';

class SkipPointsFromShapeUsecase {
  List<Offset> skipPoints(ShapeModel shape, int skipValue) {
    final List<Offset> listWithSkippedIPoints = [];

    for (int i = 0; i < shape.points.length; i += skipValue) {
      listWithSkippedIPoints.add(shape.points[i]);
    }

    return listWithSkippedIPoints;
  }
}
