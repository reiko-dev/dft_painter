import 'package:dft_drawer/view/pages/main/ellipsis_position_panel.dart';
import 'package:dft_drawer/view/pages/main/selected_shape_actions.dart';
import 'package:flutter/material.dart';

import 'package:dft_drawer/domain/controllers/drawing_controller.dart';
import 'package:dft_drawer/view/pages/main/complex_dft_painter.dart';
import 'package:dft_drawer/utils/dimensions_percent.dart';
import 'package:get/get.dart';

class BottomPanel extends StatelessWidget {
  const BottomPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.height * .15 < 85
        ? TextButton.icon(
            label: const Text(
              "Tools",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => showDialog(
              context: context,
              builder: (c) {
                return Dialog(
                  elevation: 0,
                  insetPadding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 88.0.wp,
                    height: 100,
                    child: ToolsBar(key: UniqueKey()),
                  ),
                );
              },
            ),
            icon: const Icon(Icons.settings, color: Colors.white),
            style: TextButton.styleFrom(
              shadowColor: Colors.green,
              backgroundColor: Colors.blue,
            ),
          )
        : ToolsBar(key: UniqueKey());
  }
}

class ToolsBar extends StatelessWidget {
  ToolsBar({Key? key}) : super(key: key);

  final scrollController = ScrollController();

  void showDrawingAnimation(DrawingController drawingController) {
    drawingController.startAnimation();
    ComplexDFTPainter.clean();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75.0.wp,
      height: 15.0.hp,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: GetBuilder<DrawingController>(
                builder: (_) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: ElevatedButton(
                        onPressed: () => showDrawingAnimation(_),
                        child: const Text('Run DFT'),
                      ),
                    ),
                    SizedBox(width: 2.0.wp),
                    ElevatedButton(
                      onPressed: () {
                        _.shapes = [];
                        ComplexDFTPainter.clean();
                        _.clearData();
                      },
                      child: const Text('Clear'),
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                    ),
                    SizedBox(width: 2.0.wp),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Skip value:',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        SizedBox(
                          width: 150,
                          height: 40,
                          child: Slider(
                            value: DrawingController.i.skipValue.toDouble(),
                            label: '${DrawingController.i.skipValue}',
                            activeColor: Colors.green,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            onChanged: (newSkip) =>
                                DrawingController.i.skipValue = newSkip.toInt(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 1.0.wp),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Line width:',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        SizedBox(
                          width: 150,
                          height: 40,
                          child: Slider(
                            value: _.selectedShape?.strokeWidth ?? 1,
                            label: '${_.selectedShape?.strokeWidth ?? 1}',
                            activeColor: Colors.purple,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            onChanged: _.selectedShape == null
                                ? null
                                : (value) => _.strokeWidth = value,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 1.0.wp),

                    //Sets the center point for the ellipsis group.
                    const EllipsisPositionPanel(),

                    SizedBox(width: 1.0.wp),

                    GetBuilder<DrawingController>(
                      builder: (_) {
                        return _.shapes.isEmpty
                            ? const SizedBox.shrink()
                            : const Padding(
                                padding: EdgeInsets.only(right: 15.0),
                                child: SelectedShape(),
                              );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
