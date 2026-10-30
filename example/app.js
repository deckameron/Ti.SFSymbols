// Ti.SFSymbols — example / test harness
const SF = require('ti.sfsymbols');

const win = Ti.UI.createWindow({ backgroundColor: '#111' });
const scroll = Ti.UI.createScrollView({ layout: 'vertical', contentWidth: Ti.UI.FILL, showVerticalScrollIndicator: false });
win.add(scroll);

const TINT = '#FF5A4D';

function section(title) {
    scroll.add(Ti.UI.createLabel({
        text: title, color: '#8E8E93', font: { fontSize: 13, fontWeight: 'bold' },
        left: 16, top: 22, height: Ti.UI.SIZE
    }));
}

function row() {
    const r = Ti.UI.createView({ layout: 'horizontal', left: 16, right: 16, top: 8, height: Ti.UI.SIZE });
    scroll.add(r);
    return r;
}

// A tappable cell: symbol + caption. `onTap(icon)` runs the effect.
function cell(parent, caption, props, onTap) {
    const box = Ti.UI.createView({ width: 82, height: 84, layout: 'vertical' });
    const icon = SF.createSymbolView(Object.assign({
        pointSize: 34, color: TINT, width: 60, height: 50, top: 0
    }, props));
    box.add(icon);
    box.add(Ti.UI.createLabel({
        text: caption, color: '#AAA', font: { fontSize: 10 }, top: 2,
        textAlign: 'center', height: Ti.UI.SIZE, width: 78
    }));
    if (onTap) box.addEventListener('click', function () { onTap(icon); });
    parent.add(box);
    return icon;
}

// 1. Styling ------------------------------------------------------------------
section('WEIGHTS');
let r = row();
[SF.WEIGHT_ULTRA_LIGHT, SF.WEIGHT_LIGHT, SF.WEIGHT_REGULAR, SF.WEIGHT_BOLD, SF.WEIGHT_BLACK].forEach(function (w) {
    cell(r, w, { symbol: 'heart.fill', weight: w });
});

section('RENDERING MODES');
r = row();
cell(r, 'monochrome', { symbol: 'cloud.sun.rain.fill', renderingMode: SF.RENDERING_MODE_MONOCHROME });
cell(r, 'hierarchical', { symbol: 'cloud.sun.rain.fill', renderingMode: SF.RENDERING_MODE_HIERARCHICAL });
cell(r, 'palette', { symbol: 'cloud.sun.rain.fill', renderingMode: SF.RENDERING_MODE_PALETTE, colors: ['#FFFFFF', '#FFCC00', '#0A84FF'] });
cell(r, 'multicolor', { symbol: 'cloud.sun.rain.fill', renderingMode: SF.RENDERING_MODE_MULTICOLOR });

section('VARIABLE VALUE (tap = animate 0 → 1)');
r = row();
[0, 0.35, 0.7, 1].forEach(function (v) {
    cell(r, 'value ' + v, { symbol: 'speaker.wave.3.fill', variableValue: v });
});
cell(r, 'tap', { symbol: 'wifi', variableValue: 0 }, function (icon) {
    let v = 0;
    const t = setInterval(function () {
        v += 0.25;
        icon.variableValue = Math.min(v, 1);
        if (v >= 1) clearInterval(t);
    }, 250);
});

// 2. Effects --------------------------------------------------------------------
section('EFFECTS (tap)');
r = row();
cell(r, 'bounce', { symbol: 'arrow.down.circle.fill' }, function (i) { i.addEffect({ type: SF.EFFECT_BOUNCE, direction: SF.DIRECTION_DOWN }); });
cell(r, 'pulse', { symbol: 'wifi' }, function (i) { i.addEffect({ type: SF.EFFECT_PULSE, repeatCount: 3 }); });
cell(r, 'wiggle', { symbol: 'bell.fill' }, function (i) { i.addEffect({ type: SF.EFFECT_WIGGLE, scope: SF.SCOPE_BY_LAYER }); });
cell(r, 'rotate', { symbol: 'gear' }, function (i) { i.addEffect({ type: SF.EFFECT_ROTATE, direction: SF.DIRECTION_CLOCKWISE }); });
cell(r, 'breathe', { symbol: 'heart.fill' }, function (i) { i.addEffect({ type: SF.EFFECT_BREATHE, repeatCount: 2 }); });
cell(r, 'variableColor', { symbol: 'wifi' }, function (i) { i.addEffect({ type: SF.EFFECT_VARIABLE_COLOR, iterative: true, repeatCount: 2 }); });

section('CONTINUOUS (tap = start / stop)');
r = row();
['pulse', 'breathe', 'rotate', 'variableColor'].forEach(function (t) {
    let on = false;
    cell(r, t, { symbol: t === 'rotate' ? 'arrow.triangle.2.circlepath' : (t === 'variableColor' ? 'wifi' : 'heart.fill') }, function (i) {
        on = !on;
        if (on) i.addEffect({ type: t, repeat: SF.REPEAT_CONTINUOUS });
        else i.removeEffect(t);
    });
});
let scaleOn = false;
cell(r, 'scale (hold)', { symbol: 'star.fill' }, function (i) {
    scaleOn = !scaleOn;
    if (scaleOn) i.addEffect({ type: SF.EFFECT_SCALE, direction: SF.DIRECTION_UP });
    else i.removeEffect('scale');
});

// 3. Show / hide -------------------------------------------------------------------
section('SHOW / HIDE (tap)');
r = row();
[['appear', 'appear'], ['draw', 'draw']].forEach(function (p) {
    let visible = false;
    cell(r, p[0] + ' / ' + (p[0] === 'draw' ? 'drawOff' : 'disappear'), { symbol: 'checkmark.circle.fill', symbolHidden: true }, function (i) {
        visible = !visible;
        if (visible) i.show({ effect: p[1] }); else i.hide({ effect: p[1] });
    });
});

// 4. Replace -------------------------------------------------------------------------
section('REPLACE (tap)');
r = row();
[SF.TRANSITION_MAGIC, SF.TRANSITION_DOWN_UP, SF.TRANSITION_UP_UP, SF.TRANSITION_OFF_UP, SF.TRANSITION_AUTOMATIC].forEach(function (t) {
    let open = false;
    cell(r, t, { symbol: 'lock.fill' }, function (i) {
        open = !open;
        i.replace(open ? 'lock.open.fill' : 'lock.fill', { transition: t });
    });
});

// 5. Sequence ---------------------------------------------------------------------------
section('SEQUENCE (tap)');
r = row();
const seqIcon = cell(r, 'bell → badge', { symbol: 'bell.fill', symbolHidden: true }, function (i) {
    i.hide({ animated: false });
    i.sequence([
        { type: 'show' },
        { type: SF.EFFECT_WIGGLE, scope: SF.SCOPE_BY_LAYER },
        { type: 'replace', symbol: 'bell.badge.fill', scope: SF.SCOPE_BY_LAYER }
    ]);
});
const log = Ti.UI.createLabel({ text: '', color: '#888', font: { fontSize: 11 }, left: 16, top: 6, height: Ti.UI.SIZE });
scroll.add(log);
seqIcon.addEventListener('stepdone', function (e) { log.text += 'step ' + e.index + ' ' + e.type + '  '; });
seqIcon.addEventListener('done', function () { log.text += '· done'; });

// 6. Images / availability --------------------------------------------------------------
section('createImage() + isAvailable()');
r = row();
const blob = SF.createImage({ symbol: 'star.fill', pointSize: 34, color: '#FFD60A' });
r.add(Ti.UI.createImageView({ image: blob, width: 50, height: 50 }));
const hier = SF.createImage({ symbol: 'externaldrive.fill.badge.checkmark', pointSize: 34, renderingMode: SF.RENDERING_MODE_PALETTE, colors: ['#FFF', '#30D158', '#0A84FF'] });
r.add(Ti.UI.createImageView({ image: hier, width: 50, height: 50, left: 12 }));
scroll.add(Ti.UI.createLabel({
    text: 'star.calendar available: ' + SF.isAvailable('star.calendar') +
        '   drawOn supported: ' + SF.isEffectSupported('drawOn'),
    color: '#888', font: { fontSize: 11 }, left: 16, top: 8, height: Ti.UI.SIZE
}));
scroll.add(Ti.UI.createView({ height: 40 }));

win.open();
