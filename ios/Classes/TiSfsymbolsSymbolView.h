/**
 * Ti.SFSymbols
 *
 * Native SF Symbol view (UIImageView) with the full symbol styling and effect API.
 */

#import "TiUIView.h"

@interface TiSfsymbolsSymbolView : TiUIView

/// Runs a single step (effect, replace, show, hide, remove, wait). `completion`
/// is called exactly once on the main queue.
- (void)runStep:(NSDictionary *)step completion:(void (^)(BOOL finished))completion;

- (void)playSteps:(NSArray *)steps;
- (void)cancel;
- (void)removeAllEffects;
- (void)removeEffectOfType:(NSDictionary *)descriptor;
- (NSString *)currentSymbol;

@end
