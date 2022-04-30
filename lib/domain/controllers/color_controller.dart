import 'package:dft_drawer/domain/controllers/drawing_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class ColorController extends GetxController {
  // Define custom colors. The 'guide' color values are from
  // https://material.io/design/color/the-color-system.html#color-theme-creation
  static const Color guidePrimary = Color(0xFF6200EE);
  static const Color guidePrimaryVariant = Color(0xFF3700B3);
  static const Color guideSecondary = Color(0xFF03DAC6);
  static const Color guideSecondaryVariant = Color(0xFF018786);
  static const Color guideError = Color(0xFFB00020);
  static const Color guideErrorDark = Color(0xFFCF6679);
  static const Color blueBlues = Color(0xFF174378);

  // Make a custom ColorSwatch to name map from the above custom colors.
  final Map<ColorSwatch<Object>, String> colorsNameMap =
      <ColorSwatch<Object>, String>{
    ColorTools.createPrimarySwatch(guidePrimary): 'Guide Purple',
    ColorTools.createPrimarySwatch(guidePrimaryVariant): 'Guide Purple Variant',
    ColorTools.createAccentSwatch(guideSecondary): 'Guide Teal',
    ColorTools.createAccentSwatch(guideSecondaryVariant): 'Guide Teal Variant',
    ColorTools.createPrimarySwatch(guideError): 'Guide Error',
    ColorTools.createPrimarySwatch(guideErrorDark): 'Guide Error Dark',
    ColorTools.createPrimarySwatch(blueBlues): 'Blue blues',
  };

  static ColorController get i => Get.find();

  final _drawing = DrawingController.i;
  late Color _previousColor;

  List<Color> _recentColors = [];

  List<Color> get recentColors => _recentColors;

  set recentColors(List<Color> colors) {
    _recentColors = colors;
    update();
  }

  bool get hasSelectedShape => _drawing.selectedShape != null;

  Color get selectedShapeColor => _drawing.selectedShape!.color;

  set selectedShapeColor(Color? color) {
    if (color != null) _drawing.selectedShapeColor = color;
  }

  void saveCurrentColor() {
    _previousColor = _drawing.selectedShape!.color;
    _recentColors.addIf(
        !_recentColors.contains(_previousColor), _previousColor);

    if (recentColors.length > 20) recentColors.removeLast();
  }

  void restoreColor() => _drawing.selectedShapeColor = _previousColor;

  ///Deve ter borda em dois cenários:
  ///Quando a cor selecionada for branca ou muito próxima disso e
  ///Quando for transparente.
  bool withBorder() {
    final color = selectedShapeColor;

    if (color.alpha < 60 ||
        (color.red > 200 && color.green > 200 && color.blue > 200)) return true;

    return false;
  }
}
