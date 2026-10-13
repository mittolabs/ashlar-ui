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
  final files = File('${dir.path}/.ashlar/files.json');
  final written = jsonDecode(files.readAsStringSync()) as Map<String, dynamic>;
  written[at] = fingerprint(old);
  files.writeAsStringSync(jsonEncode(written));
}

void main() {
  previewTests();
  formattedApp();
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
        final files = File('${dir.path}/.ashlar/files.json');
        final written =
            jsonDecode(files.readAsStringSync()) as Map<String, dynamic>;
        written[at] = fingerprint(old);
        files.writeAsStringSync(jsonEncode(written));
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

void formattedApp() {
  group('ashlar update in an app with its own layout', () {
    late Directory dir;
    late String old;
    const at = 'lib/ui/toggle.dart';

    // The app's code at 120 columns, as its formatter left it.
    String atWidth120(String text) {
      final f = File('${dir.path}/.layout/x.dart')
        ..createSync(recursive: true)
        ..writeAsStringSync(text);
      Process.runSync(
        'dart',
        ['format', f.path],
        workingDirectory: dir.path,
        runInShell: true,
      );
      final out = f.readAsStringSync();
      Directory('${dir.path}/.layout').deleteSync(recursive: true);
      return out;
    }

    setUp(() async {
      dir = project();
      File(
        '${dir.path}/analysis_options.yaml',
      ).writeAsStringSync('formatter:\n  page_width: 120\n');
      await run(['add', 'toggle'], dir: dir, out: StringBuffer());
      final latest = File('${dir.path}/$at').readAsStringSync();
      old = [
        '// An older first line.',
        ...latest.split('\n').skip(1),
      ].join('\n');
      olderVersion(dir, at, old);
    });

    test(
      'a file only laid out again takes the new version, in your layout',
      () async {
        File('${dir.path}/$at').writeAsStringSync(atWidth120(old));
        expect(
          File('${dir.path}/$at').readAsStringSync(),
          isNot(old),
          reason: 'the layout differs',
        );
        final out = StringBuffer();
        expect(await run(['update'], dir: dir, out: out), 0);
        expect(out.toString(), contains('took   $at'));
        final text = File('${dir.path}/$at').readAsStringSync();
        expect(text, isNot(contains('<<<<<<<')));
        expect(text, isNot(contains('An older first line')));
        expect(text, atWidth120(text), reason: 'still laid out at 120');
      },
    );

    test(
      'diff does not take a different layout for a change of yours',
      () async {
        final latest = registry['toggle']!.files['toggle.dart']!;
        File('${dir.path}/$at').writeAsStringSync(atWidth120(latest));
        File('${dir.path}/.ashlar/base/$at').writeAsStringSync(latest);
        final out = StringBuffer();
        await run(['diff', 'toggle'], dir: dir, out: out);
        expect(
          out.toString(),
          contains('Your copies are as this version writes them.'),
        );
      },
    );

    test(
      'a real change of yours is kept, with no conflicts from the layout',
      () async {
        File('${dir.path}/$at').writeAsStringSync(
          atWidth120(
            old,
          ).replaceFirst('class Toggle ', '// Ours.\nclass Toggle '),
        );
        final out = StringBuffer();
        expect(await run(['update'], dir: dir, out: out), 0);
        expect(out.toString(), contains('merged $at, your changes kept'));
        final text = File('${dir.path}/$at').readAsStringSync();
        expect(text, contains('// Ours.\nclass Toggle '));
        expect(text, isNot(contains('An older first line')));
        expect(text, isNot(contains('<<<<<<<')));
      },
    );
  });
}

void previewTests() {
  test(
    'update --preview changes nothing, and says when there is nothing to draw',
    () async {
      final dir = project();
      await run(['add', 'badge'], dir: dir, out: StringBuffer());
      final before = File('${dir.path}/lib/ui/badge.dart').readAsStringSync();
      final out = StringBuffer();
      await run(['update', '--preview'], dir: dir, out: out);
      expect(out.toString(), contains('Nothing to draw'));
      expect(File('${dir.path}/lib/ui/badge.dart').readAsStringSync(), before);
      expect(Directory('${dir.path}/.ashlar/review').existsSync(), isFalse);
    },
  );
}
