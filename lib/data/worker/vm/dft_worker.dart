import 'package:squadron/squadron_service.dart';

import '../dft_service.dart';

void start(Map command) => run((startRequest) => DftServiceImpl(), command);
