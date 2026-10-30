/**
 * Ti.SFSymbols
 *
 * Shared helpers: symbol configuration, images, effects, content transitions.
 */

#import <UIKit/UIKit.h>

@interface TiSfsymbolsUtils : NSObject

/// Builds a UIImageSymbolConfiguration from the symbol styling properties
/// (pointSize, weight, scale, textStyle, renderingMode, color, colors,
/// variableValueMode, colorRenderingMode).
+ (UIImageSymbolConfiguration *)configurationFromProps:(NSDictionary *)props;

/// Creates the symbol image (applying variableValue when present). Returns nil
/// if the symbol does not exist on this iOS version.
+ (UIImage *)imageForSymbol:(NSString *)name props:(NSDictionary *)props;

/// Returns YES if the symbol exists on this iOS version.
+ (BOOL)symbolExists:(NSString *)name;

/// Returns YES if the effect (or content transition) is available on this iOS version.
+ (BOOL)isEffectSupported:(NSString *)type;

/// Builds an NSSymbolEffect from a dictionary (type, scope, direction, ...). Nil if
/// the type is unknown or unavailable on this iOS version.
+ (id)effectFromDict:(NSDictionary *)dict;

/// Builds NSSymbolEffectOptions (repeat, repeatCount, repeatDelay, speed).
+ (id)optionsFromDict:(NSDictionary *)dict;

/// Builds an NSSymbolContentTransition (transition, scope, fallback).
+ (id)transitionFromDict:(NSDictionary *)dict;

/// Effects that stay applied until removed (instead of running once).
+ (BOOL)isIndefiniteEffect:(NSDictionary *)dict;

+ (UIColor *)colorFromValue:(id)value;

@end
