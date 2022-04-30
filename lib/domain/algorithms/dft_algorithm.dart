import 'dart:math';

import 'package:dft_drawer/domain/entities/complex.dart';
import 'package:dft_drawer/domain/entities/fourier.dart';
import 'package:flutter/cupertino.dart';

///
///Implementation of the mathematic formula of dft on Wikipedia:
///https://wikimedia.org/api/rest_v1/media/math/render/svg/18b0e4c82f095e3789e51ad8c2c6685306b5662b
///
///What i need for a circular epicycle
///1. Amplitude (the radius)
///2. Frequency: how many cycles trough the circle does it rotate per unit of time.
///3. Phase: an offset where does this wave pattern begins.
///
List<Fourier> algorithm(List<Complex> x) {
  List<Fourier> X = [];

  final N = x.length;

  for (var k = 0; k < N; k++) {
    var sum = Complex(0, 0);

    for (var n = 0; n < N; n++) {
      final phi = (2 * pi * k * n) / N;

      final c = Complex(cos(phi), -sin(phi));

      sum.add(x[n].mult(c));
    }

    sum.re = sum.re / N;
    sum.im = sum.im / N;

    var freq = k;
    var amp = sqrt(sum.re * sum.re + sum.im * sum.im);
    var phase = atan2(sum.im, sum.re);

    //adds, respectively:
    //amplitud, frequency, imaginary number, phase and real number
    X.add(
      Fourier(freq: freq, amp: amp, re: sum.re, im: sum.im, phase: phase),
    );
  }

  return X;
}

///
List<Fourier> computeUserDrawingData(List<Offset> input) {
  //This is the signal, any arbitrary digital signal/array of numbers
  List<Complex> signal = [];

  final drawing = input;
  for (int i = 0; i < drawing.length; i++) {
    signal.add(Complex(drawing[i].dx, drawing[i].dy));
  }

  var fourierList = algorithm(signal);

  //Sort the values by amplitud
  fourierList.sort((a, b) => b.amp.compareTo(a.amp));

  return fourierList;
}
