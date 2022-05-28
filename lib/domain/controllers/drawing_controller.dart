import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:dft_drawer/utils/dimensions_percent.dart';

import 'package:dft_drawer/domain/entities/fourier.dart';
import 'package:dft_drawer/domain/usecases/compute_shapes_usecase.dart';
import 'package:dft_drawer/view/models/drawing_model.dart';
import 'package:dft_drawer/view/models/shape_model.dart';
import 'package:dft_drawer/view/pages/main/complex_dft_painter.dart';

enum AnimationState { notReady, loading, loaded, animating, stopped }

class DrawingController extends GetxController {
  final computeDrawingUsecase = ComputeDrawingUsecase();

  static DrawingController get i => Get.find();

  DrawingController();

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

  AnimationState _animationState = AnimationState.notReady;

  AnimationState get animationState => _animationState;

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
    update();
  }

  set animationState(AnimationState state) {
    _animationState = state;
    update();
  }

  void addShape(ShapeModel shape) {
    _drawing.shapes.add(shape);
    _selectedShapeIndex = _drawing.shapes.length - 1;

    //Sets the values of the previous selected shape to the current selected Shape.
    if (_drawing.shapes.length > 1) {
      // _drawing.shapes[_selectedShapeIndex!].strokeWidth =
      //     _drawing.shapes[_selectedShapeIndex! - 1].strokeWidth;
      _drawing.shapes[_selectedShapeIndex!]
        ..strokeWidth = _drawing.shapes[_selectedShapeIndex! - 1].strokeWidth
        ..color = _drawing.shapes[_selectedShapeIndex! - 1].color;
    }
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

    _animationState = AnimationState.notReady;

    update();
  }

  //Must not be possible to change if there's not a shape drawn.
  set strokeWidth(double newStrokeWidth) {
    if (newStrokeWidth <= 0) {
      // print('Invalid newStrokeWidth $newStrokeWidth');
    } else {
      _drawing.shapes[selectedShapeIndex!].strokeWidth = newStrokeWidth;
      update();
    }
  }

  set ellipsisCenter(Offset ellipsisCenter) {
    //Only updates if the value entered is different from the current.
    if (_drawing.ellipsisCenter != ellipsisCenter) {
      _drawing.ellipsisCenter = ellipsisCenter;
      _animationState = AnimationState.notReady;
      update();
    }
  }

  void _setFourierList(List<Fourier> newFourierList, AnimationState state) {
    _drawing.fourierList = newFourierList;
    _animationState = state;
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
    _animationState = AnimationState.notReady;
    ComplexDFTPainter.clean();
    update();
  }

  void startAnimation() {
    if (hasShape()) {
      computeDrawingData();
    }
  }

  bool hasShape() {
    return _drawing.shapes.isNotEmpty && _drawing.shapes[0].points.isNotEmpty;
  }

  void clearData() {
    _drawing.clear();
    _selectedShapeIndex = null;
    _animationState = AnimationState.notReady;
    update();
  }

  Future<void> computeDrawingData() async {
    _setFourierList([], AnimationState.loading);

    final fourierList = await computeDrawingUsecase(_drawing);

    _setFourierList(fourierList, AnimationState.loaded);
  }
}
