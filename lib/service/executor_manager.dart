import 'dart:io';

import 'package:isolate_pool_executor/isolate_pool_executor.dart';

class ExecutorManager {
  static final ExecutorManager _instance = ExecutorManager._internal();
  late final IsolatePoolExecutor _pool;

  factory ExecutorManager() => _instance;

  ExecutorManager._internal() {
    _pool = IsolatePoolExecutor.newFixedIsolatePool(
      Platform.numberOfProcessors,
    );
  }

  IsolatePoolExecutor get pool => _pool;

  void shutdown() {
    _pool.shutdown();
  }
}
