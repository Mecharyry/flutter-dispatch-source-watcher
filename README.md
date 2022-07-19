# DispatchSourceWatcher

A package that provides (limited) file system monitoring using the [DispatchSource API](https://developer.apple.com/documentation/dispatch/dispatchsource) on iOS.

## Features

Listen to file system events for **directories** on iOS. This plugin is meant to bridge a gap that currently exists in the standard library, where watching file system changes on iOS is not currently supported (see [flutter issue 99456](https://github.com/flutter/flutter/issues/99456))

## Usage

The plugin must be initialized before events will fire:

```dart
final watcher = DispatchSourceWatcher();
watcher.initialize();
```

To listen to changes:

```dart
void callback1(event) {
  print("receive event on path ${event.path}");
}
watcher.watch("/tmp/dir1", callback1);
```

To stop listening to changes:

```dart
watcher.cancelWatchCallback("/tmp/dir1", callback1);
```

One should dispose of the watcher when it is no longer needed:

```dart
watcher.dispose();
```

## Limitations

The data provided by the notifications in this package is not very granular. In particular, the callback triggered when the directory hierarchy is modified does not contain the path of the file that was modified (the path in the event is the path of the directory being watched).

Requires iOS 10.0+