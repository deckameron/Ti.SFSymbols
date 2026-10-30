# Ti.SFSymbols

> Native SF Symbols for Titanium SDK — styled symbol views, every symbol effect, content transitions, variable values and rendering modes. iOS only.

Titanium's `Ti.UI.iOS.systemImage()` returns a static image. Ti.SFSymbols gives you the rest of SF Symbols: the animated **symbol effects** (`appear`, `bounce`, `wiggle`, `drawOn`…), **magic replace** between two symbols, **variable values**, every **rendering mode** (hierarchical, palette, multicolor) and full control over weight, scale and text style — all from JavaScript, with completion events so you can chain animations.

![Titanium](https://img.shields.io/badge/Titanium-13.0+-red.svg) ![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg) ![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg) ![License](https://img.shields.io/badge/license-MIT-green.svg) ![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen.svg)

---

## Why Ti.SFSymbols over `systemImage()`?

| Feature | `Ti.UI.iOS.systemImage()` | Ti.SFSymbols |
|---|---|---|
| Show a symbol | ✅ | ✅ |
| Weight, scale, point size, text style | ❌ | ✅ |
| Hierarchical / palette / multicolor rendering | ❌ | ✅ |
| Variable value (Wi-Fi bars, volume…) | ❌ | ✅ |
| Symbol effects (bounce, pulse, wiggle, rotate, breathe, variable color) | ❌ | ✅ |
| Appear / disappear and Draw On / Draw Off | ❌ | ✅ |
| Magic Replace and other replace transitions | ❌ | ✅ |
| Chained sequences with completion events | ❌ | ✅ |
| Repeat count, continuous repeat, speed | ❌ | ✅ |
| Check if a symbol exists on this iOS version | ❌ | ✅ |
| Reduce Motion respected | — | ✅ |

---

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [SymbolView](#symbolview)
  - [Properties](#properties)
  - [Methods](#methods)
  - [Events](#events)
- [Effects](#effects)
  - [Effect options](#effect-options)
  - [Effect reference](#effect-reference)
  - [Discrete vs. indefinite effects](#discrete-vs-indefinite-effects)
- [Show and Hide](#show-and-hide)
- [Replace (content transitions)](#replace-content-transitions)
- [Sequences](#sequences)
- [Rendering modes and colors](#rendering-modes-and-colors)
- [Variable value](#variable-value)
- [createImage](#createimage)
- [Availability helpers](#availability-helpers)
- [Constants](#constants)
- [API Reference](#api-reference)
- [Full Example](#full-example)
- [Known Limitations](#known-limitations)
- [Requirements](#requirements)
- [License](#license)

---

## Installation

### 1. Download the Module

Download the latest `.zip` from the [Releases page](https://github.com/deckameron/Ti.SFSymbols/releases).

### 2. Install in your Titanium project

```bash
# Copy the compiled module to your project:
{YOUR_PROJECT}/modules/iphone/
```

### 3. Configure tiapp.xml

```xml
<modules>
    <module platform="iphone">ti.sfsymbols</module>
</modules>
```

---

## Quick Start

```javascript
const SF = require('ti.sfsymbols')

const icon = SF.createSymbolView({
    symbol: 'bell.fill',
    pointSize: 40,
    color: '#FF3B30',
    width: 60, height: 60,
})

win.add(icon)

// Wiggle, then swap to the badged bell with Magic Replace
icon.sequence([
    { type: SF.EFFECT_WIGGLE, scope: SF.SCOPE_BY_LAYER },
    { type: SF.STEP_REPLACE, symbol: 'bell.badge.fill', scope: SF.SCOPE_BY_LAYER },
])

icon.addEventListener('done', () => Ti.API.info('animation finished'))
```

---

## SymbolView

`createSymbolView(config)` creates a native `UIImageView` that displays an SF Symbol. It is a regular Titanium view, so `top`, `left`, `width`, `height`, `center`, `opacity`, `transform`, `accessibilityLabel` and everything else from `Ti.UI.View` work as usual.

### Properties

All styling properties can be set at creation time **and changed later** (`icon.weight = 'bold'`). The symbol is re-rendered on every change.

#### `symbol` · String · **required**

The SF Symbol name, exactly as shown in the SF Symbols app.

```javascript
const icon = SF.createSymbolView({ symbol: 'heart.fill' })
```

---

#### `fallbackSymbol` · String

Used when `symbol` does not exist on the running iOS version (new symbols ship with every iOS release).

```javascript
const icon = SF.createSymbolView({
    symbol: 'star.calendar',      // iOS 27+
    fallbackSymbol: 'calendar',   // older iOS
})
```

---

#### `pointSize` · Number

Point size of the symbol, like a font size. Ignored when `textStyle` is set.

---

#### `weight` · String · default: system

One of `SF.WEIGHT_ULTRA_LIGHT`, `WEIGHT_THIN`, `WEIGHT_LIGHT`, `WEIGHT_REGULAR`, `WEIGHT_MEDIUM`, `WEIGHT_SEMIBOLD`, `WEIGHT_BOLD`, `WEIGHT_HEAVY`, `WEIGHT_BLACK`.

---

#### `scale` · String · default: system

`SF.SCALE_SMALL`, `SF.SCALE_MEDIUM` or `SF.SCALE_LARGE`. Scales the glyph relative to its point size.

---

#### `textStyle` · String

Sizes the symbol like a Dynamic Type text style (it follows the user's text-size setting): `SF.TEXT_STYLE_LARGE_TITLE`, `TITLE1`, `TITLE2`, `TITLE3`, `HEADLINE`, `SUBHEADLINE`, `BODY`, `CALLOUT`, `FOOTNOTE`, `CAPTION1`, `CAPTION2`.

```javascript
const icon = SF.createSymbolView({ symbol: 'heart.fill', textStyle: SF.TEXT_STYLE_TITLE2 })
```

---

#### `renderingMode` · String · default: `automatic`

`SF.RENDERING_MODE_AUTOMATIC`, `MONOCHROME`, `HIERARCHICAL`, `PALETTE` or `MULTICOLOR`. See [Rendering modes and colors](#rendering-modes-and-colors).

---

#### `color` · String (color)

The symbol color. In `monochrome` it is the tint; in `hierarchical` it is the primary color the layers derive from.

---

#### `colors` · Array of String

Palette colors for `renderingMode: SF.RENDERING_MODE_PALETTE` — one color per symbol layer (primary, secondary, tertiary).

---

#### `variableValue` · Number (0.0 – 1.0)

Fills the "variable" layers of symbols that support it (`wifi`, `speaker.wave.3.fill`, `chart.bar.fill`…). See [Variable value](#variable-value).

---

#### `variableValueMode` · String · iOS 26+

`SF.VARIABLE_VALUE_MODE_AUTOMATIC`, `COLOR` (layers switch on/off) or `DRAW` (layers draw proportionally).

---

#### `colorRenderingMode` · String · iOS 26+

`SF.COLOR_RENDERING_MODE_AUTOMATIC`, `FLAT` or `GRADIENT` (the iOS 26 gradient rendering).

---

#### `symbolHidden` · Boolean · default: `false`

Starts the symbol invisible so you can reveal it later with `show()` or a sequence's `show` step.

```javascript
const icon = SF.createSymbolView({ symbol: 'checkmark.circle.fill', symbolHidden: true })
icon.show() // animated appear
```

---

### Methods

| Method | Description |
|---|---|
| `addEffect(options)` | Runs a symbol effect. See [Effects](#effects). |
| `removeEffect(type)` | Stops an indefinite/continuous effect. Accepts a type string or `{ type, animated }`. |
| `removeAllEffects()` | Removes every active effect (a hidden symbol stays hidden). |
| `show(options)` | Reveals the symbol with an appear (or Draw On) animation. |
| `hide(options)` | Hides the symbol with a disappear (or Draw Off) animation. |
| `replace(symbol, options)` | Swaps the symbol with an animated content transition. |
| `sequence(steps)` | Runs a chain of steps one after another. |
| `cancel()` | Stops a running `sequence()`. Effects already running keep going. |
| `currentSymbol()` | Returns the name of the symbol currently displayed. |

One-shot methods (`addEffect`, `show`, `hide`, `replace`) fire a [`complete`](#events) event when they finish. Pass an `id` option to tell concurrent calls apart.

---

### Events

| Event | Fired by | Payload |
|---|---|---|
| `complete` | `addEffect`, `show`, `hide`, `replace` | `action`, `type`, `finished`, `symbol`, `id` (if you passed one) |
| `stepdone` | each step of a `sequence()` | `index`, `type`, `finished` |
| `done` | end of a `sequence()` | `symbol` |

```javascript
icon.addEventListener('complete', e => {
    Ti.API.info(e.action + ' finished: ' + e.finished)
})

icon.addEffect({ type: SF.EFFECT_BOUNCE, id: 'tap-bounce' })
```

`finished` is `false` when the effect was interrupted, the symbol does not exist on this iOS version, or the safety timeout (2.5 s) moved on.

---

## Effects

```javascript
icon.addEffect({
    type: SF.EFFECT_BOUNCE,
    direction: SF.DIRECTION_UP,
    scope: SF.SCOPE_BY_LAYER,
    repeatCount: 2,
    speed: 1.5,
})
```

### Effect options

| Option | Type | Description |
|---|---|---|
| `type` | String | **Required.** One of the `SF.EFFECT_*` constants. |
| `scope` | String | `SF.SCOPE_BY_LAYER` or `SF.SCOPE_WHOLE_SYMBOL` — animate layer by layer or the symbol as one piece. Default: the symbol's own preference. |
| `direction` | String | Direction variants — see the table below. |
| `repeat` | String | `SF.REPEAT_NONE` (default), `SF.REPEAT_PERIODIC` or `SF.REPEAT_CONTINUOUS` (until `removeEffect`). |
| `repeatCount` | Number | Play this many times. Implies periodic repeat. |
| `repeatDelay` | Number | Milliseconds between repeats (iOS 18+). |
| `speed` | Number | Playback speed multiplier. `1` is normal. |
| `animated` | Boolean | Set `false` to apply the end state without animating. Default `true`. |
| `duration` | Number | Milliseconds. In a `sequence`, advance after this time instead of waiting for the effect to finish. |
| `id` | String | Echoed back in the `complete` event. |

> Effects default to **non-repeating**, so sequences are predictable. Use `repeat: SF.REPEAT_CONTINUOUS` to loop.

### Effect reference

| Constant | iOS | Kind | Specific options |
|---|---|---|---|
| `EFFECT_APPEAR` | 17 | transition | `direction`: `up`, `down` |
| `EFFECT_DISAPPEAR` | 17 | transition | `direction`: `up`, `down` |
| `EFFECT_BOUNCE` | 17 | discrete | `direction`: `up`, `down` |
| `EFFECT_PULSE` | 17 | indefinite | — |
| `EFFECT_SCALE` | 17 | indefinite (holds) | `direction`: `up`, `down` |
| `EFFECT_VARIABLE_COLOR` | 17 | indefinite | `iterative`, `cumulative`, `reversing`, `nonReversing`, `hideInactiveLayers`, `dimInactiveLayers` (Booleans) |
| `EFFECT_WIGGLE` | 18 | discrete | `direction`: `clockwise`, `counterClockwise`, `left`, `right`, `up`, `down`, `forward`, `backward`; or `angle` (degrees) |
| `EFFECT_ROTATE` | 18 | discrete | `direction`: `clockwise`, `counterClockwise` |
| `EFFECT_BREATHE` | 18 | indefinite | `variant`: `pulse`, `plain` |
| `EFFECT_DRAW_ON` | 26 | transition | `individually` (Boolean) |
| `EFFECT_DRAW_OFF` | 26 | transition | `individually`, `reversed`, `nonReversed` (Booleans) |

On an iOS version that does not have an effect, the call is a no-op and `complete` reports `finished: false`. Check first with [`isEffectSupported()`](#availability-helpers).

### Discrete vs. indefinite effects

- **Discrete** effects (`bounce`, `wiggle`, `rotate`) play once and finish by themselves.
- **Indefinite** effects (`pulse`, `variableColor`, `breathe`, `scale`) can keep running. With `repeat: SF.REPEAT_CONTINUOUS`, or for `scale`, the effect stays until you call `removeEffect()`. In a `sequence`, the next step starts immediately after an indefinite effect begins.

```javascript
icon.addEffect({ type: SF.EFFECT_PULSE, repeat: SF.REPEAT_CONTINUOUS })
// ...later
icon.removeEffect(SF.EFFECT_PULSE)
```

---

## Show and Hide

`show()` and `hide()` animate the symbol in and out without removing the view.

```javascript
icon.hide()                                    // disappear
icon.show()                                    // appear
icon.show({ effect: 'draw' })                  // Draw On  (iOS 26+)
icon.hide({ effect: 'draw', reversed: true })  // Draw Off (iOS 26+)
icon.hide({ animated: false })                 // instant
```

Both accept the [effect options](#effect-options) (`scope`, `direction`, `speed`, `id`…).

---

## Replace (content transitions)

`replace()` swaps one symbol for another with an animated transition. The default is **Magic Replace**, which morphs the shared parts of two related symbols (a lock opening, a bell gaining a badge).

```javascript
icon.replace('lock.open.fill')

icon.replace('bell.badge.fill', {
    transition: SF.TRANSITION_MAGIC,
    fallback: SF.TRANSITION_DOWN_UP,   // used when the two symbols are not related
    scope: SF.SCOPE_BY_LAYER,
})
```

| Option | Description |
|---|---|
| `transition` | `SF.TRANSITION_MAGIC` (default, iOS 18+), `TRANSITION_DEFAULT`, `TRANSITION_DOWN_UP`, `TRANSITION_UP_UP`, `TRANSITION_OFF_UP`, `TRANSITION_AUTOMATIC`. |
| `fallback` | The replace variant Magic Replace uses when it cannot morph the pair. Default `downUp`. |
| `scope` | `SF.SCOPE_BY_LAYER` or `SF.SCOPE_WHOLE_SYMBOL`. |
| `animated` | `false` swaps instantly. |
| Styling keys | `pointSize`, `weight`, `scale`, `textStyle`, `renderingMode`, `color`, `colors`, `variableValue` — applied to the new symbol. |

If the new symbol does not exist on the running iOS version, the current symbol stays and `complete` reports `finished: false`. The icon never goes blank.

---

## Sequences

`sequence()` runs steps one after another. A step starts when the previous one **finishes** (the native completion callback), so animations chain exactly — no guessed timeouts.

```javascript
icon.hide({ animated: false })

icon.sequence([
    { type: 'show' },
    { type: SF.EFFECT_BOUNCE },
    { type: 'replace', symbol: 'star.fill', delay: 350, scope: SF.SCOPE_BY_LAYER },
    { type: 'wait', duration: 400 },
    { type: SF.EFFECT_PULSE, repeatCount: 2 },
])

icon.addEventListener('stepdone', e => Ti.API.info('step ' + e.index + ' ' + e.type))
icon.addEventListener('done', () => Ti.API.info('all done'))
```

Step types: any `SF.EFFECT_*`, plus `show`, `hide`, `replace`, `remove` (with `effect: 'pulse'`) and `wait` (with `duration`). Every step accepts `delay` (ms **after the previous step finished**) and the usual [effect options](#effect-options).

Calling `sequence()` again, or `cancel()`, stops the previous sequence.

> **Reduce Motion:** when the user enables Reduce Motion, sequences skip animations and jump to each step's final state, so nothing blocks the flow.

---

## Rendering modes and colors

```javascript
// Hierarchical: layers derive from one color
SF.createSymbolView({ symbol: 'cloud.sun.rain.fill', renderingMode: SF.RENDERING_MODE_HIERARCHICAL, color: '#0A84FF' })

// Palette: one color per layer
SF.createSymbolView({
    symbol: 'cloud.sun.rain.fill',
    renderingMode: SF.RENDERING_MODE_PALETTE,
    colors: ['#FFFFFF', '#FFCC00', '#0A84FF'],
})

// Multicolor: the symbol's built-in colors
SF.createSymbolView({ symbol: 'cloud.sun.rain.fill', renderingMode: SF.RENDERING_MODE_MULTICOLOR })
```

Not every symbol has multiple layers or a multicolor variant — those fall back to monochrome.

---

## Variable value

Symbols such as `wifi`, `speaker.wave.3.fill` and `chart.bar.fill` have layers that fill in with a value between `0` and `1`.

```javascript
const wifi = SF.createSymbolView({ symbol: 'wifi', pointSize: 40, variableValue: 0.4 })

wifi.variableValue = 0.9   // re-renders
```

On iOS 26+ choose how the layers respond with `variableValueMode` (`color` switches layers on and off, `draw` draws them proportionally).

---

## createImage

`createImage(config)` returns a `Ti.Blob` with the rendered symbol, for the places that take an image: `Ti.UI.createImageView`, `Ti.UI.createButton({ image })`, tab icons, nav bar buttons and so on. It accepts the same styling keys as the view.

```javascript
const blob = SF.createImage({
    symbol: 'star.fill',
    pointSize: 28,
    weight: SF.WEIGHT_SEMIBOLD,
    color: '#FFD60A',
})

const tabIcon = SF.createImage({ symbol: 'house.fill', template: true }) // takes the tint color of its container

win.add(Ti.UI.createImageView({ image: blob }))
```

Returns `null` if the symbol does not exist (after trying `fallbackSymbol`). Effects and transitions need a live view — use `createSymbolView` for those.

---

## Availability helpers

```javascript
SF.isAvailable('star.calendar')    // true on iOS 27+, false before
SF.isEffectSupported('drawOn')     // true on iOS 26+
```

Use them to choose a symbol or effect up front, or rely on `fallbackSymbol`.

---

## Constants

| Group | Constants |
|---|---|
| Weight | `WEIGHT_ULTRA_LIGHT`, `WEIGHT_THIN`, `WEIGHT_LIGHT`, `WEIGHT_REGULAR`, `WEIGHT_MEDIUM`, `WEIGHT_SEMIBOLD`, `WEIGHT_BOLD`, `WEIGHT_HEAVY`, `WEIGHT_BLACK` |
| Scale | `SCALE_SMALL`, `SCALE_MEDIUM`, `SCALE_LARGE` |
| Text style | `TEXT_STYLE_LARGE_TITLE`, `TEXT_STYLE_TITLE1` … `TITLE3`, `TEXT_STYLE_HEADLINE`, `TEXT_STYLE_SUBHEADLINE`, `TEXT_STYLE_BODY`, `TEXT_STYLE_CALLOUT`, `TEXT_STYLE_FOOTNOTE`, `TEXT_STYLE_CAPTION1`, `TEXT_STYLE_CAPTION2` |
| Rendering mode | `RENDERING_MODE_AUTOMATIC`, `RENDERING_MODE_MONOCHROME`, `RENDERING_MODE_HIERARCHICAL`, `RENDERING_MODE_PALETTE`, `RENDERING_MODE_MULTICOLOR` |
| Variable value mode | `VARIABLE_VALUE_MODE_AUTOMATIC`, `VARIABLE_VALUE_MODE_COLOR`, `VARIABLE_VALUE_MODE_DRAW` |
| Color rendering mode | `COLOR_RENDERING_MODE_AUTOMATIC`, `COLOR_RENDERING_MODE_FLAT`, `COLOR_RENDERING_MODE_GRADIENT` |
| Effects | `EFFECT_APPEAR`, `EFFECT_DISAPPEAR`, `EFFECT_BOUNCE`, `EFFECT_PULSE`, `EFFECT_SCALE`, `EFFECT_VARIABLE_COLOR`, `EFFECT_WIGGLE`, `EFFECT_ROTATE`, `EFFECT_BREATHE`, `EFFECT_DRAW_ON`, `EFFECT_DRAW_OFF` |
| Step types | `STEP_REPLACE`, `STEP_SHOW`, `STEP_HIDE`, `STEP_REMOVE`, `STEP_WAIT` |
| Transitions | `TRANSITION_MAGIC`, `TRANSITION_DEFAULT`, `TRANSITION_AUTOMATIC`, `TRANSITION_DOWN_UP`, `TRANSITION_UP_UP`, `TRANSITION_OFF_UP` |
| Scope | `SCOPE_BY_LAYER`, `SCOPE_WHOLE_SYMBOL` |
| Direction | `DIRECTION_UP`, `DIRECTION_DOWN`, `DIRECTION_LEFT`, `DIRECTION_RIGHT`, `DIRECTION_CLOCKWISE`, `DIRECTION_COUNTER_CLOCKWISE`, `DIRECTION_FORWARD`, `DIRECTION_BACKWARD` |
| Repeat | `REPEAT_NONE`, `REPEAT_PERIODIC`, `REPEAT_CONTINUOUS` |

All constants are plain strings, so `'bold'` and `SF.WEIGHT_BOLD` are interchangeable.

---

## API Reference

### `createSymbolView(config)` → `SymbolView`

Creates a symbol view. `config` accepts every [property](#properties) plus the standard `Ti.UI.View` ones.

### `createImage(config)` → `Ti.Blob`

Renders a symbol to an image. See [createImage](#createimage).

### `isAvailable(name)` → `Boolean`

`true` if the symbol exists on the running iOS version.

### `isEffectSupported(type)` → `Boolean`

`true` if the effect or content transition (`'drawOn'`, `'wiggle'`, `'magic'`…) exists on the running iOS version.

---

## Full Example

```javascript
const SF = require('ti.sfsymbols')

const win = Ti.UI.createWindow({ backgroundColor: '#111' })

// A "trial timeline" icon: lock opens, then the row continues
const lock = SF.createSymbolView({
    symbol: 'lock.fill',
    symbolHidden: true,
    pointSize: 24,
    color: '#FF5A4D',
    width: 40, height: 40,
})
win.add(lock)

lock.sequence([
    { type: 'show' },
    { type: 'replace', symbol: 'lock.open.fill', delay: 450, scope: SF.SCOPE_WHOLE_SYMBOL },
])

lock.addEventListener('done', () => {
    // continue with whatever comes next: draw a line, start the next row...
})

// A loading indicator
const wifi = SF.createSymbolView({ symbol: 'wifi', pointSize: 36, color: '#0A84FF', top: 100 })
win.add(wifi)
wifi.addEffect({ type: SF.EFFECT_VARIABLE_COLOR, iterative: true, repeat: SF.REPEAT_CONTINUOUS })

// Stop it when loading ends
setTimeout(() => wifi.removeEffect(SF.EFFECT_VARIABLE_COLOR), 4000)

// A like button
const heart = SF.createSymbolView({ symbol: 'heart', pointSize: 34, color: '#FF2D55', top: 200 })
heart.addEventListener('click', () => {
    heart.replace('heart.fill')
    heart.addEffect({ type: SF.EFFECT_BOUNCE })
})
win.add(heart)

win.open()
```

---

## Known Limitations

- **iOS only.** There is no Android equivalent of SF Symbols.
- **Symbols are version-bound.** A symbol introduced in iOS 27 does not exist on iOS 26. Use `fallbackSymbol` or `isAvailable()`.
- **Effects need a live view.** `createImage` returns a static image; effects and transitions only work on `createSymbolView`.
- **Magic Replace needs related symbols.** It morphs symbols that share parts (`lock.fill` → `lock.open.fill`). For unrelated symbols iOS uses the `fallback` transition.
- **Indefinite effects have no end event.** `pulse`, `breathe`, `variableColor` with `repeat: SF.REPEAT_CONTINUOUS`, and `scale` keep running until `removeEffect()`; the `complete` event does not mean they stopped.
- **Repeat delay and continuous repeat** need iOS 18+. On iOS 17 `repeatCount` still works, the delay is ignored.
- **Not a text or button component.** The module provides an image view. For a button, add a click listener to the view or use `createImage()` with `Ti.UI.createButton`.

---

## Requirements

- Titanium SDK 13.0+
- iOS 17.0+ (individual effects need iOS 18 / 26, see [Effect reference](#effect-reference))
- Xcode 16+ (Xcode 26+ to build the Draw On / Draw Off effects)

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

MIT License — see [LICENSE](LICENSE) for details.
