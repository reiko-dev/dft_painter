import 'package:dft_drawer/data/worker/dft_worker_pool.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:dft_drawer/utils/dimensions_percent.dart';

import 'package:dft_drawer/domain/entities/fourier.dart';
import 'package:dft_drawer/domain/usecases/compute_shapes_usecase.dart';
import 'package:dft_drawer/view/models/drawing_model.dart';
import 'package:dft_drawer/view/models/shape_model.dart';
import 'package:dft_drawer/view/pages/main/complex_dft_painter.dart';
import 'package:squadron/squadron.dart';

enum AnimationState { notReady, loading, loaded, animating, stopped }

class DrawingController extends GetxController {
  final computeDrawingUsecase = ComputeDrawingUsecase();

  static DrawingController get i => Get.find();

  //properties
  final _drawing = DrawingModel(ellipsisCenter: Offset(45.0.wp, 40.0.hp));

  //Necessary for the delete shape widget
  int? _selectedShapeIndex;

  //Getters
  List<ShapeModel> get shapes => _drawing.shapes;

  ShapeModel? get selectedShape {
    if (_selectedShapeIndex != null) {
      return _drawing.shapes[_selectedShapeIndex!];
    } else {
      return null;
    }
  }

  List<Fourier> get fourierList => _drawing.fourierList;

  int get skipValue => _drawing.skipValue;

  Offset get ellipsisCenter => _drawing.ellipsisCenter;

  int? get selectedShapeIndex => _selectedShapeIndex;

  final animationState = AnimationState.notReady.obs;

  bool _cancel = false;
  CancellationToken? _cancelToken;
  final totalPointsToCompute = 0.obs;
  final computedPointsNumber = 0.obs;

  final _hasShape = false.obs;

  //Setters
  set selectedShapeIndex(int? newVal) {
    _selectedShapeIndex = newVal;
    update();
  }

  set selectedShapeColor(Color color) {
    _drawing.shapes[selectedShapeIndex!].color = color;
    update();
  }

  set shapes(List<ShapeModel> newShapes) {
    _drawing.shapes = newShapes;

    _hasShape.value =
        _drawing.shapes.isNotEmpty && _drawing.shapes[0].points.isNotEmpty;
    update();
  }

  void addShape(ShapeModel shape) {
    _drawing.shapes.add(shape);
    _selectedShapeIndex = _drawing.shapes.length - 1;

    //Sets the values of the previous selected shape to the current selected Shape.
    if (_drawing.shapes.length > 1) {
      _drawing.shapes[_selectedShapeIndex!]
        ..strokeWidth = _drawing.shapes[_selectedShapeIndex! - 1].strokeWidth
        ..color = _drawing.shapes[_selectedShapeIndex! - 1].color;
    }
    _hasShape.value =
        _drawing.shapes.isNotEmpty && _drawing.shapes[0].points.isNotEmpty;
    update();
  }

  //Removes the shape at the specified index, if it was specified. Else, removes the actual selected shape index.
  void removeShape({int? index}) {
    if (index == null) {
      if (selectedShapeIndex == null) {
        return;
      } else {
        index = selectedShapeIndex;
      }
    }

    _drawing.shapes.removeAt(index!);

    if (selectedShapeIndex == 0) {
      if (_drawing.shapes.isEmpty) {
        selectedShapeIndex = null;
      } else {
        selectedShapeIndex = _drawing.shapes.length - 1;
      }
    } else {
      selectedShapeIndex = selectedShapeIndex! - 1;
    }

    animationState.value = AnimationState.notReady;

    _hasShape.value =
        _drawing.shapes.isNotEmpty && _drawing.shapes[0].points.isNotEmpty;
    update();
  }

  //Must not be possible to change if there's not a shape drawn.
  set strokeWidth(double newStrokeWidth) {
    if (newStrokeWidth <= 0) {
      return;
    } else {
      _drawing.shapes[selectedShapeIndex!].strokeWidth = newStrokeWidth;
      update();
    }
  }

  set ellipsisCenter(Offset ellipsisCenter) {
    //Only updates if the value entered is different from the current.
    if (_drawing.ellipsisCenter != ellipsisCenter) {
      _drawing.ellipsisCenter = ellipsisCenter;
      animationState.value = AnimationState.notReady;
      update();
    }
  }

  void _setFourierList(List<Fourier> newFourierList, AnimationState state) {
    _drawing.fourierList = newFourierList;
    animationState.value = state;
    update();
  }

  void addFourier(Fourier fourier) {
    _drawing.fourierList.add(fourier);
    update();
  }

  void addPoint(Offset point) {
    if (shapes.isEmpty) {
      addShape(ShapeModel(points: [point]));
    } else {
      _drawing.shapes.last.addPoint(point);
      update();
    }
  }

  set skipValue(int newSkipValue) {
    _drawing.skipValue = newSkipValue;
    animationState.value = AnimationState.notReady;
    ComplexDFTPainter.clean();
    update();
  }

  void startAnimation() {
    if (hasShape()) {
      computeDrawingData();
    }
  }

  bool hasShape() {
    return _hasShape.value;
  }

  void clearData() {
    _drawing.clear();
    _selectedShapeIndex = null;
    animationState.value = AnimationState.notReady;
    _cancel = true;
    _cancelToken?.cancel();
    update();
  }

  void cancelComputing() {
    _cancel = true;
    _cancelToken?.cancel();
  }

  void computeDrawingData() async {
    _setFourierList([], AnimationState.loading);

    final List<List<double>> points = [];

    for (var shape in _drawing.shapes) {
      for (int i = 0; i < shape.points.length; i += _drawing.skipValue) {
        points.add([
          shape.points[i].dx - _drawing.ellipsisCenter.dx,
          shape.points[i].dy - _drawing.ellipsisCenter.dy,
        ]);
      }
    }
    computedPointsNumber.value = 0;
    totalPointsToCompute.value = points.length;
    try {
      Squadron.info('_startCompute called from ${StackTrace.current}');
      _cancel = false;
      _cancelToken = CancellationToken('Task was cancelled by the user');
      final dftWorkerPool = DftWorkerPool();
      await dftWorkerPool.start();

      var sw = Stopwatch()..start();
      if (_cancel) {
        Squadron.info('Computation has been cancelled');
      } else {
        try {
          Squadron.info('Computation started');

          final digits = dftWorkerPool.computeDFT(points, _cancelToken!);
          try {
            final fourierTempList = <Fourier>[];
            late Fourier f;
            await for (var d in digits) {
              computedPointsNumber.value++;
              f = Fourier(
                freq: d[0],
                amp: d[1],
                re: d[2],
                im: d[3],
                phase: d[4],
              );
              fourierTempList.add(f);
            }

            fourierTempList.sort((a, b) => b.amp.compareTo(a.amp));
            _setFourierList(fourierTempList, AnimationState.loaded);

            Squadron.info('Computation completed successfully');
          } on CancelledException catch (e) {
            Squadron.info('Computation cancelled: ${e.message}');
          } on WorkerException catch (e) {
            Squadron.info('Computation failed: ${e.message}');
          } catch (e) {
            Squadron.info('Computation failed: $e');
          }
        } on CancelledException {
          _cancel = true;
          Squadron.info(
              '[_loadDftWorkerPool] computation has been cancelled by user');
        }
      }

      sw.stop();
      Squadron.info('[_loadDftWorkerPool] elapsed = ${sw.elapsed}');
    } catch (e, st) {
      Squadron.info('[_loadDftWorkerPool] ERROR = $e');
      Squadron.info('[_loadDftWorkerPool] TRACE = $st');
    } finally {
      animationState.value = AnimationState.loaded;
    }
  }
}
