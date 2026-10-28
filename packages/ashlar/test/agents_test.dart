import 'dart:io';

import 'package:ashlar/ashlar.dart';
import 'package:test/test.dart';

Directory project() {
  final dir = Directory.systemTemp.createTempSync('ashlar_agents_');
  addTearDown(() => dir.deleteSync(recursive: true));
  File('${dir.path}/pubspec.yaml').writeAsStringSync(
    'name: app\ndependencies:\n  flutter:\n    sdk: flutter\n  ashlar_icons: ^0.2.0\n',
  );
  return dir;
}

String read(Directory dir, String name) =>
    File('${dir.path}/$name').readAsStringSync();

void main() {
  test('init writes what coding agents should know into AGENTS.md', () async {
    final dir = project();
    expect(await run(['init'], dir: dir, out: StringBuffer()), 0);
    final agents = read(dir, 'AGENTS.md');
    expect(agents, contains('## Ashlar UI'));
    expect(agents, contains('copied into `lib/ui`'));
    expect(agents, contains('AshlarTheme.of(context)'));
    expect(agents, contains('ashlar shot'));
  });

  test(
    'a CLAUDE.md gets them too, its own words kept, and a second run replaces them',
    () async {
      final dir = project();
      File(
        '${dir.path}/CLAUDE.md',
      ).writeAsStringSync('# Our app\n\nUse tabs.\n');
      File('${dir.path}/AGENTS.md').writeAsStringSync('# Agents\n\nBe kind.\n');
      await run(['init', '--prefix', 'SL'], dir: dir, out: StringBuffer());
      final claude = read(dir, 'CLAUDE.md');
      expect(claude, startsWith('# Our app\n\nUse tabs.'));
      expect(claude, contains('SLButton'));
      expect(read(dir, 'AGENTS.md'), startsWith('# Agents\n\nBe kind.'));
      // A new prefix renames what the rules name, once.
      await run(['apply', '--prefix', 'Mz'], dir: dir, out: StringBuffer());
      final again = read(dir, 'AGENTS.md');
      expect(again, contains('MzButton'));
      expect(again, isNot(contains('SLButton')));
      expect('## Ashlar UI'.allMatches(again).length, 1);
    },
  );

  test('--no-agents leaves them out, and apply keeps to that', () async {
    final dir = project();
    await run(['init', '--no-agents'], dir: dir, out: StringBuffer());
    expect(File('${dir.path}/AGENTS.md').existsSync(), isFalse);
    await run(['apply', '--accent', 'blue'], dir: dir, out: StringBuffer());
    expect(File('${dir.path}/AGENTS.md').existsSync(), isFalse);
  });
}
