import '../dft_worker_pool.dart' show DftWorker;

import 'dft_worker.dart' as isolate;

DftWorker createWorker() => DftWorker(isolate.start);

String get workerPlatform => 'vm';
