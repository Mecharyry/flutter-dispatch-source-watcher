import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:dispatch_source_watcher/src/dispatch_source_event.dart';
import 'package:dispatch_source_watcher/src/dispatch_source_callback_aggregator.dart';
import 'package:dispatch_source_watcher/src/dispatch_source_watcher_method_channel.dart';
import 'package:dispatch_source_watcher/src/dispatch_source_watcher_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDispatchSourceWatcherPlatform 
    with MockPlatformInterfaceMixin
    implements DispatchSourceWatcherPlatform {
  final _streamController = StreamController<Map<String, Object>>.broadcast();

  @override
  Stream eventsStream() {
    return _streamController.stream;
  }

  @override
  Future<void> watch(String path) {
    return Future.value();
  }

  @override
  Future<void> stopWatching(String path) {
    return Future.value();
  }

  void triggerMockEvent(Map<String, Object> event) {
    _streamController.add(event);
  }
}

void main() {
  final DispatchSourceWatcherPlatform initialPlatform = DispatchSourceWatcherPlatform.instance;

  test('$MethodChannelDispatchSourceWatcher is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDispatchSourceWatcher>());
  });

  test('watch and unwatch a file', () async {
    final watcher = DispatchSourceCallbackAggregator();
    MockDispatchSourceWatcherPlatform fakePlatform = MockDispatchSourceWatcherPlatform();
    DispatchSourceWatcherPlatform.instance = fakePlatform;
    void callback1(event){}
    watcher.addCallback('/dir/file1', callback1);
    expect(watcher.callbacksForPath('/dir/file1'), equals([callback1]));

    watcher.removeCallback('/dir/file1', callback1);
    expect(watcher.callbacksForPath('/dir/file1'), equals([]));
  });

  test('watch and unwatch a file multiple times', () async {
    final watcher = DispatchSourceCallbackAggregator();
    MockDispatchSourceWatcherPlatform fakePlatform = MockDispatchSourceWatcherPlatform();
    DispatchSourceWatcherPlatform.instance = fakePlatform;
    void callback1(event){}
    void callback2(event){}

    watcher.addCallback('/dir/file1', callback1);
    watcher.addCallback('/dir/file1', callback2);
    expect(watcher.callbacksForPath('/dir/file1'), equals([callback1, callback2]));

    watcher.removeCallback('/dir/file1', callback1);
    expect(watcher.callbacksForPath('/dir/file1'), equals([callback2]));
  });

  test('callback triggers on event', () async {
    final watcher = DispatchSourceCallbackAggregator();
    MockDispatchSourceWatcherPlatform fakePlatform = MockDispatchSourceWatcherPlatform();
    DispatchSourceWatcherPlatform.instance = fakePlatform;
    watcher.ensureInitialized();
    final triggeredEvents = <Map<String, Object>>[];
    callback1(DispatchSourceEvent event){
      triggeredEvents.add(event.asDictionary());
    }

    watcher.addCallback('/dir/file1', callback1);
    expect(triggeredEvents, equals([]));

    final mockEvent1 = {"path":'/dir/file1', "event":2, "eventNames":["write"]};
    final mockEvent2 = {"path":'/dir/file2', "event":2, "eventNames":["write"]};
    fakePlatform.triggerMockEvent(mockEvent1);
    fakePlatform.triggerMockEvent(mockEvent2);

    // wait for async callback to trigger
    await Future.delayed(const Duration(seconds: 1), () {
      expect(triggeredEvents, equals([mockEvent1]));
    });

    watcher.dispose();
  });
}
