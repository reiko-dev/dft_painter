import 'dart:async';
import 'dart:math';

import 'package:squadron/squadron.dart';
import 'package:squadron/squadron_service.dart';

abstract class DftService {
  Stream<List> computeDFT(List<List<double>> x, CancellationToken? token);

  static const computeOperationNumber = 1;
}

void _noop() {}
Future noop() => Future(_noop);

class DftServiceImpl implements DftService, WorkerService {
  @override
  Stream<List> computeDFT(List x, CancellationToken? token) async* {
    final N = x.length;

    for (var k = 0; k < N; k++) {
      var sum = [0.0, 0.0];

      for (var n = 0; n < N; n++) {
        final phi = (2 * pi * k * n) / N;

        final c = <double>[cos(phi), -sin(phi)];
        final xn = [x[n][0] as double, x[n][1] as double];

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
      yield [freq, amp, sum[0], sum[1], phase];

      // avoid flooding the event loop with noop Futures
      // check every 50 digits only
      if (k % 50 == 0) {
        await noop();
        if (token?.cancelled ?? false) {
          throw CancelledException();
        }
      }
    }
  }

  static List<double> mult(List<double> xn, List<double> c) {
    final re = xn[0] * c[0] - xn[1] * c[1];
    final im = xn[0] * c[1] + xn[1] * c[0];

    return [re, im];
  }

  static add(List xn, List c) {
    xn[0] += c[0];
    xn[1] += c[1];
  }

  @override
  late final Map<int, CommandHandler> operations = {
    DftService.computeOperationNumber: (r) =>
        computeDFT(r.args[0], r.cancelToken),
  };
}
