import 'dart:io';

import 'dart:convert';

import 'package:ashlar_ui/ashlar_ui.dart';
import 'package:ashlar_ui/src/diff.dart';
import 'package:test/test.dart';

Directory project({Map<String, String>? config}) {
  final dir = Directory.systemTemp.createTempSync('ashlar_cli_');
  addTearDown(() => dir.deleteSync(recursive: true));
  File('${dir.path}/pubspec.yaml').writeAsStringSync(
    'name: app\ndependencies:\n  flutter:\n    sdk: flutter\n  ashlar_icons: ^0.2.0\n',
  );
  if (config != null) {
    File('${dir.path}/ashlar.json').writeAsStringSync(
      '{${config.entries.map((e) => '"${e.key}": "${e.value}"').join(', ')}}',
    );
  }
  return dir;
}

void main() {
  test(
    'a block goes beside the components and imports them from there',
    () async {
      final dir = project();
      final out = StringBuffer();
      expect(await run(['add', 'login-01'], dir: dir, out: out), 0);
      final block = File('${dir.path}/lib/blocks/login_01.dart');
      expect(block.existsSync(), isTrue);
      expect(block.readAsStringSync(), contains("import '../ui/form.dart';"));
      expect(File('${dir.path}/lib/ui/form.dart').existsSync(), isTrue);
      expect(
        File('${dir.path}/lib/ui/blocks/login_01.dart').existsSync(),
        isFalse,
      );
    },
  );

  test('with components elsewhere, the imports follow them', () async {
    final dir = project(config: {'path': 'lib/widgets/ui'});
    expect(await run(['add', 'login-01'], dir: dir, out: StringBuffer()), 0);
    final block = File('${dir.path}/lib/widgets/blocks/login_01.dart');
    expect(block.readAsStringSync(), contains("import '../ui/form.dart';"));
  });

  test('with blocks set apart, the imports find the components', () async {
    final dir = project(
      config: {'path': 'lib/ui', 'blocks': 'lib/screens/auth'},
    );
    expect(await run(['add', 'login-01'], dir: dir, out: StringBuffer()), 0);
    final block = File('${dir.path}/lib/screens/auth/login_01.dart');
    expect(block.readAsStringSync(), contains("import '../../ui/form.dart';"));
  });

  test('--all adds components only; --blocks adds the blocks', () async {
    final dir = project();
    expect(await run(['add', '--all'], dir: dir, out: StringBuffer()), 0);
    expect(Directory('${dir.path}/lib/blocks').existsSync(), isFalse);
    expect(await run(['add', '--blocks'], dir: dir, out: StringBuffer()), 0);
    final blocks = registry.entries.where((e) => e.value.block).length;
    expect(Directory('${dir.path}/lib/blocks').listSync().length, blocks);
  });

  test('list shows blocks apart from components', () async {
    final dir = project();
    final out = StringBuffer();
    await run(['list'], dir: dir, out: out);
    final text = out.toString();
    expect(
      text.indexOf('Blocks, whole screens:'),
      greaterThan(text.indexOf('  button ')),
    );
    expect(
      text.indexOf('login-01'),
      greaterThan(text.indexOf('Blocks, whole screens:')),
    );
  });

  test('init writes the chosen base, accent and style', () async {
    final dir = project();
    final out = StringBuffer();
    expect(
      await run(
        ['init', '--base', 'zinc', '--accent', 'blue', '--style', 'compact'],
        dir: dir,
        out: out,
      ),
      0,
    );
    final theme = File('${dir.path}/lib/ui/app_theme.dart').readAsStringSync();
    expect(theme, contains('base: AshlarBase.zinc'));
    expect(theme, contains('accent: AshlarAccent.blue'));
    expect(theme, contains('style: AshlarStyle.compact'));
    expect(theme, contains('brightness: Brightness.dark'));
    expect(File('${dir.path}/lib/ui/palette.dart').existsSync(), isTrue);
    expect(
      File('${dir.path}/ashlar.json').readAsStringSync(),
      contains('"accent": "blue"'),
    );
  });

  test(
    'init turns down a choice it does not know, and says what there is',
    () async {
      final dir = project();
      final out = StringBuffer();
      expect(
        await run(['init', '--accent', 'chartreuse'], dir: dir, out: out),
        64,
      );
      expect(out.toString(), contains('No accent named chartreuse'));
      expect(out.toString(), contains('violet'));
    },
  );

  test('view shows what an item is and its files, before adding it', () async {
    final dir = project();
    final out = StringBuffer();
    expect(await run(['view', 'date-picker'], dir: dir, out: out), 0);
    final text = out.toString();
    expect(text, contains('date-picker: '));
    expect(text, contains('needs '));
    expect(text, contains('── date_picker.dart'));
    expect(text, contains('class DatePicker'));
    expect(File('${dir.path}/lib/ui/date_picker.dart').existsSync(), isFalse);
  });

  test('search finds by words in names and descriptions, blocks too', () async {
    final out = StringBuffer();
    expect(await run(['search', 'sign', 'in'], dir: project(), out: out), 0);
    expect(out.toString(), contains('login-01'));
    expect(out.toString(), isNot(contains(' button ')));
    final none = StringBuffer();
    await run(['search', 'spaceship'], dir: project(), out: none);
    expect(none.toString(), contains('Nothing matches "spaceship"'));
  });

  test('diff tells your changes from newer versions', () async {
    final dir = project();
    await run(['add', 'badge'], dir: dir, out: StringBuffer());
    var out = StringBuffer();
    await run(['diff'], dir: dir, out: out);
    expect(out.toString(), contains('as this version writes them'));

    // You change it.
    final badge = File('${dir.path}/lib/ui/badge.dart');
    badge.writeAsStringSync(
      badge.readAsStringSync().replaceFirst(
        'class Badge',
        '// Ours.\nclass Badge',
      ),
    );
    out = StringBuffer();
    await run(['diff'], dir: dir, out: out);
    expect(out.toString(), contains('lib/ui/badge.dart: changed by you'));
    out = StringBuffer();
    await run(['diff', 'badge'], dir: dir, out: out);
    expect(out.toString(), contains('-// Ours.'));
    expect(out.toString(), contains('@@ '));

    // An older version wrote it, and you left it alone.
    final old = registry['badge']!.files['badge.dart']!.replaceFirst(
      'class Badge',
      '// Older.\nclass Badge',
    );
    badge.writeAsStringSync(old);
    final config =
        jsonDecode(File('${dir.path}/ashlar.json').readAsStringSync())
            as Map<String, dynamic>;
    (config['files'] as Map)['lib/ui/badge.dart'] = fingerprint(old);
    File('${dir.path}/ashlar.json').writeAsStringSync(jsonEncode(config));
    out = StringBuffer();
    await run(['diff'], dir: dir, out: out);
    expect(
      out.toString(),
      contains('newer here: ashlar add badge --overwrite takes it'),
    );
  });

  test('apply chooses the theme again and leaves components alone', () async {
    final dir = project();
    await run(['init', '--accent', 'blue'], dir: dir, out: StringBuffer());
    final theme = File('${dir.path}/lib/ui/theme.dart');
    theme.writeAsStringSync('${theme.readAsStringSync()}\n// Mine.\n');
    expect(
      await run(['apply', '--style', 'sharp'], dir: dir, out: StringBuffer()),
      0,
    );
    var app = File('${dir.path}/lib/ui/app_theme.dart').readAsStringSync();
    expect(app, contains('AshlarStyle.sharp'));
    expect(app, contains('AshlarAccent.blue'));
    expect(theme.readAsStringSync(), endsWith('// Mine.\n'));
    await run(['apply', '--accent', 'none'], dir: dir, out: StringBuffer());
    app = File('${dir.path}/lib/ui/app_theme.dart').readAsStringSync();
    expect(app, isNot(contains('accent:')));
    expect(app, contains('AshlarStyle.sharp'));
  });

  group('registries of your own', () {
    Directory withRegistry() {
      final dir = project();
      final src = Directory('${dir.path}/acme')..createSync();
      File(
        '${src.path}/brand_card.dart',
      ).writeAsStringSync("import 'card.dart';\n\nclass BrandCard {}\n");
      File('${src.path}/brand.dart').writeAsStringSync('class Brand {}\n');
      File('${src.path}/registry.json').writeAsStringSync(
        jsonEncode({
          'brand-card': {
            'description': 'A card with our mark.',
            'files': ['brand_card.dart'],
            'requires': ['card', 'brand'],
          },
          'brand': {
            'description': 'Our mark.',
            'files': ['brand.dart'],
          },
        }),
      );
      return dir;
    }

    test(
      'build makes the files; add takes an item and what it needs',
      () async {
        final dir = withRegistry();
        final out = StringBuffer();
        expect(
          await run(
            ['build', 'acme/registry.json', '--out', 'public/r'],
            dir: dir,
            out: out,
          ),
          0,
        );
        expect(
          File('${dir.path}/public/r/brand-card.json').existsSync(),
          isTrue,
        );
        File('${dir.path}/ashlar.json').writeAsStringSync(
          jsonEncode({
            'registries': {'@acme': 'public/r'},
          }),
        );
        final search = StringBuffer();
        await run(['search', '@acme'], dir: dir, out: search);
        expect(search.toString(), contains('@acme/brand-card'));
        expect(
          await run(['add', '@acme/brand-card'], dir: dir, out: StringBuffer()),
          0,
        );
        // Its own, its registry's, and Ashlar's.
        expect(File('${dir.path}/lib/ui/brand_card.dart').existsSync(), isTrue);
        expect(File('${dir.path}/lib/ui/brand.dart').existsSync(), isTrue);
        expect(File('${dir.path}/lib/ui/card.dart').existsSync(), isTrue);
      },
    );

    test('a registry on the web works the same', () async {
      final dir = withRegistry();
      await run(['build', 'acme/registry.json'], dir: dir, out: StringBuffer());
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(server.close);
      server.listen((request) {
        final f = File(
          '${dir.path}/public/r${request.uri.path.replaceFirst('/r', '')}',
        );
        request.response.statusCode = f.existsSync() ? 200 : 404;
        if (f.existsSync()) request.response.write(f.readAsStringSync());
        request.response.close();
      });
      File('${dir.path}/ashlar.json').writeAsStringSync(
        jsonEncode({
          'registries': {'@web': 'http://127.0.0.1:${server.port}/r'},
        }),
      );
      final out = StringBuffer();
      expect(await run(['view', '@web/brand'], dir: dir, out: out), 0);
      expect(out.toString(), contains('class Brand'));
      final missing = StringBuffer();
      expect(await run(['add', '@web/nothing'], dir: dir, out: missing), 64);
      expect(missing.toString(), contains('answered 404'));
    });

    test('a file that would land outside the project is refused', () async {
      final dir = project();
      final r = Directory('${dir.path}/r')..createSync();
      File('${r.path}/sneaky.json').writeAsStringSync(
        jsonEncode({
          'name': 'sneaky',
          'files': {'../../outside.dart': 'class Outside {}'},
        }),
      );
      File('${dir.path}/ashlar.json').writeAsStringSync(
        jsonEncode({
          'registries': {'@x': 'r'},
        }),
      );
      final out = StringBuffer();
      expect(await run(['add', '@x/sneaky'], dir: dir, out: out), 64);
      expect(out.toString(), contains('cannot be written'));
      expect(File('${dir.path}/../outside.dart').existsSync(), isFalse);
    });
  });

  test('a unified diff marks what went and what came, with context', () {
    final d = unifiedDiff('a\nb\nc\nd', 'a\nB\nc\nd\ne');
    expect(d, contains('-b'));
    expect(d, contains('+B'));
    expect(d, contains('+e'));
    expect(d, contains(' a'));
  });
}
