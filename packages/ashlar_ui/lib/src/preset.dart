// A theme as one short code: its base, accent and style, and whatever was changed on top
// of them. The themes page makes one; `ashlar init --preset` and `ashlar apply --preset`
// write it into an app's app_theme.dart. Plain Dart, so the page can use it in a browser.
import 'dart:convert';

/// The theme choices `ashlar init` and `ashlar apply` take, as palette.dart and theme.dart
/// name them.
const bases = ['neutral', 'stone', 'zinc', 'mauve', 'olive', 'mist', 'taupe'];
const accents = [
  'amber',
  'blue',
  'cyan',
  'emerald',
  'fuchsia',
  'green',
  'indigo',
  'lime',
  'orange',
  'pink',
  'purple',
  'red',
  'rose',
  'sky',
  'teal',
  'violet',
  'yellow',
];
const styles = ['standard', 'compact', 'rounded', 'sharp', 'dense', 'soft'];

/// Every colour a theme sets, as AshlarColors names them.
const colorTokens = [
  'background',
  'foreground',
  'card',
  'cardForeground',
  'popover',
  'popoverForeground',
  'primary',
  'primaryForeground',
  'secondary',
  'secondaryForeground',
  'muted',
  'mutedForeground',
  'accent',
  'accentForeground',
  'destructive',
  'destructiveForeground',
  'border',
  'input',
  'ring',
  'chart1',
  'chart2',
  'chart3',
  'chart4',
  'chart5',
  'sidebar',
  'sidebarForeground',
  'sidebarPrimary',
  'sidebarPrimaryForeground',
  'sidebarAccent',
  'sidebarAccentForeground',
  'sidebarBorder',
  'sidebarRing',
];

/// A theme: a base, an accent and a style, with the corners, spacing and colours changed
/// on top of them, if any. [code] writes it as one line; [ThemePreset.parse] reads it.
class ThemePreset {
  const ThemePreset({
    this.base = 'neutral',
    this.accent,
    this.style = 'standard',
    this.radius,
    this.density,
    this.spacing,
    this.flat,
    this.light = const {},
    this.dark = const {},
  });

  final String base;
  final String? accent;
  final String style;

  /// The style's corners, size of controls, room in panels and shadows, changed; null
  /// keeps the style's own.
  final double? radius, density, spacing;
  final bool? flat;

  /// Colours changed from the base and accent's, by name, as 0xAARRGGBB: in light and
  /// in dark.
  final Map<String, int> light, dark;

  /// Whether anything is changed on top of the base, accent and style.
  bool get changed =>
      radius != null ||
      density != null ||
      spacing != null ||
      flat != null ||
      light.isNotEmpty ||
      dark.isNotEmpty;

  static const _prefix = 'a1';

  /// The theme as one line of letters and digits, for `--preset` and for a link.
  String get code {
    String hex(int c) => c.toRadixString(16).padLeft(8, '0');
    // Whole numbers without their .0, so codes stay short.
    num n(double v) => v == v.roundToDouble() ? v.toInt() : v;
    final json = {
      if (base != 'neutral') 'b': base,
      if (accent != null) 'a': accent,
      if (style != 'standard') 's': style,
      if (radius != null) 'r': n(radius!),
      if (density != null) 'd': n(density!),
      if (spacing != null) 'p': n(spacing!),
      if (flat != null) 'f': flat,
      if (light.isNotEmpty)
        'l': {for (final e in light.entries) e.key: hex(e.value)},
      if (dark.isNotEmpty)
        'k': {for (final e in dark.entries) e.key: hex(e.value)},
    };
    return _prefix +
        base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  }

  /// Reads a [code]. Throws a [FormatException] saying what is wrong with it.
  static ThemePreset parse(String code) {
    final c = code.trim();
    if (!c.startsWith(_prefix)) {
      throw const FormatException(
        'Not a theme preset: a preset starts with a1.',
      );
    }
    final Object? decoded;
    try {
      final body = c.substring(_prefix.length);
      decoded = jsonDecode(
        utf8.decode(
          base64Url.decode(body.padRight((body.length + 3) ~/ 4 * 4, '=')),
        ),
      );
    } on FormatException {
      throw const FormatException(
        'The preset is cut short or changed: copy it again.',
      );
    }
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Not a theme preset.');
    }
    final json = decoded;

    String? name(String key, List<String> allowed, String what) {
      final v = json[key];
      if (v == null) return null;
      if (v is! String || !allowed.contains(v)) {
        throw FormatException('The preset names no $what Ashlar UI has: $v.');
      }
      return v;
    }

    double? number(String key, double lo, double hi) {
      final v = json[key];
      if (v == null) return null;
      if (v is! num || v < lo || v > hi) {
        throw FormatException('The preset\'s $key is out of range: $v.');
      }
      return v.toDouble();
    }

    Map<String, int> colors(String key) {
      final v = json[key];
      if (v == null) return const {};
      if (v is! Map) {
        throw const FormatException('The preset\'s colours are not readable.');
      }
      final out = <String, int>{};
      for (final MapEntry(:key, :value) in v.entries) {
        if (!colorTokens.contains(key)) {
          throw FormatException(
            'The preset sets a colour Ashlar UI has no name for: $key.',
          );
        }
        if (value is! String || !RegExp(r'^[0-9a-f]{8}$').hasMatch(value)) {
          throw FormatException('The preset\'s $key is not a colour: $value.');
        }
        out[key as String] = int.parse(value, radix: 16);
      }
      return out;
    }

    final flat = json['f'];
    if (flat != null && flat is! bool) {
      throw const FormatException('The preset\'s shadows are not on or off.');
    }
    return ThemePreset(
      base: name('b', bases, 'base') ?? 'neutral',
      accent: name('a', accents, 'accent'),
      style: name('s', styles, 'style') ?? 'standard',
      radius: number('r', 0, 40),
      density: number('d', -4, 4),
      spacing: number('p', .5, 2),
      flat: flat as bool?,
      light: colors('l'),
      dark: colors('k'),
    );
  }

  /// This preset with the base, accent and style given changed: what `ashlar apply
  /// --base` does to a project with a preset. A null [accent] leaves it as it is; give
  /// [noAccent] to take it away.
  ThemePreset withChoices({
    String? base,
    String? accent,
    bool noAccent = false,
    String? style,
  }) => ThemePreset(
    base: base ?? this.base,
    accent: noAccent ? null : accent ?? this.accent,
    style: style ?? this.style,
    radius: radius,
    density: density,
    spacing: spacing,
    flat: flat,
    light: light,
    dark: dark,
  );

  /// The app_theme.dart `ashlar init` writes for this preset: the theme its choices make,
  /// light and dark, with its changes on them. The same text the themes page offers.
  String appThemeDart() {
    String num(double v) =>
        v == v.roundToDouble() ? v.toInt().toString() : '$v';
    String color(int c) =>
        'Color(0x${c.toRadixString(16).padLeft(8, '0').toUpperCase()})';
    String from(String brightness) =>
        'AshlarThemeData.from(\n'
        '  brightness: Brightness.$brightness,\n'
        '  base: AshlarBase.$base,\n'
        '${accent == null ? '' : '  accent: AshlarAccent.$accent,\n'}'
        '  style: AshlarStyle.$style,\n'
        ')';
    // With changes, the theme the choices make, then the changes on it.
    String theme(String name, String brightness, Map<String, int> colors) {
      if (!changed) return 'final $name = ${from(brightness)};';
      final choices = '_${brightness}Choices';
      return [
        'final $choices = ${from(brightness)};',
        '',
        'final $name = $choices.copyWith(',
        if (radius != null) '  radius: ${num(radius!)},',
        if (density != null) '  density: ${num(density!)},',
        if (spacing != null) '  spacing: ${num(spacing!)},',
        if (flat != null) '  flat: $flat,',
        if (colors.isNotEmpty) ...[
          '  colors: $choices.colors.copyWith(',
          for (final e in colors.entries) '    ${e.key}: ${color(e.value)},',
          '  ),',
        ],
        ');',
      ].join('\n');
    }

    return '''
// Your app's theme, written by `ashlar init`: change it here, or choose again with
// `ashlar apply`. Give it to [AshlarApp]: theme: appTheme, darkTheme: appDarkTheme.
${changed ? '// Made from the preset $code.\n' : ''}
import 'package:flutter/widgets.dart';

import 'palette.dart';
import 'theme.dart';

${theme('appTheme', 'light', light)}

${theme('appDarkTheme', 'dark', dark)}
''';
  }

  @override
  bool operator ==(Object other) => other is ThemePreset && other.code == code;

  @override
  int get hashCode => code.hashCode;
}
