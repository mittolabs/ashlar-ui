// Writes registry/palette.dart from shadcn/ui's apps/v4/registry/themes.ts: the base
// colours and the accents, converted from oklch to sRGB.
// Usage: node tool/palette.mjs <path to themes.ts> registry/palette.dart
import fs from 'node:fs';

const [src, out] = process.argv.slice(2);
const text = fs.readFileSync(src, 'utf8');

// Each theme: name, then its light and dark blocks of "key": "oklch(...)".
const themes = {};
for (const m of text.matchAll(/name: "(\w+)",[\s\S]*?cssVars: \{([\s\S]*?)\n    \},\n  \}/g)) {
  const [, name, body] = m;
  const block = (mode) => {
    const b = body.match(new RegExp(`${mode}: \\{([\\s\\S]*?)\\n      \\}`))[1];
    const vars = {};
    for (const v of b.matchAll(/"?([\w-]+)"?: "([^"]+)"/g)) vars[v[1]] = v[2];
    return vars;
  };
  themes[name] = { light: block('light'), dark: block('dark') };
}

function oklchToHex(s) {
  const m = s.match(/oklch\(([\d.]+)\s+([\d.]+)\s+([\d.]+)(?:\s*\/\s*([\d.]+)%)?\)/);
  if (!m) throw new Error('not oklch: ' + s);
  const [L, C, H] = [+m[1], +m[2], +m[3]];
  const alpha = m[4] === undefined ? 1 : +m[4] / 100;
  const a = C * Math.cos((H * Math.PI) / 180), b = C * Math.sin((H * Math.PI) / 180);
  const l_ = L + 0.3963377774 * a + 0.2158037573 * b;
  const m_ = L - 0.1055613458 * a - 0.0638541728 * b;
  const s_ = L - 0.0894841775 * a - 1.291485548 * b;
  const [l, mm, ss] = [l_ ** 3, m_ ** 3, s_ ** 3];
  const lin = [
    4.0767416621 * l - 3.3077115913 * mm + 0.2309699292 * ss,
    -1.2684380046 * l + 2.6097574011 * mm - 0.3413193965 * ss,
    -0.0041960863 * l - 0.7034186147 * mm + 1.707614701 * ss,
  ];
  const gamma = (x) => (x <= 0.0031308 ? 12.92 * x : 1.055 * x ** (1 / 2.4) - 0.055);
  const byte = (x) => Math.round(Math.min(1, Math.max(0, gamma(x))) * 255);
  const hex = (n) => n.toString(16).padStart(2, '0').toUpperCase();
  return `0x${hex(Math.round(alpha * 255))}${lin.map(byte).map(hex).join('')}`;
}

// WCAG contrast between two colours written as 0xAARRGGBB, ignoring alpha.
function contrast(x, y) {
  const lum = (h) => {
    const [r, g, b] = [h.slice(4, 6), h.slice(6, 8), h.slice(8, 10)].map((p) => parseInt(p, 16) / 255)
      .map((v) => (v <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  };
  const [a, b] = [lum(x), lum(y)];
  return (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
}

// [color] (oklch) moved darker or lighter, a little at a time, until it reaches [floor]
// against each of [against] (hex). Where shadcn's value already does, it is kept.
function atLeast(color, against, floor) {
  const m = color.match(/oklch\(([\d.]+)\s+([\d.]+)\s+([\d.]+)\)/);
  let L = +m[1];
  const lighter = against.every((h) => contrast(oklchToHex('oklch(1 0 0)'), h) >= contrast(oklchToHex('oklch(0 0 0)'), h));
  for (let i = 0; i < 200; i++) {
    const hex = oklchToHex(`oklch(${L.toFixed(4)} ${m[2]} ${m[3]})`);
    if (against.every((h) => contrast(hex, h) >= floor)) return `oklch(${L.toFixed(4)} ${m[2]} ${m[3]})`;
    L = lighter ? Math.min(1, L + 0.005) : Math.max(0, L - 0.005);
  }
  throw new Error('no contrast for ' + color);
}

// The floors: muted text 4.5 to 1 on the page and on muted surfaces; the sidebar's mark 3
// to 1, as a graphic, and its text 4.5 where it carries any.
function readable(v) {
  v['muted-foreground'] = atLeast(v['muted-foreground'], [oklchToHex(v.background), oklchToHex(v.muted)], 4.5);
  return v;
}

const camel = (k) => k.replace(/-(\w)/g, (_, c) => c.toUpperCase()).replace(/^chart(\d)$/, 'chart$1');
const fields = ['background', 'foreground', 'card', 'card-foreground', 'popover', 'popover-foreground', 'primary', 'primary-foreground', 'secondary', 'secondary-foreground', 'muted', 'muted-foreground', 'accent', 'accent-foreground', 'destructive', 'border', 'input', 'ring', 'sidebar', 'sidebar-foreground', 'sidebar-primary', 'sidebar-primary-foreground', 'sidebar-accent', 'sidebar-accent-foreground', 'sidebar-border', 'sidebar-ring'];
const bases = ['stone', 'zinc', 'mauve', 'olive', 'mist', 'taupe'];
const accents = ['amber', 'blue', 'cyan', 'emerald', 'fuchsia', 'green', 'indigo', 'lime', 'orange', 'pink', 'purple', 'red', 'rose', 'sky', 'teal', 'violet', 'yellow'];
const accentFields = ['primary', 'primary-foreground', 'secondary', 'secondary-foreground', 'chart-1', 'chart-2', 'chart-3', 'chart-4', 'chart-5', 'sidebar-primary', 'sidebar-primary-foreground'];

const title = (s) => s[0].toUpperCase() + s.slice(1);
let dart = `// Ashlar UI: the palette. Copied into your app with the theme; it is yours to change.
//
// GENERATED from shadcn/ui's themes (registry/themes.ts, oklch converted to sRGB) by the
// palette tool. Edit the tool, not this file, to change every colour at once.

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// The greys a theme is built on: neutral, or tinted warm, cool or green.
enum AshlarBase { neutral, stone, zinc, mauve, olive, mist, taupe }

/// A colour for the main actions, the charts and the sidebar's chosen item, over a base.
enum AshlarAccent {
${accents.map((a) => `  ${a},`).join('\n')}
}

/// The colours for [base] in [brightness], with [accent] over them when given. Neutral
/// is [AshlarColors.light] and [AshlarColors.dark]; the charts keep their colours unless an
/// accent sets them.
AshlarColors ashlarColors(
  AshlarBase base,
  Brightness brightness, [
  AshlarAccent? accent,
]) {
  final dark = brightness == Brightness.dark;
  final colors = switch (base) {
    AshlarBase.neutral => dark ? AshlarColors.dark : AshlarColors.light,
${bases.map((b) => `    AshlarBase.${b} => dark ? _${b}Dark : _${b}Light,`).join('\n')}
  };
  if (accent == null) return colors;
  final a = _accents[accent]!;
  final (p, pf, s, sf, c1, c2, c3, c4, c5, sp, spf) = dark ? a.$2 : a.$1;
  return colors.copyWith(
    primary: p,
    primaryForeground: pf,
    secondary: s,
    secondaryForeground: sf,
    chart1: c1,
    chart2: c2,
    chart3: c3,
    chart4: c4,
    chart5: c5,
    sidebarPrimary: sp,
    sidebarPrimaryForeground: spf,
  );
}
`;
for (const b of bases) {
  for (const mode of ['light', 'dark']) {
    const v = readable({ ...themes[b][mode] });
    const neutral = mode === 'light' ? 'AshlarColors.light' : 'AshlarColors.dark';
    dart += `
/// ${title(b)}, ${mode}.
final _${b}${title(mode)} = ${neutral}.copyWith(
${fields.map((f) => `  ${camel(f)}: const Color(${oklchToHex(v[f])}),`).join('\n')}
);
`;
  }
}
for (const a of accents) {
  for (const mode of ['light', 'dark']) {
    const v = themes[a][mode];
    v['sidebar-primary-foreground'] = atLeast(v['sidebar-primary-foreground'], [oklchToHex(v['sidebar-primary'])], 4.5);
  }
}
// Neutral lives in theme.dart; print its muted text at the floor to keep the two the same.
for (const mode of ['light', 'dark']) {
  const v = readable({ ...themes.neutral[mode] });
  console.log(`neutral ${mode} mutedForeground ${oklchToHex(v['muted-foreground'])}`);
}
const tuple = (v) => `(\n${accentFields.map((f) => `      Color(${oklchToHex(v[f])}),`).join('\n')}\n    )`;
dart += `
typedef _Accent = (
  Color, Color, Color, Color, Color, Color, Color, Color, Color, Color, Color,
);

/// Each accent, light then dark: primary and its foreground, secondary and its foreground,
/// the five chart colours, and the sidebar's primary and its foreground.
const _accents = <AshlarAccent, (_Accent, _Accent)>{
${accents.map((a) => `  AshlarAccent.${a}: (\n    ${tuple(themes[a].light)},\n    ${tuple(themes[a].dark)},\n  ),`).join('\n')}
};
`;
fs.writeFileSync(out, dart);
console.log('bases', bases.length + 1, 'accents', accents.length);
