import Flutter
import UIKit


struct DirectoryReference {
    var fileDescriptor: Int32 = -1
    var dispatchSource: DispatchSource?
}

struct FSWatcherEvent {
    let path: String
    let event: UInt
}

enum FSWatcherError: Error {
    case MissingDispatchSource(path: String)
    case PlatformNotSupported(message: String)
}

public class SwiftDispatchSourceWatcherPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    let watcherQueue =  DispatchQueue(label: "dispatch-source-watcher-plugin", attributes: .concurrent);
    var sink: FlutterEventSink?
    var directoryReferences: Dictionary<String, DirectoryReference> = [:]
    
    public static func register(with registrar: FlutterPluginRegistrar) {
      let eventChannel = FlutterEventChannel(name: "dispatch_source_watcher.events", binaryMessenger: registrar.messenger())
        let instance = SwiftDispatchSourceWatcherPlugin()
        eventChannel.setStreamHandler(instance)
        let channel = FlutterMethodChannel(name: "dispatch_source_watcher.methods", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            switch call.method {
            case "watch":
                if let path = call.arguments as? String {
                    debugPrint("watching \(path)")
                    try watch(path:path)
                }
                else {
                    debugPrint("watch called with argument of unknown type [\(String(describing: call.arguments))]")
                }
                break
            default:
                debugPrint("unknown method [\(call.method)] invoked")
            }
        }
        catch {
            result(error)
            return
        }
      result(nil)
    }
    
    public func watch(path: String) throws {
        if directoryReferences[path] == nil {

            let url = URL(fileURLWithPath: path);
            var directoryReference = DirectoryReference()
            directoryReference.fileDescriptor = open((url as NSURL).fileSystemRepresentation, O_EVTONLY)
            directoryReference.dispatchSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: directoryReference.fileDescriptor, eventMask: DispatchSource.FileSystemEvent(arrayLiteral: [.write, .delete,  .rename, .revoke]), queue: watcherQueue) as? DispatchSource

            if let dispatchSource = directoryReference.dispatchSource {
                dispatchSource.setEventHandler { [weak self] in
                    let event: UInt = dispatchSource.data
                    if let eventSink = self?.sink {
                        var fsEvent = ["path": path, "events": event] as [String : Any]
                        var eventNames = [] as [String]
                        if (dispatchSource.data.contains(.write)) {
                            eventNames.append("write")
                        }
                        if (dispatchSource.data.contains(.delete)) {
                            eventNames.append("delete")
                        }
                        if (dispatchSource.data.contains(.rename)) {
                            eventNames.append("rename")
                        }
                        if (dispatchSource.data.contains(.revoke)) {
                            eventNames.append("revoke")
                        }
                        fsEvent["eventNames"] = eventNames
                        eventSink(fsEvent)
                    }
                }

                dispatchSource.setCancelHandler{
                    close(directoryReference.fileDescriptor)
                    directoryReference.fileDescriptor = -1
                    directoryReference.dispatchSource = nil
                }

                if #available(iOS 10.0, *) {
                    dispatchSource.activate()
                } else {
                    throw(FSWatcherError.PlatformNotSupported(message: "iOS 10.0 or greater is required"))
                }
            }
            else {
                throw FSWatcherError.MissingDispatchSource(path: path)
            }
        }
    }
    
    public func stopWatching(path: String) {
        if let directoryReference = directoryReferences[path] {
            directoryReference.dispatchSource?.cancel();
            directoryReferences[path] = nil
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        sink = eventSink
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        for directoryReference in directoryReferences.values {
            directoryReference.dispatchSource?.cancel();
        }
        directoryReferences = [:];
        return nil
    }
}
