/**
 * Ti.SFSymbols
 *
 * Full SF Symbols for Titanium: styled symbol views, effects, content
 * transitions, variable values, rendering modes and symbol images.
 */

#import "TiSfsymbolsModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiBlob.h"
#import "TiSfsymbolsUtils.h"

@implementation TiSfsymbolsModule

#pragma mark Internal

// This is generated for your module, please do not change it
- (id)moduleGUID
{
  return @"f0ba556d-6a3b-4020-a11b-ae8f78ecb8fc";
}

// This is generated for your module, please do not change it
- (NSString *)moduleId
{
  return @"ti.sfsymbols";
}

#pragma mark Lifecycle

- (void)startup
{
  // This method is called when the module is first loaded
  // You *must* call the superclass
  [super startup];
  DebugLog(@"[DEBUG] %@ loaded", self);
}

#pragma mark Constants

// Weights
MAKE_SYSTEM_STR(WEIGHT_ULTRA_LIGHT, @"ultraLight");
MAKE_SYSTEM_STR(WEIGHT_THIN, @"thin");
MAKE_SYSTEM_STR(WEIGHT_LIGHT, @"light");
MAKE_SYSTEM_STR(WEIGHT_REGULAR, @"regular");
MAKE_SYSTEM_STR(WEIGHT_MEDIUM, @"medium");
MAKE_SYSTEM_STR(WEIGHT_SEMIBOLD, @"semibold");
MAKE_SYSTEM_STR(WEIGHT_BOLD, @"bold");
MAKE_SYSTEM_STR(WEIGHT_HEAVY, @"heavy");
MAKE_SYSTEM_STR(WEIGHT_BLACK, @"black");

// Scales
MAKE_SYSTEM_STR(SCALE_SMALL, @"small");
MAKE_SYSTEM_STR(SCALE_MEDIUM, @"medium");
MAKE_SYSTEM_STR(SCALE_LARGE, @"large");

// Text styles
MAKE_SYSTEM_STR(TEXT_STYLE_LARGE_TITLE, @"largeTitle");
MAKE_SYSTEM_STR(TEXT_STYLE_TITLE1, @"title1");
MAKE_SYSTEM_STR(TEXT_STYLE_TITLE2, @"title2");
MAKE_SYSTEM_STR(TEXT_STYLE_TITLE3, @"title3");
MAKE_SYSTEM_STR(TEXT_STYLE_HEADLINE, @"headline");
MAKE_SYSTEM_STR(TEXT_STYLE_SUBHEADLINE, @"subheadline");
MAKE_SYSTEM_STR(TEXT_STYLE_BODY, @"body");
MAKE_SYSTEM_STR(TEXT_STYLE_CALLOUT, @"callout");
MAKE_SYSTEM_STR(TEXT_STYLE_FOOTNOTE, @"footnote");
MAKE_SYSTEM_STR(TEXT_STYLE_CAPTION1, @"caption1");
MAKE_SYSTEM_STR(TEXT_STYLE_CAPTION2, @"caption2");

// Rendering modes
MAKE_SYSTEM_STR(RENDERING_MODE_AUTOMATIC, @"automatic");
MAKE_SYSTEM_STR(RENDERING_MODE_MONOCHROME, @"monochrome");
MAKE_SYSTEM_STR(RENDERING_MODE_HIERARCHICAL, @"hierarchical");
MAKE_SYSTEM_STR(RENDERING_MODE_PALETTE, @"palette");
MAKE_SYSTEM_STR(RENDERING_MODE_MULTICOLOR, @"multicolor");

// Variable value / color rendering modes (iOS 26+)
MAKE_SYSTEM_STR(VARIABLE_VALUE_MODE_AUTOMATIC, @"automatic");
MAKE_SYSTEM_STR(VARIABLE_VALUE_MODE_COLOR, @"color");
MAKE_SYSTEM_STR(VARIABLE_VALUE_MODE_DRAW, @"draw");
MAKE_SYSTEM_STR(COLOR_RENDERING_MODE_AUTOMATIC, @"automatic");
MAKE_SYSTEM_STR(COLOR_RENDERING_MODE_FLAT, @"flat");
MAKE_SYSTEM_STR(COLOR_RENDERING_MODE_GRADIENT, @"gradient");

// Effects
MAKE_SYSTEM_STR(EFFECT_APPEAR, @"appear");
MAKE_SYSTEM_STR(EFFECT_DISAPPEAR, @"disappear");
MAKE_SYSTEM_STR(EFFECT_BOUNCE, @"bounce");
MAKE_SYSTEM_STR(EFFECT_PULSE, @"pulse");
MAKE_SYSTEM_STR(EFFECT_SCALE, @"scale");
MAKE_SYSTEM_STR(EFFECT_VARIABLE_COLOR, @"variableColor");
MAKE_SYSTEM_STR(EFFECT_WIGGLE, @"wiggle");
MAKE_SYSTEM_STR(EFFECT_ROTATE, @"rotate");
MAKE_SYSTEM_STR(EFFECT_BREATHE, @"breathe");
MAKE_SYSTEM_STR(EFFECT_DRAW_ON, @"drawOn");
MAKE_SYSTEM_STR(EFFECT_DRAW_OFF, @"drawOff");

// Sequence step types (besides the effects above)
MAKE_SYSTEM_STR(STEP_REPLACE, @"replace");
MAKE_SYSTEM_STR(STEP_SHOW, @"show");
MAKE_SYSTEM_STR(STEP_HIDE, @"hide");
MAKE_SYSTEM_STR(STEP_REMOVE, @"remove");
MAKE_SYSTEM_STR(STEP_WAIT, @"wait");

// Content transitions (replace)
MAKE_SYSTEM_STR(TRANSITION_MAGIC, @"magic");
MAKE_SYSTEM_STR(TRANSITION_DEFAULT, @"default");
MAKE_SYSTEM_STR(TRANSITION_AUTOMATIC, @"automatic");
MAKE_SYSTEM_STR(TRANSITION_DOWN_UP, @"downUp");
MAKE_SYSTEM_STR(TRANSITION_UP_UP, @"upUp");
MAKE_SYSTEM_STR(TRANSITION_OFF_UP, @"offUp");

// Scope
MAKE_SYSTEM_STR(SCOPE_BY_LAYER, @"byLayer");
MAKE_SYSTEM_STR(SCOPE_WHOLE_SYMBOL, @"wholeSymbol");

// Direction
MAKE_SYSTEM_STR(DIRECTION_UP, @"up");
MAKE_SYSTEM_STR(DIRECTION_DOWN, @"down");
MAKE_SYSTEM_STR(DIRECTION_LEFT, @"left");
MAKE_SYSTEM_STR(DIRECTION_RIGHT, @"right");
MAKE_SYSTEM_STR(DIRECTION_CLOCKWISE, @"clockwise");
MAKE_SYSTEM_STR(DIRECTION_COUNTER_CLOCKWISE, @"counterClockwise");
MAKE_SYSTEM_STR(DIRECTION_FORWARD, @"forward");
MAKE_SYSTEM_STR(DIRECTION_BACKWARD, @"backward");

// Repeat
MAKE_SYSTEM_STR(REPEAT_NONE, @"none");
MAKE_SYSTEM_STR(REPEAT_PERIODIC, @"periodic");
MAKE_SYSTEM_STR(REPEAT_CONTINUOUS, @"continuous");

#pragma Public APIs

// createImage({ symbol, pointSize, weight, scale, textStyle, renderingMode, color, colors,
//               variableValue, variableValueMode, colorRenderingMode, template }) -> Ti.Blob
- (id)createImage:(id)args
{
  ENSURE_SINGLE_ARG(args, NSDictionary);
  NSString *name = [TiUtils stringValue:@"symbol" properties:args def:nil];
  UIImage *image = [TiSfsymbolsUtils imageForSymbol:name props:args];
  if (image == nil) {
    NSString *fallback = [TiUtils stringValue:@"fallbackSymbol" properties:args def:nil];
    image = [TiSfsymbolsUtils imageForSymbol:fallback props:args];
  }
  if (image == nil) return nil;

  NSString *mode = [TiUtils stringValue:@"renderingMode" properties:args def:@"automatic"];
  UIColor *color = [TiSfsymbolsUtils colorFromValue:args[@"color"]];
  BOOL colored = ![mode isEqualToString:@"multicolor"] && ![mode isEqualToString:@"palette"] && ![mode isEqualToString:@"hierarchical"];

  if ([TiUtils boolValue:@"template" properties:args def:NO]) {
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  } else if (color != nil && colored) {
    image = [image imageWithTintColor:color renderingMode:UIImageRenderingModeAlwaysOriginal];
  }
  return [[TiBlob alloc] initWithImage:image];
}

// isAvailable('star.calendar') -> Boolean (symbol exists on this iOS version)
- (id)isAvailable:(id)args
{
  ENSURE_SINGLE_ARG(args, NSString);
  return NUMBOOL([TiSfsymbolsUtils symbolExists:args]);
}

// isEffectSupported('drawOn') -> Boolean (effect / transition exists on this iOS version)
- (id)isEffectSupported:(id)args
{
  ENSURE_SINGLE_ARG(args, NSString);
  return NUMBOOL([TiSfsymbolsUtils isEffectSupported:args]);
}

@end
