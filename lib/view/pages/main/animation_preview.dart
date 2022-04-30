import 'package:dft_drawer/domain/controllers/drawing_controller.dart';
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

  @override
  void initState() {
    super.initState();
    //Adds a default drawing
    // Future.delayed(Duration.zero).then((value) {
    //   if (!DrawingController.i.hasPoint()) {
    //     List<Offset> newList = [];
    //     for (var i = 0; i < drawing.length; i++) {
    //       newList.add(
    //         Offset(drawing[i].dx + 458, drawing[i].dy + 262),
    //       );
    //     }
    //     DrawingController.i.addShape(ShapeModel(points: newList));
    //   }
    // });
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
