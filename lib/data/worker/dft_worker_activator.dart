import 'dft_worker_pool.dart' show DftWorker;

DftWorker createWorker() =>
    throw UnsupportedError('Not supported on this platform');

String get workerPlatform => 'Unsupported';
