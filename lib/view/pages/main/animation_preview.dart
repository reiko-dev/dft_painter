import 'package:dft_drawer/domain/controllers/drawing_controller.dart';
import 'package:dft_drawer/utils/drawings.dart';
import 'package:dft_drawer/view/models/shape_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimationPreview extends StatefulWidget {
  const AnimationPreview({Key? key}) : super(key: key);

  @override
  _AnimationPreviewState createState() => _AnimationPreviewState();
}

class _AnimationPreviewState extends State<AnimationPreview> {
  bool newList = true;
  final gkey = GlobalKey();

  @override
  void initState() {
    super.initState();

    addDefaultDrawing(drawing);
  }

  ///This method can be used for adding drawings
  void addDefaultDrawing(List<Offset> points) {
    Future.delayed(Duration.zero).then((value) {
      RenderBox box = gkey.currentContext?.findRenderObject() as RenderBox;

      final localWidgetCenter = box.paintBounds.center;

      DrawingController.i.shapes.clear();

      List<Offset> centralizedPoints = [];
      final drawingRect = rectFromPoints(points);

      for (var i = 0; i < points.length; i++) {
        centralizedPoints.add(
          Offset(points[i].dx, points[i].dy) +
              localWidgetCenter -
              drawingRect.center,
        );
      }

      DrawingController.i.addShape(ShapeModel(points: centralizedPoints));
    });
  }

  Rect rectFromPoints(List<Offset> points) {
    double left = points.first.dx;
    double right = points.first.dx;
    double top = points.first.dy;
    double bottom = points.first.dy;

    for (int i = 1; i < points.length; i++) {
      if (points[i].dx < left) {
        left = points[i].dx;
        continue;
      }

      if (points[i].dx > right) {
        right = points[i].dx;
        continue;
      }
      if (points[i].dy < top) {
        top = points[i].dy;
        continue;
      }
      if (points[i].dy > bottom) {
        bottom = points[i].dy;
      }
    }

    return Rect.fromPoints(Offset(left, top), Offset(right, bottom));
  }

  void onPanUpdate(DragUpdateDetails dragDetails) {
    final point = Offset(
      dragDetails.localPosition.dx,
      dragDetails.localPosition.dy,
    );

    if (newList) {
      DrawingController.i.addShape(ShapeModel(points: [point]));
      newList = false;
    } else {
      DrawingController.i.addPoint(point);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: onPanUpdate,
      onPanEnd: (_) => newList = true,
      child: Container(
        key: gkey,
        color: Colors.black,
        child: GetBuilder<DrawingController>(builder: (drawingController) {
          return drawingController.hasShape()
              ? CustomPaint(
                  painter: AnimationPreviewPainter(dc: drawingController),
                  willChange: true,
                  isComplex: true,
                )
              : const SizedBox.shrink();
        }),
      ),
    );
  }
}

class AnimationPreviewPainter extends CustomPainter {
  AnimationPreviewPainter({required this.dc});

  final DrawingController dc;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = dc.selectedShape!.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;

    for (var shape in dc.shapes) {
      final path = Path()
        ..moveTo(
          shape.points.first.dx,
          shape.points.first.dy,
        );
      for (var element in shape.points) {
        path.lineTo(element.dx, element.dy);
      }
      canvas.drawPath(
        path,
        paint
          ..strokeWidth = shape.strokeWidth
          ..color = shape.color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AnimationPreviewPainter oldDelegate) {
    return listEquals(oldDelegate.dc.shapes, dc.shapes);
  }
}
