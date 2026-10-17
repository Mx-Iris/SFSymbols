#import <TargetConditionals.h>

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#else
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// Loads symbol images from the private system symbol set (CoreGlyphsPrivate.bundle) through private AppKit and UIKit
/// factory methods. The lookup searches the public symbol set first, so public names load as well.
///
/// Every method returns nil when the symbol does not exist or when the running system lacks the private factory method.
NS_SWIFT_NAME(PrivateSystemSymbolImageFactory)
@interface SFSymbolsPrivateSystemSymbolImageFactory : NSObject

#if TARGET_OS_OSX

+ (nullable NSImage *)imageNamed:(NSString *)name NS_SWIFT_NAME(image(named:));

+ (nullable NSImage *)imageNamed:(NSString *)name
                   variableValue:(double)variableValue API_AVAILABLE(macos(13.0)) NS_SWIFT_NAME(image(named:variableValue:));

#else

+ (nullable UIImage *)imageNamed:(NSString *)name
                   configuration:(nullable UIImageConfiguration *)configuration NS_SWIFT_NAME(image(named:configuration:));

+ (nullable UIImage *)imageNamed:(NSString *)name
                   variableValue:(double)variableValue
                   configuration:(nullable UIImageConfiguration *)configuration API_AVAILABLE(ios(16.0), tvos(16.0), watchos(9.0)) NS_SWIFT_NAME(image(named:variableValue:configuration:));

#endif

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
