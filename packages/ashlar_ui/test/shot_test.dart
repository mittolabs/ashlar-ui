import 'dart:io';

import 'package:ashlar_ui/ashlar_ui.dart';
import 'package:ashlar_ui/src/shot.dart';
import 'package:test/test.dart';

Directory project() {
  final dir = Directory.systemTemp.createTempSync('ashlar_shot_');
  addTearDown(() => dir.deleteSync(recursive: true));
  File('${dir.path}/pubspec.yaml').writeAsStringSync(
    'name: app\ndependencies:\n  flutter:\n    sdk: flutter\n',
  );
  File('${dir.path}/lib/screens/home.dart')
    ..createSync(recursive: true)
    ..writeAsStringSync('''
import 'package:flutter/widgets.dart';

class Row extends StatelessWidget {
  const Row({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Text(label);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Row(label: 'Hi');
}

class Settings extends StatefulWidget {
  const Settings({super.key});
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) => const SizedBox();
}
''');
  return dir;
}

void main() {
  test('a file alone draws its first widget made with no arguments', () {
    final dir = project();
    expect(resolveShot(dir, 'lib/screens/home.dart'), (
      file: 'lib/screens/home.dart',
      widget: 'HomeScreen',
    ));
    expect(resolveShot(dir, 'lib/screens/home.dart:Settings'), (
      file: 'lib/screens/home.dart',
      widget: 'Settings',
    ));
  });

  test('what cannot be drawn says why, and what there is', () {
    final dir = project();
    expect(
      resolveShot(dir, 'lib/screens/home.dart:Row'),
      contains('takes arguments'),
    );
    expect(
      resolveShot(dir, 'lib/screens/home.dart:Nope'),
      contains('it has Row, HomeScreen, Settings'),
    );
    expect(
      resolveShot(dir, 'lib/screens/away.dart'),
      contains('there is no lib/screens/away.dart'),
    );
    expect(resolveShot(dir, 'test/home_test.dart'), contains('under lib'));
  });

  test('the command turns down what it cannot draw before drawing', () async {
    final dir = project();
    final out = StringBuffer();
    expect(await run(['shot'], dir: dir, out: out), 64);
    expect('$out', contains('Name what to draw'));
    out.clear();
    expect(
      await run(
        ['shot', 'lib/screens/home.dart', '--size', 'watch'],
        dir: dir,
        out: out,
      ),
      64,
    );
    expect('$out', contains('--size watch'));
    out.clear();
    expect(
      await run(['shot', 'lib/screens/home.dart:Row'], dir: dir, out: out),
      64,
    );
    expect('$out', contains('takes arguments'));
  });
}
