import 'dart:async';
import 'dispatch_source_callback_aggregator.dart';
import 'dispatch_source_watcher_platform_interface.dart';
import 'dispatch_source_event.dart';

// Watches a file system object for filesystem changes and provides a stream for these events
class DispatchSourceWatcher {
  final _streamController = StreamController<DispatchSourceEvent>.broadcast();
  final String path;

  // Stream of [DispatchSourceEvent]s. This stream is a broadcast stream. Note that a single event may encapsulate several filesystem-level changes
  Stream<DispatchSourceEvent> get stream => _streamController.stream;

  DispatchSourceWatcher({required this.path}) {
    final aggregator = DispatchSourceCallbackAggregator.instance; 
    aggregator.ensureInitialized();
    _streamController.onListen = () {
      aggregator.addCallback(path, _onWatchEvent);
    };
    _streamController.onCancel = () {
      aggregator.removeCallback(path, _onWatchEvent);
    };
  }

  void _onWatchEvent(DispatchSourceEvent event) {
    _streamController.add(event);
  }
}