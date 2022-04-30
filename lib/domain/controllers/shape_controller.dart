import 'package:get/get.dart';

import 'package:dft_drawer/view/models/shape_model.dart';

class ShapeController extends GetxController {
  ShapeController(this._shape);

  ShapeModel _shape;

  ShapeModel get shape => _shape;

  set shape(ShapeModel shape) {
    _shape = shape;
    update();
  }
}
