import 'dart:convert';
import 'dart:io';

import 'component.dart';
import 'registry.g.dart';

/// The version each pub.dev package a component needs is added at.
const packageVersions = {'ashlar_icons': '^0.2.0'};

/// The theme choices `ashlar init` takes, as palette.dart and theme.dart name them.
const bases = ['neutral', 'stone', 'zinc', 'mauve', 'olive', 'mist', 'taupe'];
const accents = [
  'amber',
  'blue',
  'cyan',
  'emerald',
  'fuchsia',
  'green',
  'indigo',
  'lime',
  'orange',
  'pink',
  'purple',
  'red',
  'rose',
  'sky',
  'teal',
  'violet',
  'yellow',
];
const styles = ['standard', 'compact', 'rounded', 'sharp', 'dense', 'soft'];

final _usage =
    '''
Ashlar UI: components for Flutter on the widgets layer, copied into your app.

  ashlar init [--path lib/ui]          set up the theme and AshlarApp
             [--base neutral]           the greys: ${bases.join(', ')}
             [--accent blue]            a colour for main actions: ${accents.join(', ')}
             [--style standard]         spacing and shape: ${styles.join(', ')}
  ashlar add <component>... [--all]     copy components, with what they need
             [--blocks]                 every block: whole screens, in lib/blocks
             [--overwrite]              replace files you already have
  ashlar list                           what there is, and what you have

Run it in a Flutter project's root. The files are yours to change: ashlar never
replaces one unless you pass --overwrite.''';

/// Runs the ashlar command in [dir]; returns the exit code.
Future<int> run(List<String> args, {Directory? dir, StringSink? out}) async {
  final root = dir ?? Directory.current;
  final o = out ?? stdout;
  if (args.isEmpty ||
      args.first == 'help' ||
      args.contains('--help') ||
      args.contains('-h')) {
    o.writeln(_usage);
    return 0;
  }
  final command = args.first;
  final rest = args.skip(1).toList();
  final pubspec = File('${root.path}/pubspec.yaml');
  if (command != 'list' &&
      (!pubspec.existsSync() ||
          !pubspec.readAsStringSync().contains(
            RegExp(r'^\s+sdk:\s*flutter', multiLine: true),
          ))) {
    o.writeln(
      'Run ashlar in the root of a Flutter project: there is no pubspec.yaml with a Flutter dependency here.',
    );
    return 64;
  }
  switch (command) {
    case 'init':
      String? option(String name) {
        final at = rest.indexOf('--$name');
        return at >= 0 && at + 1 < rest.length ? rest[at + 1] : null;
      }

      final path = option('path') ?? 'lib/ui';
      final base = option('base') ?? 'neutral',
          accent = option('accent'),
          style = option('style') ?? 'standard';
      for (final (what, value, allowed) in [
        ('base', base, bases),
        ('accent', accent, accents),
        ('style', style, styles),
      ]) {
        if (value != null && !allowed.contains(value)) {
          o.writeln(
            'No $what named $value. Choose one of: ${allowed.join(', ')}.',
          );
          return 64;
        }
      }
      File('${root.path}/ashlar.json').writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert({'path': path, 'base': base, 'accent': ?accent, 'style': style})}\n',
      );
      o.writeln(
        'ashlar.json: components go in $path; $base${accent == null ? '' : ', $accent'}, $style',
      );
      final code = await _add(
        root,
        ['theme', 'app'],
        overwrite: rest.contains('--overwrite'),
        out: o,
      );
      if (code != 0) return code;
      writeAppTheme(
        root,
        path,
        base: base,
        accent: accent,
        style: style,
        out: o,
      );
      o.writeln(
        'Give AshlarApp theme: appTheme and darkTheme: appDarkTheme from $path/app_theme.dart.',
      );
      return 0;
    case 'add':
      final names = [
        if (rest.contains('--all'))
          ...registry.keys.where((n) => !registry[n]!.block),
        if (rest.contains('--blocks'))
          ...registry.keys.where((n) => registry[n]!.block),
        ...rest.where((a) => !a.startsWith('--')),
      ];
      if (names.isEmpty) {
        o.writeln('Name a component to add, or --all. ashlar list shows them.');
        return 64;
      }
      final unknown = names.where((n) => !registry.containsKey(n)).toList();
      if (unknown.isNotEmpty) {
        o.writeln(
          'No component named ${unknown.join(', ')}. ashlar list shows them.',
        );
        return 64;
      }
      return _add(root, names, overwrite: rest.contains('--overwrite'), out: o);
    case 'list':
      for (final block in [false, true]) {
        o.writeln(block ? '\nBlocks, whole screens:' : 'Components:');
        for (final MapEntry(key: name, value: c) in registry.entries.where(
          (e) => e.value.block == block,
        )) {
          final have = c.files.keys.every(
            (f) => File('${root.path}/${_target(root, c, f)}').existsSync(),
          );
          o.writeln(
            '${have ? '✓' : ' '} ${name.padRight(14)} ${c.description}',
          );
        }
      }
      return 0;
    default:
      o.writeln('No command $command.\n\n$_usage');
      return 64;
  }
}

Map<String, dynamic> _config(Directory root) {
  final config = File('${root.path}/ashlar.json');
  return config.existsSync()
      ? jsonDecode(config.readAsStringSync()) as Map<String, dynamic>
      : const {};
}

/// Where components go, from the project root.
/// Writes the chosen theme to [path]/app_theme.dart, for AshlarApp to use.
void writeAppTheme(
  Directory root,
  String path, {
  required String base,
  String? accent,
  required String style,
  required StringSink out,
}) {
  String theme(String brightness) =>
      'AshlarThemeData.from(\n'
      '  brightness: Brightness.$brightness,\n'
      '  base: AshlarBase.$base,\n'
      '${accent == null ? '' : '  accent: AshlarAccent.$accent,\n'}'
      '  style: AshlarStyle.$style,\n'
      ')';
  File('${root.path}/$path/app_theme.dart').writeAsStringSync('''
// Your app's theme, written by `ashlar init`: change it here, or choose again with
// `ashlar apply`. AshlarApp(theme: appTheme, darkTheme: appDarkTheme).

import 'package:flutter/widgets.dart';

import 'palette.dart';
import 'theme.dart';

final appTheme = ${theme('light')};

final appDarkTheme = ${theme('dark')};
''');
  out.writeln('  wrote  $path/app_theme.dart');
}

String _path(Directory root) => _config(root)['path'] as String? ?? 'lib/ui';

/// Where blocks go: ashlar.json's "blocks", or a blocks folder beside the components.
String _blocks(Directory root) {
  final set = _config(root)['blocks'] as String?;
  if (set != null) return set;
  final ui = _path(root).split('/')..removeLast();
  return [...ui, 'blocks'].join('/');
}

/// Where [file] of [c] lands, from the project root.
String _target(Directory root, Component c, String file) => c.block
    ? '${_blocks(root)}/${file.split('/').last}'
    : '${_path(root)}/$file';

/// The way from folder [from] to folder [to], both from the project root.
String _relative(String from, String to) {
  final a = from.split('/'), b = to.split('/');
  var same = 0;
  while (same < a.length && same < b.length && a[same] == b[same]) {
    same++;
  }
  return [
    for (var i = same; i < a.length; i++) '..',
    ...b.skip(same),
  ].join('/');
}

/// The components named and every one they need, needed ones first.
List<String> resolve(List<String> names) {
  final order = <String>[];
  void visit(String n) {
    if (order.contains(n)) return;
    for (final r in registry[n]!.requires) {
      visit(r);
    }
    order.add(n);
  }

  names.forEach(visit);
  return order;
}

Future<int> _add(
  Directory root,
  List<String> names, {
  required bool overwrite,
  required StringSink out,
}) async {
  final path = _path(root);
  // Blocks import components as '../ui/name.dart'; point them at where the components are.
  final toUi = _relative(_blocks(root), path);
  final packages = <String>{};
  for (final name in resolve(names)) {
    final c = registry[name]!;
    packages.addAll(c.packages);
    for (final MapEntry(key: file, value: source) in c.files.entries) {
      final at = _target(root, c, file);
      final target = File('${root.path}/$at');
      if (target.existsSync() && !overwrite) {
        out.writeln('  kept   $at (yours; --overwrite replaces it)');
        continue;
      }
      target.parent.createSync(recursive: true);
      target.writeAsStringSync(
        c.block
            ? source.replaceAll("import '../ui/", "import '$toUi/")
            : source,
      );
      out.writeln('  wrote  $at');
    }
  }
  final pubspec = File('${root.path}/pubspec.yaml').readAsStringSync();
  final missing = packages
      .where((p) => !RegExp('^\\s+$p:', multiLine: true).hasMatch(pubspec))
      .toList();
  if (missing.isEmpty) return 0;
  final specs = [for (final p in missing) '$p:${packageVersions[p] ?? 'any'}'];
  final fvm = File('${root.path}/.fvmrc').existsSync();
  final cmd = fvm
      ? ['fvm', 'flutter', 'pub', 'add', ...specs]
      : ['flutter', 'pub', 'add', ...specs];
  out.writeln('  adding ${specs.join(' ')}');
  try {
    final result = await Process.run(
      cmd.first,
      cmd.skip(1).toList(),
      workingDirectory: root.path,
      runInShell: true,
    );
    if (result.exitCode != 0) {
      throw ProcessException(
        cmd.first,
        cmd,
        '${result.stderr}',
        result.exitCode,
      );
    }
  } on Exception {
    out.writeln(
      'Could not add the packages. Add them yourself: ${cmd.join(' ')}',
    );
    return 1;
  }
  return 0;
}
