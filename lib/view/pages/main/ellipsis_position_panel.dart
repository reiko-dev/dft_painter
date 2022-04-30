import 'package:dft_drawer/domain/controllers/drawing_controller.dart';
import 'package:flutter/material.dart';

import 'package:dft_drawer/utils/dimensions_percent.dart';

class EllipsisPositionPanel extends StatefulWidget {
  const EllipsisPositionPanel({Key? key}) : super(key: key);

  @override
  State<EllipsisPositionPanel> createState() => _EllipsisPositionPanelState();
}

class _EllipsisPositionPanelState extends State<EllipsisPositionPanel> {
  Offset center = Offset.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    center = MediaQuery.of(context).size.center(Offset.zero);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      DrawingController.i.ellipsisCenter = center;
    });
  }

  void onChanged(String? x, String? y) {
    assert(x != null || y != null);

    if (x != null && double.tryParse(x) != null) {
      final tmp = double.tryParse(x);
      center = Offset(tmp!, center.dy);
    } else {
      if (double.tryParse(y!) != null) {
        final tmp = double.tryParse(y);
        center = Offset(center.dx, tmp!);
      }
    }

    DrawingController.i.ellipsisCenter = center;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.5.wp, vertical: 0.5.hp),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.blue,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Ellipsis Center:',
              style: Theme.of(context).textTheme.headline4,
            ),
            Form(
              child: Row(
                children: [
                  const SizedBox(
                    height: 30,
                    child: Text(
                      ' X: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 50,
                    child: TextFormField(
                      onChanged: (val) => onChanged(val, null),
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      textAlign: TextAlign.center,
                      maxLength: 4,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      keyboardType:
                          const TextInputType.numberWithOptions(signed: true),
                      initialValue: center.dx.toStringAsFixed(0),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                    child: Text(
                      ' Y: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 50,
                    child: TextFormField(
                      onChanged: (val) => onChanged(null, val),
                      textAlign: TextAlign.center,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      maxLength: 4,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      keyboardType:
                          const TextInputType.numberWithOptions(signed: true),
                      initialValue: center.dy.toStringAsFixed(0),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
