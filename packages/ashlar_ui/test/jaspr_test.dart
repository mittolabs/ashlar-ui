import 'dart:io';

import 'package:ashlar_ui/ashlar_ui.dart';
import 'package:test/test.dart';

Directory project() {
  final dir = Directory.systemTemp.createTempSync('ashlar_jaspr_');
  addTearDown(() => dir.deleteSync(recursive: true));
  // universal_web is there already, so adding alert_dialog runs no pub command.
  File('${dir.path}/pubspec.yaml').writeAsStringSync(
    'name: site\ndependencies:\n  jaspr: ^0.23.4\n  universal_web: ^1.1.1\n',
  );
  return dir;
}

bool has(Directory dir, String path) => File('${dir.path}/$path').existsSync();

void main() {
  test('init in a Jaspr project writes the theme and ashlar.yaml', () async {
    final dir = project();
    final out = StringBuffer();
    expect(await run(['init'], dir: dir, out: out), 0);
    expect(has(dir, 'lib/ui/theme.dart'), isTrue);
    expect(File('${dir.path}/ashlar.yaml').readAsStringSync(), contains('path: lib/ui'));
    expect(has(dir, 'lib/ui/app.dart'), isFalse, reason: 'AshlarApp is Flutter');
    expect(File('${dir.path}/lib/ui/theme.dart').readAsStringSync(), contains("package:jaspr/dom.dart"));
  });

  test('add brings what an item needs, and keeps your files', () async {
    final dir = project();
    await run(['init', '--path', 'lib/components'], dir: dir, out: StringBuffer());
    expect(await run(['add', 'chart', 'alert_dialog'], dir: dir, out: StringBuffer()), 0);
    for (final f in ['chart', 'table', 'alert_dialog', 'button']) {
      expect(has(dir, 'lib/components/$f.dart'), isTrue, reason: f);
    }
    File('${dir.path}/lib/components/button.dart').writeAsStringSync('// mine');
    final out = StringBuffer();
    await run(['add', 'button'], dir: dir, out: out);
    expect(out.toString(), contains('kept'));
    expect(File('${dir.path}/lib/components/button.dart').readAsStringSync(), '// mine');
  });

  test('--overwrite replaces what you named, not what it needs', () async {
    final dir = project();
    await run(['init'], dir: dir, out: StringBuffer());
    await run(['add', 'alert_dialog'], dir: dir, out: StringBuffer());
    File('${dir.path}/lib/ui/theme.dart').writeAsStringSync('// my theme');
    File('${dir.path}/lib/ui/alert_dialog.dart').writeAsStringSync('// old');
    await run(['add', 'alert_dialog', '--overwrite'], dir: dir, out: StringBuffer());
    expect(File('${dir.path}/lib/ui/theme.dart').readAsStringSync(), '// my theme');
    expect(File('${dir.path}/lib/ui/alert_dialog.dart').readAsStringSync(), contains('class AlertDialog'));
  });

  test('a Flutter-only command says so', () async {
    final dir = project();
    final out = StringBuffer();
    expect(await run(['shot', 'lib/main.dart'], dir: dir, out: out), 64);
    expect(out.toString(), contains('Flutter projects so far'));
  });

  test('add before init, or of something unknown, is refused', () async {
    final dir = project();
    final out = StringBuffer();
    expect(await run(['add', 'button'], dir: dir, out: out), 64);
    expect(out.toString(), contains('ashlar init'));
    await run(['init'], dir: dir, out: StringBuffer());
    expect(await run(['add', 'calendar'], dir: dir, out: out), 64);
  });

  test('a Flutter project still gets the Flutter components', () async {
    final dir = Directory.systemTemp.createTempSync('ashlar_flutter_');
    addTearDown(() => dir.deleteSync(recursive: true));
    File('${dir.path}/pubspec.yaml').writeAsStringSync(
      'name: app\ndependencies:\n  flutter:\n    sdk: flutter\n  ashlar_icons: ^0.3.0\n',
    );
    expect(await run(['init', '--no-agents'], dir: dir, out: StringBuffer()), 0);
    expect(File('${dir.path}/lib/ui/theme.dart').readAsStringSync(), contains('package:flutter/widgets.dart'));
  });
}
