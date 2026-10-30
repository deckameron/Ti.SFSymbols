#import "TiSfsymbolsSymbolView.h"
#import "TiSfsymbolsSymbolViewProxy.h"
#import "TiSfsymbolsUtils.h"
#import "TiUtils.h"

// If an effect never reports completion (view off-screen, for example) the
// sequence moves on after this long so it can never hang.
static const NSTimeInterval kStepSafetyTimeout = 2.5;

static BOOL Is(NSString *value, NSString *expected)
{
  return [value isKindOfClass:[NSString class]] && [value caseInsensitiveCompare:expected] == NSOrderedSame;
}

#define STYLE_SETTER(prop, Prop)           \
  -(void)set##Prop##_ : (id)value          \
  {                                        \
    [self setStyle:@ #prop value:value];   \
  }

@implementation TiSfsymbolsSymbolView {
  UIImageView *_imageView;
  NSMutableDictionary *_props;
  NSString *_symbol;
  BOOL _symbolHidden;
  NSUInteger _runId;
}

#pragma mark Setup

- (UIImageView *)imageView
{
  if (_imageView == nil) {
    _props = [NSMutableDictionary dictionary];
    _imageView = [[UIImageView alloc] initWithFrame:[self bounds]];
    _imageView.contentMode = UIViewContentModeCenter;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_imageView];
  }
  return _imageView;
}

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
  [super frameSizeChanged:frame bounds:bounds];
  if (_imageView != nil) {
    _imageView.frame = bounds;
  }
}

- (NSString *)currentSymbol
{
  return _symbol;
}

#pragma mark Image

// Rebuilds the image from the current symbol and styling properties.
- (void)refreshImage
{
  UIImageView *iv = [self imageView];
  UIImage *image = [TiSfsymbolsUtils imageForSymbol:_symbol props:_props];
  if (image == nil) {
    NSString *fallback = _props[@"fallbackSymbol"];
    if ([fallback isKindOfClass:[NSString class]]) {
      image = [TiSfsymbolsUtils imageForSymbol:fallback props:_props];
    }
  }
  if (image != nil) {
    iv.image = image;
  } else if (_symbol.length > 0) {
    DebugLog(@"[WARN] Ti.SFSymbols: symbol \"%@\" is not available on this iOS version", _symbol);
  }
  UIColor *color = [TiSfsymbolsUtils colorFromValue:_props[@"color"]];
  if (color) iv.tintColor = color;
}

- (void)applyHiddenState
{
  UIImageView *iv = [self imageView];
  if (@available(iOS 17.0, *)) {
    [iv removeSymbolEffectOfType:[NSSymbolDisappearEffect effect] options:[NSSymbolEffectOptions options] animated:NO];
    if (_symbolHidden) {
      [iv addSymbolEffect:[NSSymbolDisappearEffect effect] options:[NSSymbolEffectOptions options] animated:NO];
    }
  } else {
    iv.hidden = _symbolHidden;
  }
}

- (void)setStyle:(NSString *)key value:(id)value
{
  [self imageView];
  if (value == nil || value == [NSNull null]) {
    [_props removeObjectForKey:key];
  } else {
    _props[key] = value;
  }
  [self refreshImage];
}

#pragma mark Properties

- (void)setSymbol_:(id)value
{
  _symbol = [[TiUtils stringValue:value] copy];
  [self refreshImage];
  [self applyHiddenState];
}

- (void)setSymbolHidden_:(id)value
{
  _symbolHidden = [TiUtils boolValue:value def:NO];
  [self applyHiddenState];
}

STYLE_SETTER(fallbackSymbol, FallbackSymbol)
STYLE_SETTER(pointSize, PointSize)
STYLE_SETTER(weight, Weight)
STYLE_SETTER(scale, Scale)
STYLE_SETTER(textStyle, TextStyle)
STYLE_SETTER(renderingMode, RenderingMode)
STYLE_SETTER(color, Color)
STYLE_SETTER(colors, Colors)
STYLE_SETTER(variableValue, VariableValue)
STYLE_SETTER(variableValueMode, VariableValueMode)
STYLE_SETTER(colorRenderingMode, ColorRenderingMode)

#pragma mark Effects

- (void)removeAllEffects
{
  _runId++;
  if (@available(iOS 17.0, *)) {
    UIImageView *iv = [self imageView];
    [iv removeAllSymbolEffectsWithOptions:[NSSymbolEffectOptions options] animated:YES];
    if (_symbolHidden) [self applyHiddenState];
  }
}

- (void)removeEffectOfType:(NSDictionary *)descriptor
{
  if (@available(iOS 17.0, *)) {
    id effect = [TiSfsymbolsUtils effectFromDict:descriptor];
    if (effect == nil) return;
    BOOL animated = [TiUtils boolValue:descriptor[@"animated"] def:YES];
    [[self imageView] removeSymbolEffectOfType:effect
                                       options:[TiSfsymbolsUtils optionsFromDict:descriptor]
                                      animated:animated];
  }
}

#pragma mark Sequence

- (void)cancel
{
  _runId++;
}

- (void)playSteps:(NSArray *)steps
{
  _runId++;
  [self runStepAtIndex:0 steps:steps runId:_runId];
}

- (void)finishSequenceWithRunId:(NSUInteger)rid
{
  if (rid != _runId) return;
  if ([self.proxy _hasListeners:@"done"]) {
    [self.proxy fireEvent:@"done" withObject:@{ @"symbol" : _symbol ?: @"" }];
  }
}

- (void)runStepAtIndex:(NSUInteger)index steps:(NSArray *)steps runId:(NSUInteger)rid
{
  if (rid != _runId) return;
  if (index >= steps.count) {
    [self finishSequenceWithRunId:rid];
    return;
  }

  NSDictionary *step = [steps[index] isKindOfClass:[NSDictionary class]] ? steps[index] : @{};
  NSString *type = [TiUtils stringValue:@"type" properties:step def:@"replace"];
  NSTimeInterval delay = [TiUtils doubleValue:@"delay" properties:step def:0] / 1000.0;
  BOOL reduceMotion = UIAccessibilityIsReduceMotionEnabled();

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((reduceMotion ? 0 : delay) * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        if (rid != self->_runId) return;
        [self runStep:step
            completion:^(BOOL finished) {
              if (rid != self->_runId) return;
              if ([self.proxy _hasListeners:@"stepdone"]) {
                [self.proxy fireEvent:@"stepdone" withObject:@{ @"index" : @(index), @"type" : type, @"finished" : @(finished) }];
              }
              [self runStepAtIndex:index + 1 steps:steps runId:rid];
            }];
      });
}

// Runs one step. Calls `completion` once: when the native effect reports it is
// done, after `duration` ms when given, or after the safety timeout.
- (void)runStep:(NSDictionary *)step completion:(void (^)(BOOL))completion
{
  NSString *type = [TiUtils stringValue:@"type" properties:step def:@"replace"];
  BOOL reduceMotion = UIAccessibilityIsReduceMotionEnabled();

  __block BOOL called = NO;
  void (^finish)(BOOL) = ^(BOOL finished) {
    if (called) return;
    called = YES;
    if (completion) completion(finished);
  };

  id durationValue = step[@"duration"];
  BOOL hasDuration = durationValue != nil && durationValue != [NSNull null];
  if (hasDuration) {
    double ms = [TiUtils doubleValue:durationValue def:0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ms / 1000.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      finish(YES);
    });
  }
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kStepSafetyTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    finish(NO);
  });

  void (^done)(UISymbolEffectCompletionContext *) = ^(UISymbolEffectCompletionContext *ctx) {
    if (!hasDuration) finish(ctx == nil ? YES : ctx.isFinished);
  };

  [self performStep:step type:type animated:!reduceMotion reduceMotion:reduceMotion completion:done finish:finish hasDuration:hasDuration];
}

- (void)performStep:(NSDictionary *)step
               type:(NSString *)type
           animated:(BOOL)animated
       reduceMotion:(BOOL)reduceMotion
         completion:(void (^)(UISymbolEffectCompletionContext *))done
             finish:(void (^)(BOOL))finish
        hasDuration:(BOOL)hasDuration
{
  UIImageView *iv = [self imageView];

  if (Is(type, @"wait")) {
    if (!hasDuration) finish(YES);
    return;
  }

  if (@available(iOS 17.0, *)) {
    NSSymbolEffectOptions *options = [TiSfsymbolsUtils optionsFromDict:step];

    // --- replace ---------------------------------------------------------
    if (Is(type, @"replace")) {
      NSString *symbol = [TiUtils stringValue:@"symbol" properties:step def:nil];
      NSMutableDictionary *styled = [_props mutableCopy];
      for (NSString *key in @[ @"pointSize", @"weight", @"scale", @"textStyle", @"renderingMode", @"color", @"colors", @"variableValue" ]) {
        if (step[key] != nil) styled[key] = step[key];
      }
      UIImage *image = [TiSfsymbolsUtils imageForSymbol:symbol props:styled];
      if (image == nil) {
        // Symbol does not exist on this iOS version: keep the current one.
        finish(NO);
        return;
      }
      _symbol = [symbol copy];
      [_props setDictionary:styled];
      if (!animated || ![TiUtils boolValue:step[@"animated"] def:YES]) {
        iv.image = image;
        finish(YES);
        return;
      }
      NSSymbolContentTransition *transition = [TiSfsymbolsUtils transitionFromDict:step];
      if (transition == nil) {
        iv.image = image;
        finish(YES);
        return;
      }
      [iv setSymbolImage:image withContentTransition:transition options:options completion:done];
      return;
    }

    // --- show (appear / drawOn) ----------------------------------------------
    if (Is(type, @"show") || Is(type, @"appear") || Is(type, @"drawOn")) {
      _symbolHidden = NO;
      NSString *symbol = [TiUtils stringValue:@"symbol" properties:step def:nil];
      if (symbol.length > 0) {
        _symbol = [symbol copy];
        [self refreshImage];
      }
      BOOL draw = Is(type, @"drawOn") || Is(step[@"effect"], @"draw");
      id hideEffect = nil;
      if (draw) {
        NSMutableDictionary *d = [step mutableCopy];
        d[@"type"] = @"drawOff";
        hideEffect = [TiSfsymbolsUtils effectFromDict:d];
      }
      if (hideEffect == nil) {
        NSMutableDictionary *d = [step mutableCopy];
        d[@"type"] = @"disappear";
        hideEffect = [TiSfsymbolsUtils effectFromDict:d];
      }
      [iv removeSymbolEffectOfType:hideEffect options:options animated:animated completion:done];
      return;
    }

    // --- hide (disappear / drawOff) --------------------------------------------
    if (Is(type, @"hide") || Is(type, @"disappear") || Is(type, @"drawOff")) {
      _symbolHidden = YES;
      BOOL draw = Is(type, @"drawOff") || Is(step[@"effect"], @"draw");
      NSMutableDictionary *d = [step mutableCopy];
      d[@"type"] = draw ? @"drawOff" : @"disappear";
      id effect = [TiSfsymbolsUtils effectFromDict:d];
      if (effect == nil) {
        d[@"type"] = @"disappear";
        effect = [TiSfsymbolsUtils effectFromDict:d];
      }
      [iv addSymbolEffect:effect options:options animated:animated completion:done];
      return;
    }

    // --- remove ----------------------------------------------------------------
    if (Is(type, @"remove")) {
      NSMutableDictionary *d = [step mutableCopy];
      d[@"type"] = [TiUtils stringValue:@"effect" properties:step def:@"pulse"];
      id effect = [TiSfsymbolsUtils effectFromDict:d];
      if (effect == nil) {
        finish(NO);
        return;
      }
      [iv removeSymbolEffectOfType:effect options:options animated:animated completion:done];
      return;
    }

    // --- every other effect ------------------------------------------------------
    id effect = [TiSfsymbolsUtils effectFromDict:step];
    if (effect == nil) {
      finish(NO);
      return;
    }
    if (reduceMotion) {
      finish(YES);
      return;
    }
    [iv addSymbolEffect:effect options:options animated:animated completion:done];
    // Effects that stay applied until removed don't "finish": the sequence moves
    // on right away unless the step defines a duration.
    if (!hasDuration && [TiSfsymbolsUtils isIndefiniteEffect:step]) {
      finish(YES);
    }
    return;
  }

  // iOS < 17: no symbol effects. Jump to the final state.
  NSString *symbol = [TiUtils stringValue:@"symbol" properties:step def:nil];
  if (symbol.length > 0) {
    _symbol = [symbol copy];
    [self refreshImage];
  }
  iv.hidden = Is(type, @"hide") || Is(type, @"disappear");
  finish(YES);
}

@end
