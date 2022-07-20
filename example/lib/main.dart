import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';


import 'package:dispatch_source_watcher/dispatch_source_watcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DispatchSourceWatcher watcher = DispatchSourceWatcher(path:'/tmp/dir1');
  StreamSubscription? watcherSubscription;

  @override
  void initState() {
    super.initState();
    Directory("/tmp/dir1").createSync();
    watcherSubscription = watcher.stream.listen((event) => onFsEvent(event));
  }

  @override
  void dispose() {
    watcherSubscription?.cancel();
    super.dispose();
  }

  void onFsEvent(DispatchSourceEvent event) {
    print("DBG flutter app got event: ${event.path}, ${event.eventNames}");
  }

  void writeFile() {
    final test2 = File('/tmp/dir1');
    if (test2.existsSync()) {
      test2.delete();
    }
    File('/tmp/dir1/test2').writeAsStringSync('hello world');
    Directory('/tmp/dir1').deleteSync(recursive: true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: TextButton(
                child: Text('create file in /tmp/dir1/'),
                onPressed: writeFile
            )
        ),
      ),
    );
  }
}
