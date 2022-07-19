import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dispatch_source_watcher/src/dispatch_source_watcher_method_channel.dart';

void main() {
  MethodChannelDispatchSourceWatcher platform = MethodChannelDispatchSourceWatcher();
  const MethodChannel channel = MethodChannel('dispatch_source_watcher');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
