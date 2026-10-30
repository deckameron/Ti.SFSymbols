#import "TiSfsymbolsUtils.h"
#import "TiUtils.h"
#import "TiColor.h"
#import <Symbols/Symbols.h>

static NSString *Str(NSDictionary *d, NSString *key)
{
  id v = d[key];
  return [v isKindOfClass:[NSString class]] ? v : nil;
}

static BOOL Is(NSString *value, NSString *expected)
{
  return value != nil && [value caseInsensitiveCompare:expected] == NSOrderedSame;
}

@implementation TiSfsymbolsUtils

#pragma mark Colors

+ (UIColor *)colorFromValue:(id)value
{
  if (value == nil || value == [NSNull null]) return nil;
  return [[TiUtils colorValue:value] _color];
}

#pragma mark Configuration

+ (UIImageSymbolWeight)weightFromString:(NSString *)s
{
  if (Is(s, @"ultraLight")) return UIImageSymbolWeightUltraLight;
  if (Is(s, @"thin")) return UIImageSymbolWeightThin;
  if (Is(s, @"light")) return UIImageSymbolWeightLight;
  if (Is(s, @"regular")) return UIImageSymbolWeightRegular;
  if (Is(s, @"medium")) return UIImageSymbolWeightMedium;
  if (Is(s, @"semibold")) return UIImageSymbolWeightSemibold;
  if (Is(s, @"bold")) return UIImageSymbolWeightBold;
  if (Is(s, @"heavy")) return UIImageSymbolWeightHeavy;
  if (Is(s, @"black")) return UIImageSymbolWeightBlack;
  return UIImageSymbolWeightUnspecified;
}

+ (UIImageSymbolScale)scaleFromString:(NSString *)s
{
  if (Is(s, @"small")) return UIImageSymbolScaleSmall;
  if (Is(s, @"medium")) return UIImageSymbolScaleMedium;
  if (Is(s, @"large")) return UIImageSymbolScaleLarge;
  return UIImageSymbolScaleUnspecified;
}

+ (UIFontTextStyle)textStyleFromString:(NSString *)s
{
  if (Is(s, @"largeTitle")) return UIFontTextStyleLargeTitle;
  if (Is(s, @"title1")) return UIFontTextStyleTitle1;
  if (Is(s, @"title2")) return UIFontTextStyleTitle2;
  if (Is(s, @"title3")) return UIFontTextStyleTitle3;
  if (Is(s, @"headline")) return UIFontTextStyleHeadline;
  if (Is(s, @"subheadline")) return UIFontTextStyleSubheadline;
  if (Is(s, @"body")) return UIFontTextStyleBody;
  if (Is(s, @"callout")) return UIFontTextStyleCallout;
  if (Is(s, @"footnote")) return UIFontTextStyleFootnote;
  if (Is(s, @"caption1")) return UIFontTextStyleCaption1;
  if (Is(s, @"caption2")) return UIFontTextStyleCaption2;
  return nil;
}

+ (UIImageSymbolConfiguration *)configurationFromProps:(NSDictionary *)props
{
  UIImageSymbolConfiguration *config = nil;

  UIImageSymbolWeight weight = [self weightFromString:Str(props, @"weight")];
  UIImageSymbolScale scale = [self scaleFromString:Str(props, @"scale")];
  UIFontTextStyle textStyle = [self textStyleFromString:Str(props, @"textStyle")];
  CGFloat pointSize = [TiUtils floatValue:props[@"pointSize"] def:0];

  if (textStyle != nil) {
    config = [UIImageSymbolConfiguration configurationWithTextStyle:textStyle scale:scale];
    if (weight != UIImageSymbolWeightUnspecified) {
      config = [config configurationByApplyingConfiguration:[UIImageSymbolConfiguration configurationWithWeight:weight]];
    }
  } else if (pointSize > 0) {
    config = [UIImageSymbolConfiguration configurationWithPointSize:pointSize weight:weight scale:scale];
  } else if (weight != UIImageSymbolWeightUnspecified) {
    config = [UIImageSymbolConfiguration configurationWithWeight:weight];
    if (scale != UIImageSymbolScaleUnspecified) {
      config = [config configurationByApplyingConfiguration:[UIImageSymbolConfiguration configurationWithScale:scale]];
    }
  } else if (scale != UIImageSymbolScaleUnspecified) {
    config = [UIImageSymbolConfiguration configurationWithScale:scale];
  } else {
    config = [UIImageSymbolConfiguration unspecifiedConfiguration];
  }

  // Color rendering mode
  NSString *mode = Str(props, @"renderingMode");
  UIColor *color = [self colorFromValue:props[@"color"]];
  NSArray *rawColors = [props[@"colors"] isKindOfClass:[NSArray class]] ? props[@"colors"] : nil;

  UIImageSymbolConfiguration *colorConfig = nil;
  if (Is(mode, @"multicolor")) {
    colorConfig = [UIImageSymbolConfiguration configurationPreferringMulticolor];
  } else if (Is(mode, @"hierarchical")) {
    colorConfig = [UIImageSymbolConfiguration configurationWithHierarchicalColor:(color ?: [UIColor labelColor])];
  } else if (Is(mode, @"palette")) {
    NSMutableArray *colors = [NSMutableArray array];
    for (id c in rawColors) {
      UIColor *uc = [self colorFromValue:c];
      if (uc) [colors addObject:uc];
    }
    if (colors.count == 0 && color) [colors addObject:color];
    if (colors.count > 0) {
      colorConfig = [UIImageSymbolConfiguration configurationWithPaletteColors:colors];
    }
  } else if (Is(mode, @"monochrome")) {
    colorConfig = [UIImageSymbolConfiguration configurationPreferringMonochrome];
  }
  if (colorConfig) {
    config = [config configurationByApplyingConfiguration:colorConfig];
  }

  if (@available(iOS 26.0, *)) {
    NSString *vvm = Str(props, @"variableValueMode");
    if (vvm != nil) {
      UIImageSymbolVariableValueMode m = Is(vvm, @"color") ? UIImageSymbolVariableValueModeColor
          : Is(vvm, @"draw")                               ? UIImageSymbolVariableValueModeDraw
                                                           : UIImageSymbolVariableValueModeAutomatic;
      config = [config configurationByApplyingConfiguration:[UIImageSymbolConfiguration configurationWithVariableValueMode:m]];
    }
    NSString *crm = Str(props, @"colorRenderingMode");
    if (crm != nil) {
      UIImageSymbolColorRenderingMode m = Is(crm, @"flat") ? UIImageSymbolColorRenderingModeFlat
          : Is(crm, @"gradient")                           ? UIImageSymbolColorRenderingModeGradient
                                                           : UIImageSymbolColorRenderingModeAutomatic;
      config = [config configurationByApplyingConfiguration:[UIImageSymbolConfiguration configurationWithColorRenderingMode:m]];
    }
  }
  return config;
}

#pragma mark Images

+ (UIImage *)imageForSymbol:(NSString *)name props:(NSDictionary *)props
{
  if (name.length == 0) return nil;
  UIImageSymbolConfiguration *config = [self configurationFromProps:props];
  id vv = props[@"variableValue"];
  if (vv != nil && vv != [NSNull null]) {
    double value = MAX(0.0, MIN(1.0, [TiUtils doubleValue:vv]));
    return [UIImage systemImageNamed:name variableValue:value withConfiguration:config];
  }
  return [UIImage systemImageNamed:name withConfiguration:config];
}

+ (BOOL)symbolExists:(NSString *)name
{
  return name.length > 0 && [UIImage systemImageNamed:name] != nil;
}

#pragma mark Effects

+ (BOOL)isEffectSupported:(NSString *)type
{
  if (type.length == 0) return NO;
  NSArray *ios17 = @[ @"appear", @"disappear", @"bounce", @"pulse", @"scale", @"variableColor", @"replace", @"downUp", @"upUp", @"offUp", @"automatic" ];
  NSArray *ios18 = @[ @"wiggle", @"rotate", @"breathe", @"magic" ];
  NSArray *ios26 = @[ @"drawOn", @"drawOff" ];
  for (NSString *t in ios17) if (Is(type, t)) { if (@available(iOS 17.0, *)) return YES; return NO; }
  for (NSString *t in ios18) if (Is(type, t)) { if (@available(iOS 18.0, *)) return YES; return NO; }
  for (NSString *t in ios26) if (Is(type, t)) { if (@available(iOS 26.0, *)) return YES; return NO; }
  return NO;
}

+ (BOOL)isIndefiniteEffect:(NSDictionary *)dict
{
  NSString *type = Str(dict, @"type");
  NSString *rep = Str(dict, @"repeat");
  if (Is(rep, @"continuous")) return YES;
  // scale holds until removed; breathe keeps going until removed (it never reports completion).
  return Is(type, @"scale") || Is(type, @"breathe");
}

+ (id)optionsFromDict:(NSDictionary *)dict
{
  if (@available(iOS 17.0, *)) {
    NSSymbolEffectOptions *options = [NSSymbolEffectOptions optionsWithNonRepeating];
    NSString *rep = Str(dict, @"repeat");
    NSInteger count = [TiUtils intValue:dict[@"repeatCount"] def:0];
    double delay = [TiUtils doubleValue:dict[@"repeatDelay"] def:0] / 1000.0;
    BOOL wantsRepeat = Is(rep, @"periodic") || Is(rep, @"continuous") || count > 0;

    if (wantsRepeat) {
      if (@available(iOS 18.0, *)) {
        NSSymbolEffectOptionsRepeatBehavior *b = nil;
        if (Is(rep, @"continuous")) {
          b = [NSSymbolEffectOptionsRepeatBehavior behaviorContinuous];
        } else if (count > 0 && delay > 0) {
          b = [NSSymbolEffectOptionsRepeatBehavior behaviorPeriodicWithCount:count delay:delay];
        } else if (count > 0) {
          b = [NSSymbolEffectOptionsRepeatBehavior behaviorPeriodicWithCount:count];
        } else if (delay > 0) {
          b = [NSSymbolEffectOptionsRepeatBehavior behaviorPeriodicWithDelay:delay];
        } else {
          b = [NSSymbolEffectOptionsRepeatBehavior behaviorPeriodic];
        }
        options = [options optionsWithRepeatBehavior:b];
      } else if (count > 0) {
        options = [NSSymbolEffectOptions optionsWithRepeatCount:count];
      } else {
        options = [NSSymbolEffectOptions optionsWithRepeating];
      }
    }
    id speed = dict[@"speed"];
    if (speed != nil && speed != [NSNull null]) {
      double s = [TiUtils doubleValue:speed def:1.0];
      if (s > 0) options = [options optionsWithSpeed:s];
    }
    return options;
  }
  return nil;
}

+ (id)effectFromDict:(NSDictionary *)d
{
  NSString *type = Str(d, @"type");
  NSString *scope = Str(d, @"scope");
  NSString *dir = Str(d, @"direction");
  BOOL byLayer = Is(scope, @"byLayer");
  BOOL whole = Is(scope, @"wholeSymbol");

  if (@available(iOS 17.0, *)) {
    if (Is(type, @"appear") || Is(type, @"disappear")) {
      BOOL appear = Is(type, @"appear");
      if (appear) {
        NSSymbolAppearEffect *e = Is(dir, @"up") ? [NSSymbolAppearEffect appearUpEffect]
            : Is(dir, @"down")                   ? [NSSymbolAppearEffect appearDownEffect]
                                                 : [NSSymbolAppearEffect effect];
        return byLayer ? [e effectWithByLayer] : (whole ? [e effectWithWholeSymbol] : e);
      }
      NSSymbolDisappearEffect *e = Is(dir, @"up") ? [NSSymbolDisappearEffect disappearUpEffect]
          : Is(dir, @"down")                      ? [NSSymbolDisappearEffect disappearDownEffect]
                                                  : [NSSymbolDisappearEffect effect];
      return byLayer ? [e effectWithByLayer] : (whole ? [e effectWithWholeSymbol] : e);
    }
    if (Is(type, @"bounce")) {
      NSSymbolBounceEffect *e = Is(dir, @"up") ? [NSSymbolBounceEffect bounceUpEffect]
          : Is(dir, @"down")                   ? [NSSymbolBounceEffect bounceDownEffect]
                                               : [NSSymbolBounceEffect effect];
      return byLayer ? [e effectWithByLayer] : (whole ? [e effectWithWholeSymbol] : e);
    }
    if (Is(type, @"pulse")) {
      NSSymbolPulseEffect *e = [NSSymbolPulseEffect effect];
      return byLayer ? [e effectWithByLayer] : (whole ? [e effectWithWholeSymbol] : e);
    }
    if (Is(type, @"scale")) {
      NSSymbolScaleEffect *e = Is(dir, @"down") ? [NSSymbolScaleEffect scaleDownEffect] : [NSSymbolScaleEffect scaleUpEffect];
      return byLayer ? [e effectWithByLayer] : (whole ? [e effectWithWholeSymbol] : e);
    }
    if (Is(type, @"variableColor")) {
      NSSymbolVariableColorEffect *e = [NSSymbolVariableColorEffect effect];
      if ([TiUtils boolValue:d[@"iterative"] def:NO]) e = [e effectWithIterative];
      if ([TiUtils boolValue:d[@"cumulative"] def:NO]) e = [e effectWithCumulative];
      if ([TiUtils boolValue:d[@"reversing"] def:NO]) e = [e effectWithReversing];
      if ([TiUtils boolValue:d[@"nonReversing"] def:NO]) e = [e effectWithNonReversing];
      if ([TiUtils boolValue:d[@"hideInactiveLayers"] def:NO]) e = [e effectWithHideInactiveLayers];
      if ([TiUtils boolValue:d[@"dimInactiveLayers"] def:NO]) e = [e effectWithDimInactiveLayers];
      return e;
    }
  }

  if (@available(iOS 18.0, *)) {
    if (Is(type, @"wiggle")) {
      NSSymbolWiggleEffect *e = nil;
      id angle = d[@"angle"];
      if (angle != nil && angle != [NSNull null]) {
        e = [NSSymbolWiggleEffect wiggleCustomAngleEffect:[TiUtils doubleValue:angle def:0]];
      } else if (Is(dir, @"clockwise")) {
        e = [NSSymbolWiggleEffect wiggleClockwiseEffect];
      } else if (Is(dir, @"counterClockwise")) {
        e = [NSSymbolWiggleEffect wiggleCounterClockwiseEffect];
      } else if (Is(dir, @"left")) {
        e = [NSSymbolWiggleEffect wiggleLeftEffect];
      } else if (Is(dir, @"right")) {
        e = [NSSymbolWiggleEffect wiggleRightEffect];
      } else if (Is(dir, @"up")) {
        e = [NSSymbolWiggleEffect wiggleUpEffect];
      } else if (Is(dir, @"down")) {
        e = [NSSymbolWiggleEffect wiggleDownEffect];
      } else if (Is(dir, @"forward")) {
        e = [NSSymbolWiggleEffect wiggleForwardEffect];
      } else if (Is(dir, @"backward")) {
        e = [NSSymbolWiggleEffect wiggleBackwardEffect];
      } else {
        e = [NSSymbolWiggleEffect effect];
      }
      return byLayer ? [e effectWithByLayer] : (whole ? [e effectWithWholeSymbol] : e);
    }
    if (Is(type, @"rotate")) {
      NSSymbolRotateEffect *e = Is(dir, @"clockwise") ? [NSSymbolRotateEffect rotateClockwiseEffect]
          : Is(dir, @"counterClockwise")              ? [NSSymbolRotateEffect rotateCounterClockwiseEffect]
                                                      : [NSSymbolRotateEffect effect];
      return byLayer ? [e effectWithByLayer] : (whole ? [e effectWithWholeSymbol] : e);
    }
    if (Is(type, @"breathe")) {
      NSString *variant = Str(d, @"variant");
      NSSymbolBreatheEffect *e = Is(variant, @"pulse") ? [NSSymbolBreatheEffect breathePulseEffect]
          : Is(variant, @"plain")                      ? [NSSymbolBreatheEffect breathePlainEffect]
                                                       : [NSSymbolBreatheEffect effect];
      return byLayer ? [e effectWithByLayer] : (whole ? [e effectWithWholeSymbol] : e);
    }
  }

  if (@available(iOS 26.0, *)) {
    if (Is(type, @"drawOn")) {
      NSSymbolDrawOnEffect *e = [NSSymbolDrawOnEffect effect];
      if ([TiUtils boolValue:d[@"individually"] def:NO]) return [e effectWithIndividually];
      return byLayer ? [e effectWithByLayer] : (whole ? [e effectWithWholeSymbol] : e);
    }
    if (Is(type, @"drawOff")) {
      NSSymbolDrawOffEffect *e = [NSSymbolDrawOffEffect effect];
      if ([TiUtils boolValue:d[@"individually"] def:NO]) e = [e effectWithIndividually];
      else if (byLayer) e = [e effectWithByLayer];
      else if (whole) e = [e effectWithWholeSymbol];
      if ([TiUtils boolValue:d[@"reversed"] def:NO]) e = [e effectWithReversed];
      else if ([TiUtils boolValue:d[@"nonReversed"] def:NO]) e = [e effectWithNonReversed];
      return e;
    }
  }
  return nil;
}

#pragma mark Content transitions

+ (id)replaceTransitionNamed:(NSString *)name scope:(NSString *)scope
{
  if (@available(iOS 17.0, *)) {
    NSSymbolReplaceContentTransition *t = Is(name, @"downUp") ? [NSSymbolReplaceContentTransition replaceDownUpTransition]
        : Is(name, @"upUp")                                   ? [NSSymbolReplaceContentTransition replaceUpUpTransition]
        : Is(name, @"offUp")                                  ? [NSSymbolReplaceContentTransition replaceOffUpTransition]
                                                              : [NSSymbolReplaceContentTransition transition];
    if (Is(scope, @"byLayer")) return [t transitionWithByLayer];
    if (Is(scope, @"wholeSymbol")) return [t transitionWithWholeSymbol];
    return t;
  }
  return nil;
}

+ (id)transitionFromDict:(NSDictionary *)d
{
  NSString *name = Str(d, @"transition");
  NSString *scope = Str(d, @"scope");

  if (@available(iOS 17.0, *)) {
    if (name == nil || Is(name, @"magic")) {
      // Magic replace falls back to the "fallback" replace (downUp by default).
      NSString *fb = Str(d, @"fallback") ?: @"downUp";
      id fallback = [self replaceTransitionNamed:fb scope:scope];
      if (@available(iOS 18.0, *)) {
        return [NSSymbolReplaceContentTransition magicTransitionWithFallback:fallback];
      }
      return fallback;
    }
    if (Is(name, @"automatic")) return [NSSymbolAutomaticContentTransition transition];
    return [self replaceTransitionNamed:name scope:scope];
  }
  return nil;
}

@end
