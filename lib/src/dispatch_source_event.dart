
// Represents a file system event
class DispatchSourceEvent {
  // The path of the directory hierarchy in which the event occurred (not the path of the file that was changed!)
  final String path;
  // Event mask representing the event, a bitmask composed of [DispatchSource.FileSystemEvent](https://developer.apple.com/documentation/dispatch/dispatchsource/filesystemevent) values
  final int eventMask;
  // A list of String interpretations of the event mask, e.g. "write", "delete" etc. Note that a single DispatchSourceEvent may encapsulate multiple changes to the same directory hierarchy (hence eventNames is a list)
  final List<String> eventNames;
  DispatchSourceEvent({required this.path, required this.eventMask, required this.eventNames});

  Map<String, Object> asDictionary() => {
    "path": path,
    "event": eventMask,
    "eventNames": eventNames
  };
}