import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dispatch_source_watcher_method_channel.dart';
import 'dispatch_source_event.dart';

typedef DispatchSourceWatcherCallback = void Function(DispatchSourceEvent);

abstract class DispatchSourceWatcherPlatform extends PlatformInterface {
  DispatchSourceWatcherPlatform() : super(token: _token);

  static final Object _token = Object();

  static DispatchSourceWatcherPlatform _instance = MethodChannelDispatchSourceWatcher();

  static DispatchSourceWatcherPlatform get instance => _instance;

  static set instance(DispatchSourceWatcherPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream eventsStream();

  Future<void> watch(String path) {
    throw UnimplementedError('watch(String path) has not been implemented.');
  }

  Future<void> stopWatching(String path) {
    throw UnimplementedError('stopWatching(String path) has not been implemented.');
  }
}
