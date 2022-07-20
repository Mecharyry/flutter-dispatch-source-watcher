import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dispatch_source_watcher_platform_interface.dart';

class MethodChannelDispatchSourceWatcher extends DispatchSourceWatcherPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('dispatch_source_watcher.methods');

  @visibleForTesting
  final eventsChannel = const EventChannel('dispatch_source_watcher.events');

  @override
  Stream eventsStream() {
    return eventsChannel.receiveBroadcastStream();
  }

  @override
  Future<void> watch(String path) {
    return methodChannel.invokeMethod('watch', path);
  }

  @override
  Future<void> stopWatching(String path) {
    return methodChannel.invokeMethod('stopWatching', path);
  }
}
