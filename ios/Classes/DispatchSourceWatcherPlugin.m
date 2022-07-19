#import "DispatchSourceWatcherPlugin.h"
#if __has_include(<dispatch_source_watcher/dispatch_source_watcher-Swift.h>)
#import <dispatch_source_watcher/dispatch_source_watcher-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "dispatch_source_watcher-Swift.h"
#endif

@implementation DispatchSourceWatcherPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDispatchSourceWatcherPlugin registerWithRegistrar:registrar];
}
@end
