import 'package:dft_drawer/domain/algorithms/dft_algorithm.dart';
import 'package:dft_drawer/domain/entities/fourier.dart';
import 'package:dft_drawer/view/models/drawing_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ComputeDrawingUsecase {
  Future<List<Fourier>> call(DrawingModel drawing) async {
    final List<Offset> points = [];

    for (var shape in drawing.shapes) {
      for (int i = 0; i < shape.points.length; i += drawing.skipValue) {
        points.add(
          Offset(
            shape.points[i].dx - drawing.ellipsisCenter.dx,
            shape.points[i].dy - drawing.ellipsisCenter.dy,
          ),
        );
      }
    }

    return await compute(computeUserDrawingData, points);
  }
}
