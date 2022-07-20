# DispatchSourceWatcher

A package that provides (limited) file system monitoring using the [DispatchSource API](https://developer.apple.com/documentation/dispatch/dispatchsource) on iOS.

## Features

Listen to file system events iOS. This plugin is meant to bridge a gap that currently exists in the standard library, where watching file system changes on iOS is not currently supported (see [flutter issue 99456](https://github.com/flutter/flutter/issues/99456))

## Usage

Create a watcher for the desired path

```dart
final watcher = DispatchSourceWatcher(path: '/tmp/dir1');
```

The watcher provides a (broadcast) stream that can be listened to:

```dart
final subscription = watcher.stream.listen((event) {
  print("receive event on path ${event.path}");
});
```

To stop listening to changes cancel the subscription:

```dart
subscription.cancel();
```

## Limitations

The data provided by the notifications in this package is not very granular. In particular, when watching a directory, the events triggered when the directory hierarchy is modified do not contain the path of the file that was modified within that hierarchy - the path in the event is the path of the directory being watched.

Requires iOS 10.0+