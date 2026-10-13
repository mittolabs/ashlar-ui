import 'dart:convert';
import 'dart:io';

import 'package:ashlar_ui/ashlar_ui.dart';
import 'package:ashlar_ui/src/merge.dart';
import 'package:test/test.dart';

Directory project() {
  final dir = Directory.systemTemp.createTempSync('ashlar_update_');
  addTearDown(() => dir.deleteSync(recursive: true));
  File('${dir.path}/pubspec.yaml').writeAsStringSync(
    'name: app\ndependencies:\n  flutter:\n    sdk: flutter\n  ashlar_icons: ^0.2.0\n',
  );
  return dir;
}

/// Makes the project look as an older ashlar left it: [old] written and kept as the base.
void olderVersion(Directory dir, String at, String old) {
  File('${dir.path}/$at').writeAsStringSync(old);
  File('${dir.path}/.ashlar/base/$at').writeAsStringSync(old);
  final config =
      jsonDecode(File('${dir.path}/ashlar.json').readAsStringSync())
          as Map<String, dynamic>;
  (config['files'] as Map)[at] = fingerprint(old);
  File('${dir.path}/ashlar.json').writeAsStringSync(jsonEncode(config));
}

void main() {
  group('merge3', () {
    test('changes to different lines both come through', () {
      final m = merge3('a\nb\nc\nd', 'A\nb\nc\nd', 'a\nb\nc\nD');
      expect(m.text, 'A\nb\nc\nD');
      expect(m.conflicts, 0);
    });

    test('the same change on both sides is taken once', () {
      final m = merge3('a\nb\nc', 'a\nB\nc', 'a\nB\nc');
      expect(m.text, 'a\nB\nc');
      expect(m.conflicts, 0);
    });

    test('different changes to the same line are both kept, marked', () {
      final m = merge3('a\nb\nc', 'a\nmine\nc', 'a\ntheirs\nc');
      expect(m.conflicts, 1);
      expect(
        m.text,
        'a\n<<<<<<< yours\nmine\n=======\ntheirs\n>>>>>>> ashlar\nc',
      );
    });

    test('lines added in different places both come through', () {
      final m = merge3('a\nb\nc', 'top\na\nb\nc', 'a\nb\nc\nbottom');
      expect(m.text, 'top\na\nb\nc\nbottom');
      expect(m.conflicts, 0);
    });

    test('different lines added at the same place are both kept, marked', () {
      final m = merge3('a\nb', 'a\nx\nb', 'a\ny\nb');
      expect(m.conflicts, 1);
    });

    test('a line one side deleted and the other left alone stays deleted', () {
      final m = merge3('a\nb\nc', 'a\nc', 'a\nb\nc\nd');
      expect(m.text, 'a\nc\nd');
    });
  });

  group('ashlar update', () {
    late Directory dir;
    late String latest, old;
    const at = 'lib/ui/badge.dart';

    setUp(() async {
      dir = project();
      await run(['add', 'badge'], dir: dir, out: StringBuffer());
      latest = File('${dir.path}/$at').readAsStringSync();
      // The older version: its first line said something else.
      final lines = latest.split('\n');
      old = ['// An older first line.', ...lines.skip(1)].join('\n');
    });

    test('add keeps a copy of what it wrote', () {
      expect(File('${dir.path}/.ashlar/base/$at').readAsStringSync(), latest);
    });

    test('a file you have not changed takes the new version', () async {
      olderVersion(dir, at, old);
      final out = StringBuffer();
      expect(await run(['update'], dir: dir, out: out), 0);
      expect(File('${dir.path}/$at').readAsStringSync(), latest);
      expect(out.toString(), contains('took   $at'));
      final again = StringBuffer();
      await run(['update'], dir: dir, out: again);
      expect(again.toString(), contains('Everything is up to date.'));
    });

    test('your change and the new version are merged', () async {
      olderVersion(dir, at, old);
      final yours = old.replaceFirst('class Badge', '// Ours.\nclass Badge');
      File('${dir.path}/$at').writeAsStringSync(yours);
      final out = StringBuffer();
      expect(await run(['update'], dir: dir, out: out), 0);
      final text = File('${dir.path}/$at').readAsStringSync();
      expect(text, latest.replaceFirst('class Badge', '// Ours.\nclass Badge'));
      expect(out.toString(), contains('your changes kept'));
      // Diff now sees your change and nothing newer.
      final diff = StringBuffer();
      await run(['diff'], dir: dir, out: diff);
      expect(diff.toString(), contains('$at: changed by you'));
      expect(diff.toString(), isNot(contains('newer')));
    });

    test(
      'where you changed what changed, both are kept to choose from',
      () async {
        olderVersion(dir, at, old);
        File('${dir.path}/$at').writeAsStringSync(
          ['// Our own first line.', ...old.split('\n').skip(1)].join('\n'),
        );
        final out = StringBuffer();
        expect(await run(['update'], dir: dir, out: out), 1);
        final text = File('${dir.path}/$at').readAsStringSync();
        expect(
          text,
          startsWith('<<<<<<< yours\n// Our own first line.\n=======\n'),
        );
        expect(out.toString(), contains('1 place to choose'));
      },
    );

    test('--dry-run says what it would do and writes nothing', () async {
      olderVersion(dir, at, old);
      final out = StringBuffer();
      await run(['update', '--dry-run'], dir: dir, out: out);
      expect(File('${dir.path}/$at').readAsStringSync(), old);
      expect(out.toString(), contains('Would update: 1 taken'));
    });

    test(
      'with no copy of what was written, your changed file is kept',
      () async {
        File('${dir.path}/.ashlar/base/$at').deleteSync();
        File('${dir.path}/$at').writeAsStringSync('// Mine alone.\n$old');
        final config =
            jsonDecode(File('${dir.path}/ashlar.json').readAsStringSync())
                as Map<String, dynamic>;
        (config['files'] as Map)[at] = fingerprint(old);
        File('${dir.path}/ashlar.json').writeAsStringSync(jsonEncode(config));
        final out = StringBuffer();
        await run(['update'], dir: dir, out: out);
        expect(
          File('${dir.path}/$at').readAsStringSync(),
          startsWith('// Mine alone.'),
        );
        expect(out.toString(), contains('no copy of what ashlar wrote'));
      },
    );
  });
}
