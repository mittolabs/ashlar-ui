// A project's own prefix on the components' names, as a design system marks its parts:
// SLButton, SLTheme, slShowToast. Chosen at ashlar init and applied to every file ashlar
// writes, so the components read as the project's own and never clash with Material's.

import 'check.dart' show codeOnly;

import 'registry.g.dart';

/// A prefix ashlar can use: a capital, then letters and digits, as SL or Mz.
final validPrefix = RegExp(r'^[A-Z][A-Za-z0-9]*$');

final _declared = RegExp(
  r'^(?:(?:abstract|sealed|final|base|interface|mixin)\s+)*(?:class|enum|mixin|typedef|extension\s+type|extension)\s+([A-Za-z]\w*)',
  multiLine: true,
);
final _topLevel = RegExp(
  r'^(?:(?:const|final|late|var)\s+)?(?:[A-Za-z_][\w<>?, .]*?\s+)?([a-zA-Z]\w*)\s*(?:<[^>]*>)?\s*(?:\(|=|;)',
);
final _notTopLevel = RegExp(
  r'^(?:import|export|part|library|class|enum|mixin|typedef|extension|abstract|sealed|base|interface|@|\s|\}|/)',
);

/// The public names the components declare (not the blocks, which are the app's own
/// screens), each with its name under [prefix].
Map<String, String> prefixedNames(String prefix) {
  final lower = prefix.toLowerCase();
  final names = <String>{};
  for (final c in registry.values.where((c) => !c.block)) {
    for (final source in c.files.values) {
      final code = codeOnly(source);
      for (final m in _declared.allMatches(code)) {
        names.add(m[1]!);
      }
      for (final line in code.split('\n')) {
        if (line.isEmpty || _notTopLevel.hasMatch(line)) continue;
        final m = _topLevel.firstMatch(line);
        if (m != null) names.add(m[1]!);
      }
    }
  }
  names.removeWhere((n) => n.startsWith('_') || n == 'on');
  return {
    for (final n in names)
      n: n.startsWith('Ashlar')
          ? '$prefix${n.substring(6)}'
          : n.startsWith('ashlar')
          ? '$lower${n.substring(6)}'
          : n.contains('Ashlar')
          ? n.replaceFirst('Ashlar', prefix)
          : n[0] == n[0].toUpperCase()
          ? '$prefix$n'
          : '$lower${n[0].toUpperCase()}${n.substring(1)}',
  };
}

/// [source] with each of [names] renamed: in its code, and in its comments where a name is
/// meant as code, in [brackets] or in a ``` example. Strings and prose are left alone.
String withPrefix(String source, Map<String, String> names) {
  if (names.isEmpty) return source;
  final sorted = names.keys.toList()..sort((a, b) => b.length - a.length);
  final word = RegExp('(?<![\\w\$.])(${sorted.join('|')})(?![\\w\$])');
  String rename(String s) => s.replaceAllMapped(word, (m) => names[m[1]]!);
  final out = StringBuffer();
  var inExample = false;
  for (final (start, end, kind) in _segments(source)) {
    final text = source.substring(start, end);
    switch (kind) {
      case _Kind.code:
        out.write(rename(text));
      case _Kind.string:
        // Text is left alone; what is interpolated into it is code.
        out.write(_inInterpolations(text, (code) => withPrefix(code, names)));
      case _Kind.comment:
        // A comment: every name in a ``` example, and names in brackets elsewhere.
        final body = text.replaceFirst(RegExp(r'^/+\s?'), '').trimLeft();
        if (body.startsWith('```')) {
          inExample = !inExample;
          out.write(text);
        } else if (inExample) {
          out.write(rename(text));
        } else {
          out.write(
            text.replaceAllMapped(
              RegExp(r'\[([^\]]+)\]'),
              (m) => '[${rename(m[1]!)}]',
            ),
          );
        }
    }
  }
  return out.toString();
}

enum _Kind { code, string, comment }

/// [source] cut into code, strings and comments, in order: each a start, an end and a kind.
/// A string's interpolations are part of the string.
List<(int, int, _Kind)> _segments(String source) {
  final out = <(int, int, _Kind)>[];
  final n = source.length;
  var i = 0, code = 0;
  void cut(int at, int end, _Kind kind) {
    if (code < at) out.add((code, at, _Kind.code));
    out.add((at, end, kind));
    code = end;
  }

  int stringEnd(int i) {
    final raw = source[i] == 'r';
    var j = raw ? i + 1 : i;
    final q = source[j];
    final close = source.startsWith(q * 3, j) ? q * 3 : q;
    j += close.length;
    var depth = 0;
    while (j < n) {
      if (!raw && source[j] == r'\') {
        j += 2;
        continue;
      }
      if (!raw && source.startsWith(r'${', j)) {
        depth++;
        j += 2;
        continue;
      }
      if (depth > 0) {
        if (source[j] == '}') depth--;
        j++;
        continue;
      }
      if (source.startsWith(close, j)) return j + close.length;
      j++;
    }
    return n;
  }

  while (i < n) {
    final c = source[i], d = i + 1 < n ? source[i + 1] : '';
    if (c == '/' && d == '/') {
      final e = source.indexOf('\n', i);
      final end = e < 0 ? n : e;
      cut(i, end, _Kind.comment);
      i = end;
    } else if (c == '/' && d == '*') {
      final e = source.indexOf('*/', i + 2);
      final end = e < 0 ? n : e + 2;
      cut(i, end, _Kind.comment);
      i = end;
    } else if (c == "'" ||
        c == '"' ||
        (c == 'r' &&
            (d == "'" || d == '"') &&
            (i == 0 || !RegExp(r'\w').hasMatch(source[i - 1])))) {
      final end = stringEnd(i);
      cut(i, end, _Kind.string);
      i = end;
    } else {
      i++;
    }
  }
  if (code < n) out.add((code, n, _Kind.code));
  return out;
}

/// [text], a string, with [rename] applied to what is inside each \${...} in it.
String _inInterpolations(String text, String Function(String) rename) {
  if (text.startsWith('r') || !text.contains(r'${')) return text;
  final out = StringBuffer();
  var i = 0;
  while (i < text.length) {
    final at = text.indexOf(r'${', i);
    if (at < 0 || (at > 0 && text[at - 1] == r'\')) {
      out.write(text.substring(i, at < 0 ? text.length : at + 2));
      if (at < 0) break;
      i = at + 2;
      continue;
    }
    out.write(text.substring(i, at + 2));
    var depth = 1, j = at + 2;
    while (j < text.length && depth > 0) {
      if (text[j] == '{') depth++;
      if (text[j] == '}') depth--;
      j++;
    }
    out.write(rename(text.substring(at + 2, j - 1)));
    out.write('}');
    i = j;
  }
  return out.toString();
}
