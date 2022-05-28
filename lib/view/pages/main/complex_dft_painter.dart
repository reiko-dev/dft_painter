import 'dart:math';

import 'package:dft_drawer/domain/controllers/drawing_controller.dart';
import 'package:dft_drawer/domain/entities/fourier.dart';
import 'package:flutter/material.dart';

enum AnimationStyle { once, loop, loopOver }

class ComplexDFTPainter extends CustomPainter {
  ComplexDFTPainter({
    required this.drawing,
    required this.style,
    required this.startAnimation,
  });

  final Function startAnimation;
  final DrawingController drawing;
  final AnimationStyle style;

  double firstEllipseRadius = 0;

  static double time = 0;
  static List<Offset> path = [];
  static int currentDrawingIndex = 0;

  static List<List<Offset>> oldPaths = [];

  static void clean() {
    time = 0;
    path = [];
    currentDrawingIndex = 0;
    oldPaths = [];
  }

  bool hasFullyDrawnAShape() {
    int actualShapeLength =
        (drawing.shapes[currentDrawingIndex].points.length / drawing.skipValue)
            .truncate();
    if (drawing.shapes[currentDrawingIndex].points.length % drawing.skipValue !=
        0) actualShapeLength++;

    return path.length == actualShapeLength;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (hasFullyDrawnAShape()) {
      //Stores the path of the current shape if it hasn't been previousle stored.
      if (oldPaths.length <= currentDrawingIndex) {
        oldPaths.add([...path]);
      }
      path.clear();

      //Moves or to the next shape (if has one more) or to the first shape
      if (currentDrawingIndex + 1 < drawing.shapes.length) {
        currentDrawingIndex++;
      } else {
        currentDrawingIndex = 0;
      }
    }

    drawOldPaths(canvas);

    draw(
      drawing.fourierList,
      canvas,
      drawing.ellipsisCenter,
    );
  }

  ///
  ///The x/y Epicycle Positions  position the ellipsis group in the middle of the drawing container.
  ///
  draw(
    List<Fourier> fourier,
    Canvas canvas,
    Offset ellipsisCenter,
  ) {
    final currentPoint =
        epicycles(fourier, canvas, ellipsisCenter.dx, ellipsisCenter.dy);

    path.insert(0, currentPoint);

    // begin shape
    Path pathToDraw = Path()..moveTo(path.first.dx, path.first.dy);

    for (int i = 0; i < path.length; i++) {
      pathToDraw.lineTo(path[i].dx.toDouble(), path[i].dy);
    }
    //end shape

    final paint = Paint()
      ..color = drawing.shapes[currentDrawingIndex].color
      ..strokeWidth = drawing.shapes[currentDrawingIndex].strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(pathToDraw, paint);

    final dt = 2 * pi / fourier.length;
    time += dt;

    startAnimation();
  }

  void drawOldPaths(Canvas canvas) {
    if (oldPaths.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.stroke;

    final List<Path> paths = [];

    for (int i = 0; i < oldPaths.length; i++) {
      paths.add(Path());

      paths[i].moveTo(oldPaths[i].first.dx, oldPaths[i].first.dy);

      for (var point in oldPaths[i]) {
        paths[i].lineTo(point.dx, point.dy);
      }
    }

    for (int i = 0; i < paths.length; i++) {
      paint.color = drawing.shapes[i].color;
      paint.strokeWidth = drawing.shapes[i].strokeWidth;
      canvas.drawPath(paths[i], paint);
    }
  }

  Offset epicycles(
    List<Fourier> fourier,
    Canvas canvas,
    double xEpicyclePosition,
    double yEpicyclePosition,
  ) {
    Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.13)
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < fourier.length; i++) {
      double prevX = xEpicyclePosition;
      double prevY = yEpicyclePosition;

      int freq = fourier[i].freq;
      double radius = fourier[i].amp;
      double phase = fourier[i].phase;

      xEpicyclePosition += radius * cos(freq * time + phase);
      yEpicyclePosition += radius * sin(freq * time + phase);

      paint.strokeWidth = 2;
      canvas.drawCircle(Offset(prevX, prevY), radius, paint);

      //Draw a line to the center of the next circle.
      canvas.drawLine(Offset(prevX, prevY),
          Offset(xEpicyclePosition, yEpicyclePosition), paint);
    }

    return Offset(xEpicyclePosition, yEpicyclePosition);
  }

  @override
  bool shouldRepaint(covariant ComplexDFTPainter oldDelegate) {
    if (oldPaths.length == drawing.shapes.length) {
      switch (style) {
        case AnimationStyle.once:
          return false;

        case AnimationStyle.loop:
          clean();
          return true;

        default:
          return true;
      }
    }

    return true;
  }
}
