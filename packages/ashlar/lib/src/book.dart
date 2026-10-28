// ashlar book: a catalog of the components an app has, in its own theme, as an app of its
// own to run on any device. Written to .ashlar/book, outside the app's code.
import 'dart:io';

import 'review.dart' show ReviewItem;

/// Writes the catalog of [items] for the app at [root], whose components are in [path]
/// (under lib). [named] gives a name as the app has it, under its prefix; [rename] does
/// the same to a source. Returns the entry point's path, or why it could not be written.
({String? main, String? why}) writeBook({
  required Directory root,
  required String package,
  required String path,
  required List<ReviewItem> items,
  required String Function(String) named,
  required String Function(String) rename,
}) {
  if (!path.startsWith('lib/')) {
    return (
      main: null,
      why:
          'the components are not under lib, where the catalog can import them from',
    );
  }
  if (items.isEmpty) {
    return (
      main: null,
      why: 'the app has no components with a page yet: ashlar add some',
    );
  }
  final dir = Directory('${root.path}/.ashlar/book');
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  dir.createSync(recursive: true);
  File('${dir.path}/.gitignore').writeAsStringSync('*\n');
  // The app's own components, as any file in the app imports them.
  final up = 'package:$package/${path.substring(4)}';
  for (final i in items) {
    File('${dir.path}/pages/${i.name.replaceAll('-', '_')}.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync(
        rename(i.preview).replaceAll('package:ashlar_ui_gallery/ui/', '$up/'),
      );
  }
  final hasTheme = File('${root.path}/$path/app_theme.dart').existsSync();
  final app = named('AshlarApp'),
      theme = named('AshlarTheme'),
      data = named('AshlarThemeData');
  final mode = named('AshlarThemeMode');
  String title(String n) =>
      n.split('-').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  final out = StringBuffer()
    ..writeln(
      '// Written by ashlar book: your components, in your theme. Written again each time.',
    )
    ..writeln('// Run it: flutter run -t .ashlar/book/main.dart')
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln()
    ..writeln("import '$up/app.dart';")
    ..writeln("import '$up/theme.dart';")
    ..writeln(hasTheme ? "import '$up/app_theme.dart';" : '');
  for (final (n, i) in items.indexed) {
    out.writeln("import 'pages/${i.name.replaceAll('-', '_')}.dart' as p$n;");
  }
  out.writeln('''

/// Each component's page, by its name.
final _pages = <(String, Widget Function())>[
${[for (final (n, i) in items.indexed) "  ('${title(i.name)}', () => const p$n.${i.widget}()),"].join('\n')}
];

void main() => runApp(const _Book());

class _Book extends StatefulWidget {
  const _Book();

  @override
  State<_Book> createState() => _BookState();
}

class _BookState extends State<_Book> {
  var _at = 0;
  bool _dark = false, _bigText = false, _rtl = false;

  @override
  Widget build(BuildContext context) => $app(
    title: 'Components',
    theme: ${hasTheme ? 'appTheme' : '$data.light()'},
    darkTheme: ${hasTheme ? 'appDarkTheme' : '$data.dark()'},
    themeMode: _dark ? $mode.dark : $mode.light,
    builder: (context, child) {
      var out = child!;
      if (_rtl) out = Directionality(textDirection: TextDirection.rtl, child: out);
      if (_bigText) {
        out = MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)), child: out);
      }
      return out;
    },
    home: Builder(
      builder: (context) {
        final t = $theme.of(context);
        final c = t.colors;
        Widget link(String label, bool on, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: on ? c.accent : c.accent.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(t.radiusMd),
              ),
              child: Text(label, style: t.text.sm.copyWith(color: on ? c.accentForeground : c.mutedForeground)),
            ),
          ),
        );
        return Row(
          children: [
            SizedBox(
              width: 220,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  for (final (n, (name, _)) in _pages.indexed)
                    link(name, n == _at, () => setState(() => _at = n)),
                ],
              ),
            ),
            Container(width: 1, color: c.border),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        link('Dark', _dark, () => setState(() => _dark = !_dark)),
                        link('Text 200%', _bigText, () => setState(() => _bigText = !_bigText)),
                        link('Right to left', _rtl, () => setState(() => _rtl = !_rtl)),
                      ],
                    ),
                  ),
                  Container(height: 1, color: c.border),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: KeyedSubtree(key: ValueKey(_at), child: _pages[_at].\$2()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}''');
  final main = File('${dir.path}/main.dart')..writeAsStringSync(out.toString());
  return (main: main.path.substring(root.path.length + 1), why: null);
}
