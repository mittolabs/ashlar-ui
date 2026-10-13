// ashlar check: what can be proved about an app's accessibility from its source and its
// theme. Each finding says where it is and what to do; nothing is reported that was not
// found, and what cannot be checked this way is said to be unchecked.

/// Something ashlar check found.
class Finding {
  const Finding(this.kind, this.at, this.message);

  /// Which check: labels, right to left, touch targets or contrast.
  final String kind;

  /// Where: path:line, or a theme's brightness for contrast.
  final String at;

  final String message;
}

/// [src] with its strings (interpolations in them too) and comments blanked to spaces,
/// lines kept, so code patterns can be looked for without matching text that is not code.
String codeOnly(String src) {
  final out = src.split('');
  final n = src.length;
  void blank(int from, int to) {
    for (var k = from; k < to && k < n; k++) {
      if (out[k] != '\n') out[k] = ' ';
    }
  }

  late int Function(int, bool) code;
  // The end of the string starting at [i], at its quote or at its r.
  int string(int i) {
    final raw = src[i] == 'r';
    var j = raw ? i + 1 : i;
    final q = src[j];
    final close = src.startsWith(q * 3, j) ? q * 3 : q;
    j += close.length;
    while (j < n) {
      if (!raw && src[j] == r'\') {
        j += 2;
        continue;
      }
      if (!raw && src.startsWith(r'${', j)) {
        j = code(j + 2, true);
        continue;
      }
      if (src.startsWith(close, j)) return j + close.length;
      j++;
    }
    return n;
  }

  // Walks code from [i]; in an interpolation, to just after its closing brace.
  code = (int i, bool interpolation) {
    var depth = 0;
    while (i < n) {
      final c = src[i], d = i + 1 < n ? src[i + 1] : '';
      if (c == '/' && d == '/') {
        final e = src.indexOf('\n', i);
        final end = e < 0 ? n : e;
        blank(i, end);
        i = end;
        continue;
      }
      if (c == '/' && d == '*') {
        final e = src.indexOf('*/', i + 2);
        final end = e < 0 ? n : e + 2;
        blank(i, end);
        i = end;
        continue;
      }
      final before = i > 0 ? src[i - 1] : ' ';
      if (c == "'" ||
          c == '"' ||
          (c == 'r' &&
              (d == "'" || d == '"') &&
              !RegExp(r'\w').hasMatch(before))) {
        final e = string(i);
        if (!interpolation) blank(i + 1, e - 1);
        i = e;
        continue;
      }
      if (interpolation) {
        if (c == '{') depth++;
        if (c == '}') {
          if (depth == 0) return i + 1;
          depth--;
        }
      }
      i++;
    }
    return n;
  };
  code(0, false);
  return out.join();
}

/// The index just past the bracket that closes the one at [open], in code [m].
int _closing(String m, int open) {
  var depth = 0;
  for (var j = open; j < m.length; j++) {
    final c = m[j];
    if (c == '(' || c == '[' || c == '{') depth++;
    if (c == ')' || c == ']' || c == '}') {
      depth--;
      if (depth == 0) return j + 1;
    }
  }
  return m.length;
}

/// A call's arguments, split at its top-level commas: name to value for named ones,
/// and the positional ones under '0', '1'...
Map<String, String> _arguments(String m, String src, int open, int close) {
  final args = <String, String>{};
  var depth = 0, start = open + 1, positional = 0;
  void take(int end) {
    final text = src.substring(start, end).trim();
    final code = m.substring(start, end).trim();
    if (code.isEmpty) return;
    final named = RegExp(r'^([A-Za-z_]\w*)\s*:(?!:)').firstMatch(code);
    if (named != null) {
      args[named[1]!] = text
          .substring(text.indexOf(':') + 1)
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');
    } else {
      args['${positional++}'] = text.replaceAll(RegExp(r'\s+'), ' ');
    }
  }

  for (var j = open + 1; j < close - 1; j++) {
    final c = m[j];
    if (c == '(' || c == '[' || c == '{') depth++;
    if (c == ')' || c == ']' || c == '}') depth--;
    if (c == ',' && depth == 0) {
      take(j);
      start = j + 1;
    }
  }
  take(close - 1);
  return args;
}

/// A value that follows a physical side, or the text direction.
final _followsASide = RegExp(
  r'left|right|rtl|ltr|TextDirection',
  caseSensitive: false,
);

const _directional = {
  'topLeft': 'topStart',
  'topRight': 'topEnd',
  'centerLeft': 'centerStart',
  'centerRight': 'centerEnd',
  'bottomLeft': 'bottomStart',
  'bottomRight': 'bottomEnd',
};

/// What can be proved from one Dart file's [src], at [path].
List<Finding> checkSource(String path, String src) {
  final m = codeOnly(src);
  final lines = src.split('\n');
  final found = <Finding>[];
  int lineOf(int at) => '\n'.allMatches(src.substring(0, at)).length + 1;
  // A line, or the line above it, can say a finding there is meant.
  // A file can say it means all of it, with its reason: charts drawn left to right.
  final whole = src.contains('// ashlar: ignore-file');
  bool ignored(int line) =>
      whole ||
      lines[line - 1].contains('ashlar: ignore') ||
      (line > 1 && lines[line - 2].trim() == '// ashlar: ignore');
  void add(String kind, int at, String message) {
    final line = lineOf(at);
    if (!ignored(line)) found.add(Finding(kind, '$path:$line', message));
  }

  // Calls, by the name they are made with.
  final calls = RegExp(
    r'(?<![\w.$])(EdgeInsets\.only|EdgeInsets\.fromLTRB|BorderRadius\.only|Positioned|Border|Button|Toggle)\s*\(',
  );
  for (final call in calls.allMatches(m)) {
    final open = call.end - 1;
    final close = _closing(m, open);
    final inner = m.substring(open + 1, close - 1).trim();
    // A constructor being declared, not called.
    if (inner.startsWith('{') ||
        inner.contains('this.') ||
        inner.contains('super.')) {
      continue;
    }
    final a = _arguments(m, src, open, close);
    // Both sides given alike is the same either way round.
    // Both sides given alike is the same either way round; and sides that follow a
    // physical left or right, or the text direction, were chosen as they are.
    bool lopsided(String left, String right) =>
        (a.containsKey(left) || a.containsKey(right)) &&
        a[left] != a[right] &&
        ![a[left], a[right]].nonNulls.every(_followsASide.hasMatch);
    switch (call[1]) {
      case 'EdgeInsets.only' when lopsided('left', 'right'):
        add(
          'right to left',
          call.start,
          'EdgeInsets.only(left/right) stays put in a right-to-left language: use EdgeInsetsDirectional.only(start: …, end: …).',
        );
      case 'EdgeInsets.fromLTRB' when a['0'] != a['2']:
        add(
          'right to left',
          call.start,
          'EdgeInsets.fromLTRB stays put in a right-to-left language: use EdgeInsetsDirectional.fromSTEB.',
        );
      case 'Positioned' when lopsided('left', 'right'):
        add(
          'right to left',
          call.start,
          'Positioned(left/right) stays put in a right-to-left language: use PositionedDirectional(start: …, end: …).',
        );
      case 'Border' when lopsided('left', 'right'):
        add(
          'right to left',
          call.start,
          'Border(left/right) stays put in a right-to-left language: use BorderDirectional(start: …, end: …).',
        );
      case 'BorderRadius.only'
          when lopsided('topLeft', 'topRight') ||
              lopsided('bottomLeft', 'bottomRight'):
        add(
          'right to left',
          call.start,
          'BorderRadius.only rounds the same corners in a right-to-left language: use BorderRadiusDirectional.only(topStart: …).',
        );
      case 'Button' || 'Toggle'
          when !a.containsKey('semanticLabel') &&
              (RegExp(
                    r'^(const\s+)?(AshlarIcon|Icon)\s*\(',
                  ).hasMatch(a['child'] ?? '') ||
                  (a['size'] ?? '').contains('icon')):
        add(
          'labels',
          call.start,
          'A ${call[1]} with only an icon has no semanticLabel: a screen reader says only "${call[1] == 'Button' ? 'button' : 'toggle button'}". Give it semanticLabel: \'…\'.',
        );
    }
  }
  for (final x in RegExp(
    r'(?<![\w.$])Alignment\.(topLeft|topRight|centerLeft|centerRight|bottomLeft|bottomRight)\b',
  ).allMatches(m)) {
    // In a choice over sides named left and right, left is what was asked for.
    final line = m.split('\n')[lineOf(x.start) - 1];
    if (RegExp(r'(?:left|Left|right|Right)\s*(?:=>|\?|==)').hasMatch(line)) {
      continue;
    }
    add(
      'right to left',
      x.start,
      'Alignment.${x[1]} stays put in a right-to-left language: use AlignmentDirectional.${_directional[x[1]]}.',
    );
  }
  for (final x in RegExp(
    r'(?<![\w.$])TextAlign\.(left|right)\b',
  ).allMatches(m)) {
    add(
      'right to left',
      x.start,
      'TextAlign.${x[1]} stays put in a right-to-left language: use TextAlign.${x[1] == 'left' ? 'start' : 'end'}.',
    );
  }
  for (final x in RegExp(r'\btapTarget\s*:\s*0(\.0)?\b').allMatches(m)) {
    add(
      'touch targets',
      x.start,
      'tapTarget: 0 turns off the room around controls for a finger: on a phone they are only as big as drawn. Leave it out for 44 on iOS and 48 on Android.',
    );
  }
  return found;
}

/// The colour pairs ashlar check measures: what is read, on what, and the ratio it
/// needs under WCAG 2.2 AA.
const contrastPairs = [
  ('text on the page', 'foreground', 'background', 4.5, '1.4.3'),
  ('muted text on the page', 'mutedForeground', 'background', 4.5, '1.4.3'),
  ('muted text on muted panels', 'mutedForeground', 'muted', 4.5, '1.4.3'),
  ('card text', 'cardForeground', 'card', 4.5, '1.4.3'),
  ('popover and menu text', 'popoverForeground', 'popover', 4.5, '1.4.3'),
  ('primary button text', 'primaryForeground', 'primary', 4.5, '1.4.3'),
  ('secondary button text', 'secondaryForeground', 'secondary', 4.5, '1.4.3'),
  ('highlighted item text', 'accentForeground', 'accent', 4.5, '1.4.3'),
  (
    'destructive button text',
    'destructiveForeground',
    'destructive',
    4.5,
    '1.4.3',
  ),
  ('error text on the page', 'destructive', 'background', 4.5, '1.4.3'),
  ('sidebar text', 'sidebarForeground', 'sidebar', 4.5, '1.4.3'),
  (
    'sidebar primary text',
    'sidebarPrimaryForeground',
    'sidebarPrimary',
    4.5,
    '1.4.3',
  ),
  ('focus ring on the page', 'ring', 'background', 3.0, '1.4.11'),
  ('field border on the page', 'input', 'background', 3.0, '1.4.11'),
];

/// A flutter test that measures [contrastPairs] in the app's own theme, importing it
/// from [ui] (package:app/ui), and prints a line for each.
String contrastHarness(String ui) {
  final pairs = contrastPairs
      .map((p) => "    ('${p.$1}', c.${p.$2}, c.${p.$3}, ${p.$4}, '${p.$5}'),")
      .join('\n');
  return '''
// Written by ashlar check to measure your theme's contrast, and deleted after.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import '$ui/app_theme.dart';
import '$ui/theme.dart';

double _luminance(Color c) {
  double channel(double v) => v <= 0.04045
      ? v / 12.92
      : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

// A see-through colour is measured as it shows, over what it is on.
double _ratio(Color top, Color under) {
  final bottom = under.withValues(alpha: 1);
  final a = _luminance(Color.alphaBlend(top, bottom)), b = _luminance(bottom);
  return (math.max(a, b) + .05) / (math.min(a, b) + .05);
}

void main() {
  test('contrast', () {
    for (final (mode, theme) in [('light', appTheme), ('dark', appDarkTheme)]) {
      final c = theme.colors;
      for (final (what, top, under, need, rule) in [
$pairs
      ]) {
        // ignore: avoid_print
        print('ASHLAR\\t\$mode\\t\$what\\t\${_ratio(top, under).toStringAsFixed(2)}\\t\$need\\t\$rule');
      }
    }
  });
}
''';
}

/// The contrast findings in what [contrastHarness] printed.
List<Finding> contrastFindings(String output) => [
  for (final line in output.split('\n'))
    if (line.startsWith('ASHLAR\t'))
      if (line.split('\t') case [
        _,
        final mode,
        final what,
        final r,
        final need,
        final rule,
      ] when double.parse(r) < double.parse(need))
        Finding(
          'contrast',
          mode,
          '$what is $r:1; WCAG $rule needs ${double.parse(need) == 3 ? '3' : need}:1.',
        ),
];
