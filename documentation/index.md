# Ti.SFSymbols Module

Full SF Symbols for Titanium: styled symbol views, symbol effects, content transitions, variable values and rendering modes. iOS only.

See the [README](../README.md) for the complete API, and `example/app.js` for a runnable showcase.

```javascript
const SF = require('ti.sfsymbols')

const icon = SF.createSymbolView({ symbol: 'bell.fill', pointSize: 40, color: '#FF3B30' })
icon.addEffect({ type: SF.EFFECT_WIGGLE })
```
