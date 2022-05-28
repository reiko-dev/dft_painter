import 'package:dft_drawer/domain/controllers/drawing_controller.dart';
import 'package:dft_drawer/view/pages/main/complex_dft_painter.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class DrawingAnimation extends StatefulWidget {
  const DrawingAnimation({Key? key}) : super(key: key);

  @override
  createState() => _ComplexDFTUserDrawerState();
}

class _ComplexDFTUserDrawerState extends State<DrawingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  bool isStarted = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      lowerBound: 0,
      upperBound: 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    if (controller.isAnimating) controller.stop();
    controller.dispose();
    super.dispose();
  }

  void startAnimation() {
    if (!isStarted) {
      controller.repeat();
      isStarted = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (DrawingController.i.animationState.value ==
            AnimationState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            return Stack(
              children: [
                CustomPaint(
                  painter: ComplexDFTPainter(
                    drawing: DrawingController.i,
                    style: AnimationStyle.loop,
                    startAnimation: startAnimation,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
