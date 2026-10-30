#import "TiSfsymbolsSymbolViewProxy.h"
#import "TiSfsymbolsSymbolView.h"
#import "TiUtils.h"

@implementation TiSfsymbolsSymbolViewProxy

- (TiSfsymbolsSymbolView *)symbolView
{
  return (TiSfsymbolsSymbolView *)[self view];
}

// Fires "complete" for one-shot calls (addEffect, replace, show, hide...).
- (void)runOneShot:(NSMutableDictionary *)step action:(NSString *)action
{
  NSString *callId = step[@"id"];
  TiThreadPerformOnMainThread(^{
    [[self symbolView] runStep:step
                    completion:^(BOOL finished) {
                      if (![self _hasListeners:@"complete"]) return;
                      NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
                        @"action" : action,
                        @"type" : step[@"type"] ?: @"",
                        @"finished" : @(finished),
                        @"symbol" : [[self symbolView] currentSymbol] ?: @""
                      }];
                      if (callId) event[@"id"] = callId;
                      [self fireEvent:@"complete" withObject:event];
                    }];
  }, NO);
}

- (NSMutableDictionary *)stepFromArgs:(id)args type:(NSString *)type
{
  NSMutableDictionary *step = [NSMutableDictionary dictionary];
  id first = [args count] > 0 ? [args objectAtIndex:0] : nil;
  if ([first isKindOfClass:[NSDictionary class]]) {
    [step addEntriesFromDictionary:first];
  }
  if (type) step[@"type"] = type;
  return step;
}

#pragma mark Sequence

// sequence([{ type, symbol, delay, ... }, ...])
- (void)sequence:(id)args
{
  ENSURE_SINGLE_ARG(args, NSArray);
  NSArray *steps = [args copy];
  TiThreadPerformOnMainThread(^{
    [[self symbolView] playSteps:steps];
  }, NO);
}

- (void)cancel:(id)unused
{
  TiThreadPerformOnMainThread(^{
    [[self symbolView] cancel];
  }, NO);
}

#pragma mark One-shot effects

// addEffect({ type: 'bounce', direction, scope, repeat, repeatCount, repeatDelay, speed, ... })
- (void)addEffect:(id)args
{
  NSMutableDictionary *step = [self stepFromArgs:args type:nil];
  if (step[@"type"] == nil) step[@"type"] = @"pulse";
  [self runOneShot:step action:@"addEffect"];
}

// removeEffect('pulse') or removeEffect({ type: 'pulse', animated: true })
- (void)removeEffect:(id)args
{
  id first = [args count] > 0 ? [args objectAtIndex:0] : nil;
  NSDictionary *descriptor = [first isKindOfClass:[NSString class]] ? @{ @"type" : first }
                                                                    : ([first isKindOfClass:[NSDictionary class]] ? first : @{});
  TiThreadPerformOnMainThread(^{
    [[self symbolView] removeEffectOfType:descriptor];
  }, NO);
}

- (void)removeAllEffects:(id)unused
{
  TiThreadPerformOnMainThread(^{
    [[self symbolView] removeAllEffects];
  }, NO);
}

// replace('symbol.name', { transition, scope, fallback, ... })
- (void)replace:(id)args
{
  NSMutableDictionary *step = [NSMutableDictionary dictionary];
  id first = [args count] > 0 ? [args objectAtIndex:0] : nil;
  id second = [args count] > 1 ? [args objectAtIndex:1] : nil;
  if ([first isKindOfClass:[NSDictionary class]]) {
    [step addEntriesFromDictionary:first];
  } else if ([first isKindOfClass:[NSString class]]) {
    step[@"symbol"] = first;
    if ([second isKindOfClass:[NSDictionary class]]) [step addEntriesFromDictionary:second];
  }
  step[@"type"] = @"replace";
  [self runOneShot:step action:@"replace"];
}

// show({ effect: 'appear'|'draw', direction, scope, ... })
- (void)show:(id)args
{
  [self runOneShot:[self stepFromArgs:args type:@"show"] action:@"show"];
}

// hide({ effect: 'appear'|'draw', direction, scope, ... })
- (void)hide:(id)args
{
  [self runOneShot:[self stepFromArgs:args type:@"hide"] action:@"hide"];
}

// currentSymbol() -> name of the symbol currently displayed (updated by replace and sequences)
- (id)currentSymbol:(id)unused
{
  __block NSString *name = nil;
  TiThreadPerformOnMainThread(^{
    name = [[self symbolView] currentSymbol];
  }, YES);
  return name;
}

@end
