// ashlar update --preview: each component an update would change, drawn in the app's own
// theme as it is and as it would be, side by side on a page in .ashlar/review. Nothing in
// the app changes: the would-be files are written beside the review, never into lib.
import 'dart:convert';
import 'dart:io';

/// One component to draw: its name, the widget in its preview, and the preview's source
/// (importing the gallery's ui folder, as the registry keeps it).
typedef ReviewItem = ({String name, String widget, String preview});

/// Draws [items] before and after, in the app at [root] whose components are in [path]
/// (under lib), [after] holding the would-be text of each changed file by its path from
/// the root. [named] gives a component name as the app has it, under its prefix; [rename]
/// does the same to a source. Returns the page's path, or why it could not be drawn.
Future<({String? page, String? why})> drawReview({
  required Directory root,
  required String path,
  required Map<String, String> after,
  required List<ReviewItem> items,
  required String Function(String) named,
  required String Function(String) rename,
}) async {
  if (!path.startsWith('lib/')) {
    return (
      page: null,
      why:
          'the components are not under lib, where a test can import them from',
    );
  }
  final dir = Directory('${root.path}/.ashlar/review');
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  dir.createSync(recursive: true);
  // Never committed: it is drawn again each time.
  File('${dir.path}/.gitignore').writeAsStringSync('*\n');

  // The components as they would be: a copy of the folder, with the changed files merged.
  final ui = Directory('${root.path}/$path');
  for (final f in ui.listSync(recursive: true).whereType<File>()) {
    if (!f.path.endsWith('.dart')) continue;
    final rel = f.path.substring(ui.path.length + 1);
    File('${dir.path}/after/ui/$rel')
      ..createSync(recursive: true)
      ..writeAsStringSync(after['$path/$rel'] ?? f.readAsStringSync());
  }
  // Each preview twice: importing the components as they are, and as they would be.
  final up = '../../../$path';
  for (final i in items) {
    final source = rename(i.preview);
    File('${dir.path}/before/${i.name}.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync(
        source.replaceAll('package:ashlar_ui_gallery/ui/', '$up/'),
      );
    File('${dir.path}/after/previews/${i.name}.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync(
        source.replaceAll('package:ashlar_ui_gallery/ui/', '../ui/'),
      );
  }
  final hasTheme = File('${root.path}/$path/app_theme.dart').existsSync();
  final app = named('AshlarApp'),
      data = named('AshlarThemeData'),
      text = named('AshlarText');
  String sideImports(String as, String ui) =>
      '''
import '$ui/app.dart' as ${as}App;
import '$ui/theme.dart' as ${as}Theme;
${hasTheme ? "import '$ui/app_theme.dart' as ${as}Chosen;" : ''}''';
  final harness = StringBuffer()
    ..writeln(
      '// Written by ashlar update --preview, and drawn again each time.',
    )
    ..writeln("import 'dart:convert';")
    ..writeln("import 'dart:io';")
    ..writeln("import 'dart:ui' as ui;")
    ..writeln()
    ..writeln("import 'package:flutter/rendering.dart';")
    ..writeln("import 'package:flutter/services.dart';")
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln("import 'package:flutter_test/flutter_test.dart';")
    ..writeln(sideImports('before', '../../$path'))
    ..writeln(sideImports('after', 'after/ui'));
  for (final (n, i) in items.indexed) {
    harness
      ..writeln("import 'before/${i.name}.dart' as b$n;")
      ..writeln("import 'after/previews/${i.name}.dart' as a$n;");
  }
  String theme(String as) {
    final chosen = hasTheme
        ? '${as}Chosen.appTheme'
        : '${as}Theme.$data.light()';
    // Text in the app's own font, or Roboto where it names none: a test draws boxes else.
    return '$chosen.copyWith(text: $chosen.text.fontFamily == null ? const ${as}Theme.$text(fontFamily: \'Roboto\') : $chosen.text)';
  }

  harness.writeln('''

/// The app's fonts, and Roboto from Flutter itself for text that names none.
Future<void> _fonts() async {
  final manifest = jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(family['family'] as String);
    for (final font in (family['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
  final roboto = FontLoader('Roboto');
  for (final w in ['Regular', 'Medium', 'Bold']) {
    final f = File('\${const String.fromEnvironment('FONTS')}/Roboto-\$w.ttf');
    if (f.existsSync()) roboto.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
  }
  await roboto.load();
}

Future<void> _draw(WidgetTester tester, Widget app, String file) async {
  tester.view
    ..physicalSize = const Size(888, 592) * 2
    ..devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final key = GlobalKey();
  await tester.pumpWidget(RepaintBoundary(key: key, child: app));
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  tester.takeException();
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  File(file).writeAsBytesSync(bytes!);
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 10));
}

void main() {
  setUpAll(_fonts);''');
  for (final (n, i) in items.indexed) {
    for (final (side, prefix, label) in [
      ('before', 'b', 'before'),
      ('after', 'a', 'after'),
    ]) {
      harness.writeln('''
  testWidgets('${i.name} $label', (tester) async {
    await _draw(
      tester,
      ${side}App.$app(
        theme: ${theme(side)},
        home: Center(child: Padding(padding: const EdgeInsets.all(24), child: $prefix$n.${i.widget}())),
      ),
      '${dir.path}/${i.name}-$label.png',
    );
  });''');
    }
  }
  harness.writeln('}');
  final test = File('${dir.path}/review_test.dart')
    ..writeAsStringSync(harness.toString());

  final fvm = File('${root.path}/.fvmrc').existsSync();
  final flutter = [if (fvm) 'fvm', 'flutter'];
  // Flutter's own Roboto, where Flutter keeps it.
  String fonts = '';
  try {
    final v = await Process.run(
      flutter.first,
      [...flutter.skip(1), '--version', '--machine'],
      workingDirectory: root.path,
      runInShell: true,
    );
    final flutterRoot =
        (jsonDecode('${v.stdout}'.substring('${v.stdout}'.indexOf('{')))
            as Map)['flutterRoot'];
    fonts = '$flutterRoot/bin/cache/artifacts/material_fonts';
  } on Object {
    // Without it, text in the pictures is drawn in Flutter's test font, as boxes.
  }
  final result = await Process.run(
    flutter.first,
    [
      ...flutter.skip(1),
      'test',
      '--dart-define=FONTS=$fonts',
      test.path.substring(root.path.length + 1),
    ],
    workingDirectory: root.path,
    runInShell: true,
  );
  final drawn = items
      .where((i) => File('${dir.path}/${i.name}-after.png').existsSync())
      .toList();
  if (drawn.isEmpty) {
    final why = '${result.stdout}${result.stderr}'
        .split('\n')
        .where((l) => l.contains('Error') || l.contains('error:'))
        .take(3)
        .join(' ');
    return (
      page: null,
      why: 'flutter test could not draw them${why.isEmpty ? '' : ': $why'}',
    );
  }
  final page = File('${dir.path}/index.html')
    ..writeAsStringSync('''<!doctype html>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>What the update changes</title>
<style>
  body { font: 15px/1.5 system-ui, sans-serif; margin: 32px; color: #171717; background: #fff; }
  h1 { font-size: 22px; } h2 { font-size: 16px; margin: 32px 0 8px; }
  .pair { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
  figure { margin: 0; } img { width: 100%; border: 1px solid #e5e5e5; border-radius: 10px; }
  figcaption { font-size: 13px; color: #737373; margin-top: 4px; }
</style>
<h1>What the update changes</h1>
<p>Each component the update would change, in your theme: as it is, and as it would be. Nothing has changed yet; <code>ashlar update</code> takes it.</p>
${drawn.map((i) => '<h2>${i.name}</h2><div class="pair"><figure><img src="${i.name}-before.png" alt="${i.name} as it is"><figcaption>As it is</figcaption></figure><figure><img src="${i.name}-after.png" alt="${i.name} after the update"><figcaption>After the update</figcaption></figure></div>').join('\n')}
''');
  return (page: page.path.substring(root.path.length + 1), why: null);
}
