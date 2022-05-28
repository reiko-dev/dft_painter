import 'package:squadron/squadron.dart';

import 'dft_service.dart';
import 'dft_worker_activator.dart'
    if (dart.library.js) 'package:dft_drawer/data/worker/browser/dft_worker_activator.dart'
    if (dart.library.html) 'package:dft_drawer/data/worker/browser/dft_worker_activator.dart'
    if (dart.library.io) 'package:dft_drawer/data/worker/vm/dft_worker_activator.dart';

class DftWorkerPool extends WorkerPool<DftWorker> implements DftService {
  DftWorkerPool()
      : super(
          createWorker,
          concurrencySettings: const ConcurrencySettings(
            maxParallel: 2,
            maxWorkers: 1,
            minWorkers: 1,
          ),
        );

  @override
  Stream<List> computeDFT(List x, CancellationToken? token) =>
      stream((w) => w.computeDFT(x, token));
}

class DftWorker extends Worker implements DftService {
  DftWorker(dynamic entryPoint, {List args = const []})
      : super(entryPoint, args: args);

  @override
  Stream<List> computeDFT(List x, CancellationToken? token) =>
      stream(DftService.computeOperationNumber, args: [x], token: token);
}
