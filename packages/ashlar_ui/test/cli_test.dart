import 'dart:io';

import 'package:ashlar_ui/ashlar_ui.dart';
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
}
