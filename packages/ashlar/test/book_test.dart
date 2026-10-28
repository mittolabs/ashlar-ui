// ashlar book: a catalog of the app's own components, written outside its code.
import 'dart:io';

import 'package:ashlar/ashlar.dart';
import 'package:test/test.dart';

Directory project() {
  final dir = Directory.systemTemp.createTempSync('ashlar_book_');
  addTearDown(() => dir.deleteSync(recursive: true));
  File('${dir.path}/pubspec.yaml').writeAsStringSync(
    'name: shop\ndependencies:\n  flutter:\n    sdk: flutter\n  ashlar_icons: ^0.2.0\n',
  );
  return dir;
}

void main() {
  test(
    'it lists the components the app has, importing them from the app',
    () async {
      final dir = project();
      await run(['init', '--prefix', 'SL'], dir: dir, out: StringBuffer());
      await run(['add', 'button', 'badge'], dir: dir, out: StringBuffer());
      final out = StringBuffer();
      expect(await run(['book'], dir: dir, out: out), 0);
      expect(
        out.toString(),
        contains('Run it: flutter run -t .ashlar/book/main.dart'),
      );
      final main = File(
        '${dir.path}/.ashlar/book/main.dart',
      ).readAsStringSync();
      expect(main, contains("import 'package:shop/ui/app.dart';"));
      expect(main, contains("('Button', () => const p"));
      expect(main, contains("('Badge', () => const p"));
      expect(main, isNot(contains("('Dialog'")));
      expect(main, contains('SLApp('));
      final page = File(
        '${dir.path}/.ashlar/book/pages/button.dart',
      ).readAsStringSync();
      expect(page, contains("import 'package:shop/ui/button.dart';"));
      expect(page, contains('SLButton('));
      // Drawn again each time, so never committed.
      expect(
        File('${dir.path}/.ashlar/book/.gitignore').readAsStringSync(),
        '*\n',
      );
    },
  );

  test('with no components, it says so', () async {
    final dir = project();
    final out = StringBuffer();
    expect(await run(['book'], dir: dir, out: out), 64);
    expect(out.toString(), contains('No catalog'));
  });
}
