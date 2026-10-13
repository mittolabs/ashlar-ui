// ashlar check reports what it can prove, and nothing that only looks like it.
import 'dart:io';

import 'package:ashlar_ui/ashlar_ui.dart';
import 'package:ashlar_ui/src/check.dart';
import 'package:test/test.dart';

List<String> found(String src) => [
  for (final f in checkSource('lib/a.dart', src))
    '${f.kind} ${f.at.split(':').last}',
];

void main() {
  group('codeOnly', () {
    test(
      'blanks strings and comments, interpolations in them too, keeping lines',
      () {
        const src = "a('x(') // y(\nb(\"\${c(1)}\") /* d( */ e(r'\\')";
        final m = codeOnly(src);
        expect(m.length, src.length);
        expect(m.split('\n'), hasLength(2));
        expect('('.allMatches(m).length, 3);
      },
    );
  });

  group('labels', () {
    test('an icon-only Button or Toggle without a semanticLabel', () {
      expect(
        found('''
Button(onPressed: go, child: AshlarIcon(AshlarIconsRoundedStroke.trash));
Toggle(pressed: b, onChanged: f, child: const Icon(x));
Button(size: ButtonSize.icon, onPressed: go, child: glyph);
'''),
        ['labels 1', 'labels 2', 'labels 3'],
      );
    });

    test('not with a label, with words, or where a Button is declared', () {
      expect(
        found('''
Button(semanticLabel: 'Delete', onPressed: go, child: AshlarIcon(trash));
Button(onPressed: go, child: const Text('Save'));
IconButton(onPressed: go, icon: Icon(x));
const Button({super.key, required this.child});
'''),
        isEmpty,
      );
    });
  });

  group('right to left', () {
    test('physical sides where start and end belong', () {
      expect(
        found('''
EdgeInsets.only(left: 16);
EdgeInsets.fromLTRB(16, 0, 8, 0);
Positioned(right: 0, child: c);
Border(left: side);
BorderRadius.only(topLeft: r);
Alignment.centerRight;
TextAlign.left;
'''),
        [
          'right to left 1',
          'right to left 2',
          'right to left 3',
          'right to left 4',
          'right to left 5',
          'right to left 6',
          'right to left 7',
        ],
      );
    });

    test('not when both sides are alike, or follow a physical side', () {
      expect(
        found('''
EdgeInsets.only(left: 8, right: 8, top: 4);
EdgeInsets.fromLTRB(16, 0, 16, 0);
Positioned(left: 16 + padding.left, right: 16 + padding.right, child: c);
Border(left: side == SheetSide.right ? edge : none, right: side == SheetSide.left ? edge : none);
Border(left: rtl ? side : lead, right: rtl ? lead : side);
final a = switch (side) { DrawerSide.left => Alignment.centerLeft, _ => Alignment.center };
EdgeInsetsDirectional.only(start: 16);
'''),
        isEmpty,
      );
    });

    test('not in strings, comments, or lines that say they mean it', () {
      expect(
        found('''
Text('EdgeInsets.only(left: 1)');
// Alignment.topLeft
Align(alignment: Alignment.topLeft); // ashlar: ignore
// ashlar: ignore
TextAlign.right;
'''),
        isEmpty,
      );
    });

    test('nor in a file that says it means all of it', () {
      expect(
        found('// ashlar: ignore-file. Drawn left to right.\nTextAlign.left;'),
        isEmpty,
      );
    });
  });

  test('touch targets turned off', () {
    expect(
      found('final t = theme.copyWith(tapTarget: 0);\nx(tapTarget: 0.0);'),
      ['touch targets 1', 'touch targets 2'],
    );
    expect(found('x(tapTarget: 44);'), isEmpty);
  });

  group('contrast', () {
    test('the harness imports the theme from the app', () {
      final h = contrastHarness('package:shop/src/ui');
      expect(h, contains("import 'package:shop/src/ui/app_theme.dart';"));
      expect(h, contains("import 'package:shop/src/ui/theme.dart';"));
      for (final p in contrastPairs) {
        expect(h, contains("c.${p.$2}, c.${p.$3}"));
      }
    });

    test('only what measured under its need is a finding', () {
      final f = contrastFindings(
        'noise\n'
        'ASHLAR\tlight\ttext on the page\t17.93\t4.5\t1.4.3\n'
        'ASHLAR\tdark\tdestructive button text\t2.89\t4.5\t1.4.3\n'
        'ASHLAR\tlight\tfocus ring on the page\t2.58\t3.0\t1.4.11\n',
      );
      expect(f.map((x) => '${x.at}: ${x.message}'), [
        'dark: destructive button text is 2.89:1; WCAG 1.4.3 needs 4.5:1.',
        'light: focus ring on the page is 2.58:1; WCAG 1.4.11 needs 3:1.',
      ]);
    });
  });

  test('ashlar check says what it found, and fails for CI only then', () async {
    final dir = Directory.systemTemp.createTempSync('ashlar_check_');
    addTearDown(() => dir.deleteSync(recursive: true));
    File('${dir.path}/pubspec.yaml').writeAsStringSync(
      'name: shop\ndependencies:\n  flutter:\n    sdk: flutter\n',
    );
    final screen = File('${dir.path}/lib/home.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync("const a = Text('Hi', textAlign: TextAlign.end);\n");
    var out = StringBuffer();
    expect(await run(['check', '--no-contrast'], dir: dir, out: out), 0);
    expect('$out', contains('Nothing found in 1 file under lib.'));
    expect('$out', contains('Not checked'));

    screen.writeAsStringSync(
      "const a = Text('Hi', textAlign: TextAlign.right);\n",
    );
    out = StringBuffer();
    expect(await run(['check', '--no-contrast'], dir: dir, out: out), 1);
    expect('$out', contains('lib/home.dart:1  TextAlign.right'));

    out = StringBuffer();
    await run(['check'], dir: dir, out: out);
    expect(
      '$out',
      contains('Contrast not measured: there is no lib/ui/app_theme.dart'),
    );
  });
}
