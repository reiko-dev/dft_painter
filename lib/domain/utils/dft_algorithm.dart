import 'dart:math';

///
///Implementation of the mathematic formula of dft on Wikipedia:
///https://wikimedia.org/api/rest_v1/media/math/render/svg/18b0e4c82f095e3789e51ad8c2c6685306b5662b
///
///What i need for a circular epicycle
///1. Amplitude (the radius)
///2. Frequency: how many cycles trough the circle does it rotate per unit of time.
///3. Phase: an offset where does this wave pattern begins.
///
List<double> mult(List<double> xn, List<double> c) {
  final re = xn[0] * c[0] - xn[1] * c[1];
  final im = xn[0] * c[1] + xn[1] * c[0];

  return [re, im];
}

add(List xn, List c) {
  xn[0] += c[0];
  xn[1] += c[1];
}

List<List<num>> dftAlgorithm(List<List<double>> x) {
  // List<Fourier> X = [];
  final X = <List<num>>[];

  final N = x.length;

  for (var k = 0; k < N; k++) {
    var sum = [0.0, 0.0];

    for (var n = 0; n < N; n++) {
      final phi = (2 * pi * k * n) / N;

      final c = <double>[cos(phi), -sin(phi)];
      final xn = [x[n][0], x[n][1]];

      final o = mult(xn, c);

      sum = [sum[0] + o[0], sum[1] + o[1]];
    }

    sum[0] /= N;
    sum[1] /= N;

    var freq = k;
    var amp = sqrt(sum[0] * sum[0] + sum[1] * sum[1]);
    var phase = atan2(sum[1], sum[0]);

    //adds, respectively:
    //amplitud, frequency, imaginary number, phase and real number
    X.add([freq, amp, sum[0], sum[1], phase]);
  }

  return X;
}

List<List<dynamic>> computeUserDrawingData(List<List<double>> input) {
  var fourierList = dftAlgorithm(input);

  //Sort the values by amplitud
  fourierList.sort((a, b) => b[1].compareTo(a[1]));

  return fourierList;
}
