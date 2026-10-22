// ashlar shot: the app's own screens drawn to pictures, without running the app, in its
// theme and fonts, at a phone's, a tablet's or a desktop's size, light or dark. And what
// Flutter complained of while drawing them: overflows and the like, with the line of the
// app's own code they came from. For a person, and for a coding agent that cannot see.
import 'dart:io';

import 'render.dart';

/// The sizes `--size` names, in logical pixels, and the platform each is drawn as.
const shotSizes = {
  'phone': (390.0, 844.0, 'iOS'),
  'tablet': (820.0, 1180.0, 'iOS'),
  'desktop': (1440.0, 900.0, 'macOS'),
};

/// One widget to draw: its file from the project root (under lib) and its class.
typedef ShotTarget = ({String file, String widget});

/// [given], `lib/screens/home.dart` or `lib/screens/home.dart:HomeScreen`, as a target: the
/// class named, or the first widget in the file that can be made with no arguments. A
/// string saying what is wrong when there is none.
Object resolveShot(Directory root, String given) {
  final at = given.lastIndexOf(':');
  final file = at > 1 ? given.substring(0, at) : given;
  final name = at > 1 ? given.substring(at + 1) : null;
  final f = File('${root.path}/$file');
  if (!file.startsWith('lib/') || !file.endsWith('.dart')) {
    return '$given: name a Dart file under lib, as lib/screens/home.dart.';
  }
  if (!f.existsSync()) return '$given: there is no $file.';
  final source = f.readAsStringSync();
  final widgets = [
    for (final m in RegExp(
      r'^class\s+([A-Z]\w*)\s+extends\s+(?:StatelessWidget|StatefulWidget)\b',
      multiLine: true,
    ).allMatches(source))
      m[1]!,
  ];
  // Made with no arguments: no required parameters in its constructor.
  bool plain(String w) {
    final ctor = RegExp(
      '(?:const\\s+)?$w\\s*\\(([^)]*)\\)',
    ).firstMatch(source.substring(source.indexOf('class $w')));
    return ctor == null || !ctor[1]!.contains('required');
  }

  if (name != null) {
    if (!widgets.contains(name)) {
      return '$given: $file has no widget named $name'
          '${widgets.isEmpty ? '' : '; it has ${widgets.join(', ')}'}.';
    }
    if (!plain(name)) {
      return '$given: $name takes arguments; draw a widget that makes it with them.';
    }
    return (file: file, widget: name);
  }
  final first = widgets.where(plain).firstOrNull;
  if (first == null) {
    return '$given: $file has no widget that can be made with no arguments; name one, as $file:HomeScreen.';
  }
  return (file: file, widget: first);
}

/// 'HomeScreen' as 'home-screen'.
String _kebab(String s) => s
    .replaceAllMapped(RegExp('(?<=[a-z0-9])([A-Z])'), (m) => '-${m[1]}')
    .toLowerCase();

/// Draws [targets] at each of [sizes] (names in [shotSizes], or `WIDTHxHEIGHT`), light,
/// dark or both, into [out] (from the root). [package] is the app's name, [path] the
/// folder its components are in; [named] gives a component's name under the app's
/// prefix. Writes what it drew and what Flutter complained of to [o]. 0 when every
/// picture was drawn clean, 1 when drawn with complaints, 2 when none could be drawn.
Future<int> drawShots({
  required Directory root,
  required String package,
  required String path,
  required List<ShotTarget> targets,
  required List<String> sizes,
  required List<bool> darks,
  required String out,
  required double scale,
  required bool center,
  required String Function(String) named,
  required StringSink o,
}) async {
  if (!path.startsWith('lib/')) {
    o.writeln(
      'The components are in $path, not under lib, where a test can import them from.',
    );
    return 2;
  }
  final work = Directory('${root.path}/.ashlar/shot');
  if (work.existsSync()) work.deleteSync(recursive: true);
  work.createSync(recursive: true);
  File('${work.path}/.gitignore').writeAsStringSync('*\n');
  final dest = Directory('${root.path}/$out')..createSync(recursive: true);
  if (out.startsWith('.ashlar/')) {
    File('${root.path}/.ashlar/.gitignore')
      ..createSync(recursive: true)
      ..writeAsStringSync('*\n');
  }

  final ui = 'package:$package/${path.substring(4)}';
  final hasTheme = File('${root.path}/$path/app_theme.dart').existsSync();
  final app = named('AshlarApp'),
      data = named('AshlarThemeData'),
      text = named('AshlarText'),
      mode = named('AshlarThemeMode');
  String theme(bool dark) {
    final chosen = hasTheme
        ? (dark ? 'chosen.appDarkTheme' : 'chosen.appTheme')
        : 'theme.$data.${dark ? 'dark' : 'light'}()';
    // Text in the app's own font, or Roboto where it names none: a test draws boxes else.
    return '$chosen.copyWith(text: $chosen.text.fontFamily == null ? const theme.$text(fontFamily: \'Roboto\') : $chosen.text)';
  }

  final h = StringBuffer()
    ..writeln('// Written by ashlar shot, and drawn again each time.')
    ..writeln("import 'dart:convert';")
    ..writeln("import 'dart:io';")
    ..writeln("import 'dart:ui' as ui;")
    ..writeln()
    ..writeln("import 'package:flutter/foundation.dart';")
    ..writeln("import 'package:flutter/rendering.dart';")
    ..writeln("import 'package:flutter/services.dart';")
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln("import 'package:flutter_test/flutter_test.dart';")
    ..writeln("import '$ui/app.dart' as app;")
    ..writeln("import '$ui/theme.dart' as theme;")
    ..writeln(hasTheme ? "import '$ui/app_theme.dart' as chosen;" : '');
  for (final (n, t) in targets.indexed) {
    h.writeln("import 'package:$package/${t.file.substring(4)}' as t$n;");
  }
  h
    ..writeln()
    ..writeln(fontsSource)
    ..writeln('''
/// Draws [child] filling a screen of [size], as [platform] draws it, to [file], saying
/// each thing Flutter complains of on its way.
Future<void> _draw(WidgetTester tester, String label, Size size, TargetPlatform platform, Widget child, String file) async {
  debugDefaultTargetPlatformOverride = platform;
  tester.view
    ..physicalSize = size * $scale
    ..devicePixelRatio = $scale;
  addTearDown(tester.view.reset);
  final told = FlutterError.onError;
  final complaints = <String>[];
  FlutterError.onError = (d) {
    // The first line, and where in the app's own code it came from: the widget Flutter
    // names as its cause (a layout fault), else the first line of the app in the stack.
    final text = d.toString();
    final cause = RegExp(r'file://\\S*?/(lib/[^\\s:]+\\.dart:\\d+)').firstMatch(text)?.group(1);
    final stacked = d.stack.toString().split('\\n').map((l) => RegExp(r'\\(package:$package/([^)]+?:\\d+)').firstMatch(l)?.group(1)).whereType<String>().firstOrNull;
    final where = cause ?? (stacked == null ? null : 'lib/\$stacked');
    complaints.add('\${d.exceptionAsString().split('\\n').first.trim()}\${where == null ? '' : ' (\$where)'}');
  };
  final key = GlobalKey();
  await tester.pumpWidget(RepaintBoundary(key: key, child: child));
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  final thrown = tester.takeException();
  if (thrown != null) complaints.add('\$thrown'.split('\\n').first);
  FlutterError.onError = told;
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: $scale);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  File(file).writeAsBytesSync(bytes!);
  // ignore: avoid_print
  print('ASHLAR_DREW \$file');
  for (final c in complaints.toSet()) {
    // ignore: avoid_print
    print('ASHLAR_COMPLAINT \$label: \$c');
  }
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 10));
  debugDefaultTargetPlatformOverride = null;
}

void main() {
  setUpAll(_fonts);''');
  final planned = <String>[];
  for (final (n, t) in targets.indexed) {
    for (final size in sizes) {
      final (w, hgt, platform) =
          shotSizes[size] ??
          () {
            final m = RegExp(r'^(\d+)x(\d+)$').firstMatch(size)!;
            final w = double.parse(m[1]!);
            return (w, double.parse(m[2]!), w < 1000 ? 'iOS' : 'macOS');
          }();
      for (final dark in darks) {
        final label = '${t.widget} $size ${dark ? 'dark' : 'light'}';
        final file =
            '${dest.path}/${_kebab(t.widget)}-$size-${dark ? 'dark' : 'light'}.png';
        planned.add(file);
        final body = center
            ? 'Center(child: Padding(padding: const EdgeInsets.all(24), child: t$n.${t.widget}()))'
            : 't$n.${t.widget}()';
        h.writeln('''
  testWidgets(${_quote(label)}, (tester) async {
    await _draw(
      tester,
      ${_quote(label)},
      const Size($w, $hgt),
      TargetPlatform.${platform == 'iOS' ? 'iOS' : 'macOS'},
      app.$app(
        theme: ${theme(false)},
        darkTheme: ${theme(true)},
        themeMode: app.$mode.${dark ? 'dark' : 'light'},
        home: $body,
      ),
      ${_quote(file)},
    );
  });''');
      }
    }
  }
  h.writeln('}');
  final test = File('${work.path}/shot_test.dart')
    ..writeAsStringSync(h.toString());
  final (flutter, fonts) = await flutterFor(root);
  final result = await runDrawing(
    root,
    flutter,
    fonts,
    test.path.substring(root.path.length + 1),
  );
  final lines = '${result.stdout}'.split('\n');
  final drawn = [
    for (final l in lines)
      if (l.startsWith('ASHLAR_DREW ')) l.substring(12).trim(),
  ];
  final complaints = [
    for (final l in lines)
      if (l.startsWith('ASHLAR_COMPLAINT ')) l.substring(17).trim(),
  ];
  String rel(String p) =>
      p.startsWith(root.path) ? p.substring(root.path.length + 1) : p;
  for (final d in drawn) {
    o.writeln('  drew   ${rel(d)}');
  }
  for (final c in complaints.toSet()) {
    o.writeln('  fault  $c');
  }
  if (drawn.isEmpty) {
    final why = '${result.stdout}${result.stderr}'
        .split('\n')
        .where((l) => l.contains('Error') || l.contains('error'))
        .take(4)
        .join('\n  ');
    o.writeln(
      'flutter test could not draw them${why.isEmpty ? '' : ':\n  $why'}',
    );
    return 2;
  }
  final missing = planned.where((p) => !drawn.contains(p)).length;
  if (missing > 0) o.writeln('  $missing more could not be drawn.');
  return complaints.isEmpty && missing == 0 ? 0 : 1;
}

String _quote(String s) =>
    "'${s.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll(r'$', r'\$')}'";
