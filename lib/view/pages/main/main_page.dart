import 'package:dft_drawer/view/pages/main/bottom_panel.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:dft_drawer/utils/dimensions_percent.dart';

import 'package:dft_drawer/domain/controllers/drawing_controller.dart';
import 'package:dft_drawer/view/pages/main/animation_preview.dart';
import 'package:dft_drawer/view/pages/main/drawing_animation.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: size.width,
        height: size.height,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: 90.0.wp,
              height: 80.0.hp,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: GetBuilder<DrawingController>(
                builder: (_) {
                  return _.animationState.value == AnimationState.notReady
                      ? const AnimationPreview()
                      : GestureDetector(
                          onTap: () {
                            _.animationState.value = AnimationState.notReady;
                          },
                          child: const DrawingAnimation(),
                        );
                },
              ),
            ),
            const BottomPanel(),
          ],
        ),
      ),
    );
  }
}
