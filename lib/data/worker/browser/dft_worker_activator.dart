import '../dft_worker_pool.dart' show DftWorker;

DftWorker createWorker() => DftWorker('/workers/dft_worker.dart.js');

String get workerPlatform => 'browser';
