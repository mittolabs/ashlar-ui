// Components come with their tests, pointed at the project they are added to.
import 'dart:convert';
import 'dart:io';

import 'package:ashlar_ui/ashlar_ui.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

Directory project({String name = 'shop'}) {
  final dir = Directory.systemTemp.createTempSync('ashlar_tests_');
  addTearDown(() => dir.deleteSync(recursive: true));
  File('${dir.path}/pubspec.yaml').writeAsStringSync(
    'name: $name\ndependencies:\n  flutter:\n    sdk: flutter\n  ashlar_icons: ^0.2.0\n',
  );
  return dir;
}

/// Sets [values] in the project's ashlar.yaml, keeping what is there. JSON is YAML too.
void configure(Directory dir, Map<String, Object> values) {
  final file = File('${dir.path}/ashlar.yaml');
  final config = file.existsSync()
      ? jsonDecode(jsonEncode(loadYaml(file.readAsStringSync())))
            as Map<String, dynamic>
      : <String, dynamic>{};
  file.writeAsStringSync(jsonEncode({...config, ...values}));
}

Future<String> ashlar(Directory dir, List<String> args) async {
  final out = StringBuffer();
  await run(args, dir: dir, out: out);
  return '$out';
}

void main() {
  test(
    'a component comes with its tests, importing it from the project',
    () async {
      final dir = project();
      await ashlar(dir, ['init']);
      final said = await ashlar(dir, ['add', 'swipe-actions']);
      expect(said, contains('wrote  test/ashlar/swipe_actions_test.dart'));
      final test = File(
        '${dir.path}/test/ashlar/swipe_actions_test.dart',
      ).readAsStringSync();
      expect(test, contains("import 'package:shop/ui/swipe_actions.dart';"));
      expect(test, isNot(contains('ashlar_ui_gallery')));
    },
  );

  test('the import follows where the components are', () async {
    final dir = project();
    await ashlar(dir, ['init', '--path', 'lib/src/widgets/ui']);
    await ashlar(dir, ['add', 'swipe-actions']);
    expect(
      File(
        '${dir.path}/test/ashlar/swipe_actions_test.dart',
      ).readAsStringSync(),
      contains("import 'package:shop/src/widgets/ui/swipe_actions.dart';"),
    );
  });

  test('init sets where components, blocks and tests go', () async {
    final dir = project();
    final said = await ashlar(dir, [
      'init',
      '--path',
      'lib/widgets/ui/',
      '--blocks',
      'lib/screens',
      '--tests',
      'test/ui',
    ]);
    expect(
      said,
      contains(
        'components go in lib/widgets/ui, blocks in lib/screens, tests in test/ui',
      ),
    );
    final config = loadYaml(File('${dir.path}/ashlar.yaml').readAsStringSync());
    expect(config['path'], 'lib/widgets/ui');
    expect(config['blocks'], 'lib/screens');
    expect(config['tests'], 'test/ui');
    await ashlar(dir, ['add', 'login-01', 'swipe-actions']);
    expect(
      File('${dir.path}/lib/screens/login_01.dart').readAsStringSync(),
      contains("import '../widgets/ui/"),
    );
    expect(
      File('${dir.path}/test/ui/swipe_actions_test.dart').existsSync(),
      isTrue,
    );
    expect(Directory('${dir.path}/test/ashlar').existsSync(), isFalse);
  });

  test('init again keeps the folders it is not given', () async {
    final dir = project();
    await ashlar(dir, [
      'init',
      '--blocks',
      'lib/screens',
      '--tests',
      'test/ui',
    ]);
    await ashlar(dir, ['init', '--accent', 'blue']);
    final config = loadYaml(File('${dir.path}/ashlar.yaml').readAsStringSync());
    expect(config['blocks'], 'lib/screens');
    expect(config['tests'], 'test/ui');
  });

  test('init refuses a folder outside the project', () async {
    for (final bad in ['/tmp/ui', '../ui', 'lib/../../ui', '']) {
      final dir = project();
      final said = await ashlar(dir, ['init', '--tests', bad]);
      expect(said, contains('name a folder inside the project'));
      expect(File('${dir.path}/ashlar.yaml').existsSync(), isFalse);
    }
  });

  test('init says when flutter test will not find the tests', () async {
    final dir = project();
    expect(
      await ashlar(dir, ['init', '--tests', 'checks/ui']),
      contains('run these with flutter test checks/ui'),
    );
  });

  test('tests that use another component wait until it is added', () async {
    final dir = project();
    await ashlar(dir, ['init']);
    final tooltip = File('${dir.path}/test/ashlar/tooltip_test.dart');
    final said = await ashlar(dir, ['add', 'tooltip']);
    expect(
      said,
      contains('later  test/ashlar/tooltip_test.dart, once you have'),
    );
    expect(said, contains('button'));
    expect(tooltip.existsSync(), isFalse);
    await ashlar(dir, ['add', 'button']);
    expect(tooltip.existsSync(), isTrue);
  });

  test(
    'init brings the app shell\'s test, as add brings a component\'s',
    () async {
      final dir = project();
      await ashlar(dir, ['init']);
      expect(
        File('${dir.path}/test/ashlar/app_test.dart').existsSync(),
        isTrue,
      );
    },
  );

  test('--no-tests, or "tests": false, leaves them out', () async {
    final dir = project();
    await ashlar(dir, ['init', '--no-tests']);
    await ashlar(dir, ['add', 'swipe-actions', '--no-tests']);
    expect(Directory('${dir.path}/test').existsSync(), isFalse);
    configure(dir, {'tests': false});
    await ashlar(dir, ['add', 'bottom-bar']);
    expect(Directory('${dir.path}/test').existsSync(), isFalse);
  });

  test(
    'a test you deleted stays deleted, unless added again with --overwrite',
    () async {
      final dir = project();
      await ashlar(dir, ['init']);
      final test = File('${dir.path}/test/ashlar/bottom_bar_test.dart');
      await ashlar(dir, ['add', 'bottom-bar']);
      test.deleteSync();
      await ashlar(dir, ['add', 'swipe-actions']);
      await ashlar(dir, ['add', 'bottom-bar']);
      expect(test.existsSync(), isFalse);
      await ashlar(dir, ['add', 'bottom-bar', '--overwrite']);
      expect(test.existsSync(), isTrue);
    },
  );

  test('components outside lib get no tests, and say why', () async {
    final dir = project();
    await ashlar(dir, ['init', '--path', 'packages/ui']);
    final said = await ashlar(dir, ['add', 'bottom-bar']);
    expect(said, contains('no     test/ashlar/bottom_bar_test.dart'));
    expect(Directory('${dir.path}/test').existsSync(), isFalse);
  });

  test(
    'update merges your changes to a test; diff ignores one left out',
    () async {
      final dir = project();
      await ashlar(dir, ['init']);
      await ashlar(dir, ['add', 'bottom-bar']);
      const at = 'test/ashlar/bottom_bar_test.dart';
      final file = File('${dir.path}/$at');
      final latest = file.readAsStringSync();
      // An older version had another first line; you added a test at the end.
      final old = [
        '// An older first line.',
        ...latest.split('\n').skip(1),
      ].join('\n');
      File('${dir.path}/.ashlar/base/$at').writeAsStringSync(old);
      final files = File('${dir.path}/.ashlar/files.json');
      final written =
          jsonDecode(files.readAsStringSync()) as Map<String, dynamic>;
      written[at] = fingerprint(old);
      files.writeAsStringSync(jsonEncode(written));
      file.writeAsStringSync('$old\n// Mine.\n');

      final said = await ashlar(dir, ['update']);
      expect(said, contains('merged $at, your changes kept'));
      expect(file.readAsStringSync(), '$latest\n// Mine.\n');

      file.deleteSync();
      expect(await ashlar(dir, ['diff']), isNot(contains(at)));
    },
  );

  test('view says an item comes with tests, and what else they use', () async {
    final dir = project();
    await ashlar(dir, ['init']);
    expect(
      await ashlar(dir, ['view', 'tooltip']),
      contains('with its tests: tooltip_test.dart, which also use button'),
    );
  });
}
