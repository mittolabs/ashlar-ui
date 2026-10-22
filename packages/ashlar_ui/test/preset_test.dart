import 'dart:convert';
import 'dart:io';

import 'package:ashlar_ui/ashlar_ui.dart';
import 'package:ashlar_ui/preset.dart';
import 'package:test/test.dart';

Directory project() {
  final dir = Directory.systemTemp.createTempSync('ashlar_preset_');
  addTearDown(() => dir.deleteSync(recursive: true));
  File('${dir.path}/pubspec.yaml').writeAsStringSync(
    'name: app\ndependencies:\n  flutter:\n    sdk: flutter\n  ashlar_icons: ^0.2.0\n',
  );
  return dir;
}

const custom = ThemePreset(
  base: 'zinc',
  accent: 'blue',
  style: 'rounded',
  radius: 12,
  spacing: 1.1,
  flat: true,
  light: {'primary': 0xFF2563EB, 'ring': 0xFF93C5FD},
  dark: {'primary': 0xFF60A5FA},
);

void main() {
  test('a preset reads back as it was written', () {
    expect(ThemePreset.parse(custom.code), custom);
    final back = ThemePreset.parse(custom.code);
    expect(back.light['primary'], 0xFF2563EB);
    expect(back.dark['primary'], 0xFF60A5FA);
    expect(back.radius, 12);
    expect(back.flat, isTrue);
    // A theme of choices alone is short, and has nothing changed.
    const plain = ThemePreset(accent: 'teal');
    expect(plain.changed, isFalse);
    expect(plain.code.length, lessThan(30));
    expect(ThemePreset.parse(plain.code).accent, 'teal');
  });

  test('a preset that is wrong says why', () {
    void says(String code, String words) => expect(
      () => ThemePreset.parse(code),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains(words),
        ),
      ),
    );
    says('zz123', 'starts with a1');
    says('${custom.code.substring(0, 20)}%', 'cut short');
    says(const ThemePreset().code.replaceFirst('a1', 'a1x'), 'cut short');
    // Made by hand: an accent there is not, and a colour with no name.
    String made(String json) => 'a1${base64UrlNoPad(json)}';
    says(made('{"a":"chartreuse"}'), 'no accent');
    says(made('{"l":{"brand":"ff000000"}}'), 'no name for: brand');
    says(made('{"l":{"primary":"red"}}'), 'not a colour');
    says(made('{"r":400}'), 'out of range');
  });

  test('init --preset writes the choices and the changes on them', () async {
    final dir = project();
    final out = StringBuffer();
    expect(
      await run(['init', '--preset', custom.code], dir: dir, out: out),
      0,
      reason: '$out',
    );
    final theme = File('${dir.path}/lib/ui/app_theme.dart').readAsStringSync();
    expect(theme, contains('base: AshlarBase.zinc'));
    expect(theme, contains('accent: AshlarAccent.blue'));
    expect(theme, contains('style: AshlarStyle.rounded'));
    expect(theme, contains('radius: 12,'));
    expect(theme, contains('flat: true,'));
    expect(theme, contains('primary: Color(0xFF2563EB),'));
    expect(theme, contains('primary: Color(0xFF60A5FA),'));
    expect(theme, contains('Made from the preset ${custom.code}'));
    expect(
      File('${dir.path}/ashlar.yaml').readAsStringSync(),
      contains('preset: ${custom.code}'),
    );
  });

  test(
    'apply keeps a preset, changes its choices, and drops it when asked',
    () async {
      final dir = project();
      await run(
        ['init', '--preset', custom.code],
        dir: dir,
        out: StringBuffer(),
      );
      expect(
        await run(
          ['apply', '--accent', 'green'],
          dir: dir,
          out: StringBuffer(),
        ),
        0,
      );
      var theme = File('${dir.path}/lib/ui/app_theme.dart').readAsStringSync();
      expect(theme, contains('accent: AshlarAccent.green'));
      expect(theme, contains('primary: Color(0xFF2563EB),'));
      expect(
        await run(['apply', '--preset', 'none'], dir: dir, out: StringBuffer()),
        0,
      );
      theme = File('${dir.path}/lib/ui/app_theme.dart').readAsStringSync();
      expect(theme, isNot(contains('copyWith')));
      expect(theme, contains('accent: AshlarAccent.green'));
      expect(
        File('${dir.path}/ashlar.yaml').readAsStringSync(),
        isNot(contains('preset:')),
      );
    },
  );

  test('a preset that is wrong stops init, saying why', () async {
    final dir = project();
    final out = StringBuffer();
    expect(await run(['init', '--preset', 'nope'], dir: dir, out: out), 64);
    expect('$out', contains('--preset: Not a theme preset'));
    expect(File('${dir.path}/lib/ui/app_theme.dart').existsSync(), isFalse);
  });
}

String base64UrlNoPad(String s) =>
    base64Url.encode(utf8.encode(s)).replaceAll('=', '');
