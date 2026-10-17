#import "SFSymbolsPrivate.h"

NS_ASSUME_NONNULL_BEGIN

#if TARGET_OS_OSX

// Private AppKit factory methods (macOS 11 and macOS 13). They run the same lookup as
// +[NSImage imageWithSystemSymbolName:accessibilityDescription:], but with private lookup allowed, so a name the
// public symbol set lacks is then looked up in the private one.
@interface NSImage (SFSymbolsPrivateSystemSymbols)

+ (nullable NSImage *)imageWithPrivateSystemSymbolName:(NSString *)name
                              accessibilityDescription:(nullable NSString *)accessibilityDescription;

+ (nullable NSImage *)imageWithPrivateSystemSymbolName:(NSString *)name
                                         variableValue:(double)variableValue
                              accessibilityDescription:(nullable NSString *)accessibilityDescription;

@end

#else

// Private UIKit factory methods (the variable value one since iOS 16). They run the same lookup as
// +[UIImage systemImageNamed:withConfiguration:], but with private lookup allowed, so a name the public symbol set
// lacks is then looked up in the private one.
@interface UIImage (SFSymbolsPrivateSystemSymbols)

+ (nullable UIImage *)_systemImageNamed:(NSString *)name
                      withConfiguration:(nullable UIImageConfiguration *)configuration;

+ (nullable UIImage *)_systemImageNamed:(NSString *)name
                          variableValue:(double)variableValue
                      withConfiguration:(nullable UIImageConfiguration *)configuration;

@end

#endif

@implementation SFSymbolsPrivateSystemSymbolImageFactory

#if TARGET_OS_OSX

+ (nullable NSImage *)imageNamed:(NSString *)name {
    if (![NSImage respondsToSelector:@selector(imageWithPrivateSystemSymbolName:accessibilityDescription:)]) {
        return nil;
    }
    return [NSImage imageWithPrivateSystemSymbolName:name accessibilityDescription:nil];
}

+ (nullable NSImage *)imageNamed:(NSString *)name variableValue:(double)variableValue {
    // Without the variable value method, still show the symbol, only without the variable value.
    if (![NSImage respondsToSelector:@selector(imageWithPrivateSystemSymbolName:variableValue:accessibilityDescription:)]) {
        return [self imageNamed:name];
    }
    return [NSImage imageWithPrivateSystemSymbolName:name variableValue:variableValue accessibilityDescription:nil];
}

#else

+ (nullable UIImage *)imageNamed:(NSString *)name configuration:(nullable UIImageConfiguration *)configuration {
    if (![UIImage respondsToSelector:@selector(_systemImageNamed:withConfiguration:)]) {
        return nil;
    }
    return [UIImage _systemImageNamed:name withConfiguration:configuration];
}

+ (nullable UIImage *)imageNamed:(NSString *)name
                   variableValue:(double)variableValue
                   configuration:(nullable UIImageConfiguration *)configuration {
    // Without the variable value method, still show the symbol, only without the variable value.
    if (![UIImage respondsToSelector:@selector(_systemImageNamed:variableValue:withConfiguration:)]) {
        return [self imageNamed:name configuration:configuration];
    }
    return [UIImage _systemImageNamed:name variableValue:variableValue withConfiguration:configuration];
}

#endif

@end

NS_ASSUME_NONNULL_END
