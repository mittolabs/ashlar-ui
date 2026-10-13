// A project's own prefix on the components' names: SLButton, SLTheme, slShowToast.
import 'dart:io';

import 'package:ashlar_ui/ashlar_ui.dart';
import 'package:ashlar_ui/src/check.dart';
import 'package:ashlar_ui/src/prefix.dart';
import 'package:test/test.dart';

Directory project() {
  final dir = Directory.systemTemp.createTempSync('ashlar_prefix_');
  addTearDown(() => dir.deleteSync(recursive: true));
  File('${dir.path}/pubspec.yaml').writeAsStringSync(
    'name: shop\ndependencies:\n  flutter:\n    sdk: flutter\n  ashlar_icons: ^0.2.0\n',
  );
  return dir;
}

Future<String> ashlar(Directory dir, List<String> args) async {
  final out = StringBuffer();
  await run(args, dir: dir, out: out);
  return '$out';
}

void main() {
  group('the names', () {
    final names = prefixedNames('SL');

    test('types take the prefix; Ashlar gives way to it', () {
      expect(names['Button'], 'SLButton');
      expect(names['ButtonVariant'], 'SLButtonVariant');
      expect(names['AshlarTheme'], 'SLTheme');
      expect(names['AshlarApp'], 'SLApp');
      expect(names['ClockTime'], 'SLClockTime');
    });

    test('functions take it in lower case', () {
      expect(names['showToast'], 'slShowToast');
      expect(names['ashlarColors'], 'slColors');
      expect(names['showAshlarDialog'], 'showSLDialog');
    });

    test('the blocks, the app\'s own screens, keep their names', () {
      expect(names.containsKey('Login01'), isFalse);
      expect(names.containsKey('on'), isFalse);
    });
  });

  group('renaming a source', () {
    const names = {'Button': 'SLButton', 'isRtl': 'slIsRtl'};

    test('code, interpolations, bracketed names and examples; never text', () {
      const source = '''
/// A [Button] that says Button, as a Button does.
///
/// ```dart
/// Button(onPressed: go)
/// ```
final b = Button(label: 'Button', hint: "\${isRtl(c) ? 'Button' : ''}");
final c = other.Button; // [Button] here too.
''';
      expect(withPrefix(source, names), '''
/// A [SLButton] that says Button, as a Button does.
///
/// ```dart
/// SLButton(onPressed: go)
/// ```
final b = SLButton(label: 'Button', hint: "\${slIsRtl(c) ? 'Button' : ''}");
final c = other.Button; // [SLButton] here too.
''');
    });

    test('a longer name is not taken for a shorter one', () {
      expect(
        withPrefix('ButtonGroup(); Button();', {
          'Button': 'SLButton',
          'ButtonGroup': 'SLButtonGroup',
        }),
        'SLButtonGroup(); SLButton();',
      );
    });
  });

  test('init --prefix writes every file, tests and theme with it', () async {
    final dir = project();
    expect(
      await ashlar(dir, ['init', '--prefix', 'SL']),
      contains('Give SLApp theme'),
    );
    await ashlar(dir, ['add', 'button']);
    expect(
      File('${dir.path}/ashlar.yaml').readAsStringSync(),
      contains('prefix: SL'),
    );
    expect(
      File('${dir.path}/lib/ui/button.dart').readAsStringSync(),
      contains('class SLButton '),
    );
    expect(
      File('${dir.path}/lib/ui/app_theme.dart').readAsStringSync(),
      contains('SLThemeData.from('),
    );
    expect(await ashlar(dir, ['view', 'button']), contains('class SLButton '));
    // Updated, the file stays as written: nothing to take.
    expect(
      await ashlar(dir, ['diff']),
      contains('Your copies are as this version writes them.'),
    );
  });

  test('a prefix that is not a name is refused', () async {
    final dir = project();
    expect(
      await ashlar(dir, ['init', '--prefix', 'sl']),
      contains('A prefix is a capital'),
    );
    expect(File('${dir.path}/ashlar.yaml').existsSync(), isFalse);
  });

  test('apply --prefix renames everywhere, your own code included', () async {
    final dir = project();
    await ashlar(dir, ['init']);
    await ashlar(dir, ['add', 'button']);
    final home = File('${dir.path}/lib/home.dart')
      ..writeAsStringSync(
        "final save = Button(onPressed: go, child: Text('Button'));\n",
      );
    expect(
      await ashlar(dir, ['apply', '--prefix', 'Mz']),
      contains('Prefix Mz'),
    );
    expect(
      home.readAsStringSync(),
      "final save = MzButton(onPressed: go, child: Text('Button'));\n",
    );
    expect(
      File('${dir.path}/lib/ui/button.dart').readAsStringSync(),
      contains('class MzButton '),
    );
    expect(
      File('${dir.path}/lib/ui/app_theme.dart').readAsStringSync(),
      contains('MzThemeData.from('),
    );
    // ashlar's copies follow, so diff and update still see nothing of yours changed.
    expect(
      await ashlar(dir, ['diff']),
      contains('Your copies are as this version writes them.'),
    );
    await ashlar(dir, ['apply', '--prefix', 'none']);
    expect(home.readAsStringSync(), contains('= Button('));
    expect(
      File('${dir.path}/ashlar.yaml').readAsStringSync(),
      isNot(contains('prefix')),
    );
  });

  test('check knows an icon-only button by its prefixed name', () {
    final found = checkSource(
      'lib/a.dart',
      'SLButton(onPressed: go, child: AshlarIcon(AshlarIconsRoundedStroke.trash));',
      button: 'SLButton',
    );
    expect(found.single.message, contains('A SLButton with only an icon'));
  });
}
