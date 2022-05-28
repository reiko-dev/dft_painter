import 'package:dft_drawer/domain/entities/fourier.dart';
import 'package:dft_drawer/domain/utils/dft_algorithm.dart';
import 'package:dft_drawer/view/models/drawing_model.dart';
import 'package:flutter/foundation.dart';

class ComputeDrawingUsecase {
  Future<List<Fourier>> call(DrawingModel drawing) async {
    final List<List<double>> points = [];

    for (var shape in drawing.shapes) {
      for (int i = 0; i < shape.points.length; i += drawing.skipValue) {
        points.add([
          shape.points[i].dx - drawing.ellipsisCenter.dx,
          shape.points[i].dy - drawing.ellipsisCenter.dy,
        ]);
      }
    }

    final resultList = await compute(computeUserDrawingData, points);

    List<Fourier> fourierList = [];
    for (var rl in resultList) {
      fourierList.add(Fourier(
        freq: rl[0],
        amp: rl[1],
        re: rl[2],
        im: rl[3],
        phase: rl[4],
      ));
    }

    return fourierList;
  }
}
