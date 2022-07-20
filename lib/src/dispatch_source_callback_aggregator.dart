import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dispatch_source_watcher_platform_interface.dart';
import 'dispatch_source_event.dart';

class DispatchSourceCallbackAggregator {
  static var instance = DispatchSourceCallbackAggregator();
  StreamSubscription? _platformWatcherSubscription;
  final Map<String, List<DispatchSourceWatcherCallback>> watchCallbacks = {};

  // Initialize the aggregator (ok to call multiple times)
  void ensureInitialized() {
    if (_platformWatcherSubscription != null) return;
    _platformWatcherSubscription = DispatchSourceWatcherPlatform.instance.eventsStream().listen(_onWatchEvent);
  }

  // Dispose of the dispatch source watcher
  void dispose() {
    _platformWatcherSubscription?.cancel();
    _platformWatcherSubscription = null;
  }

  void _onWatchEvent(event) {
    final path = event["path"];
    if (path == null) {
      print("ERROR: ignoring watch event with empty path: $event");
      return;
    }
    final callbacks = watchCallbacks[path];
    if ((callbacks == null) || (callbacks.isEmpty)) {
      print("WARNING: received watch event for path [$path] but  it has no watchers");
      return;
    }
    final eventSourcedNames = event["eventNames"];
    final eventNames = eventSourcedNames is List ? eventSourcedNames.cast<String>() : <String>[];
    final watcherEvent = DispatchSourceEvent(path:path, eventMask:event["event"] ?? -1, eventNames: eventNames);
    for (final callback in callbacks) {
      callback(watcherEvent);
    }
  }

  // Registers the given callback for file system changes on the directory hierarchy at the given path
  Future<void> addCallback(String path, DispatchSourceWatcherCallback callback) {
    final callbacks = watchCallbacks[path];
    if (callbacks == null) {
      watchCallbacks[path] = [callback];
    }
    else {
      callbacks.add(callback);
    }
    return DispatchSourceWatcherPlatform.instance.watch(path);
  }

  // Unregisters the given callback for file system changes at the given path
  void removeCallback(String path, DispatchSourceWatcherCallback callback) {
    final callbacks = watchCallbacks[path];
    if (callbacks == null) return;
    if (callbacks.isEmpty) {
      DispatchSourceWatcherPlatform.instance.stopWatching(path);
    }
    else {
      callbacks.remove(callback);
    }
  }

  @visibleForTesting
  List<DispatchSourceWatcherCallback> callbacksForPath(String path) {
    return watchCallbacks[path] ?? [];
  }

}
