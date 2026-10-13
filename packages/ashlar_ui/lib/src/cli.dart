import 'dart:convert';
import 'dart:io';

import 'registry.g.dart';

/// The version each pub.dev package a component needs is added at.
const packageVersions = {'ashlar_icons': '^0.2.0'};

const _usage = '''
Ashlar UI: components for Flutter on the widgets layer, copied into your app.

  ashlar init [--path lib/ui]          set up the theme and AshlarApp
  ashlar add <component>... [--all]     copy components, with what they need
             [--overwrite]              replace files you already have
  ashlar list                           what there is, and what you have

Run it in a Flutter project's root. The files are yours to change: ashlar never
replaces one unless you pass --overwrite.''';

/// Runs the ashlar command in [dir]; returns the exit code.
Future<int> run(List<String> args, {Directory? dir, StringSink? out}) async {
  final root = dir ?? Directory.current;
  final o = out ?? stdout;
  if (args.isEmpty || args.first == 'help' || args.contains('--help') || args.contains('-h')) {
    o.writeln(_usage);
    return 0;
  }
  final command = args.first;
  final rest = args.skip(1).toList();
  final pubspec = File('${root.path}/pubspec.yaml');
  if (command != 'list' && (!pubspec.existsSync() || !pubspec.readAsStringSync().contains(RegExp(r'^\s+sdk:\s*flutter', multiLine: true)))) {
    o.writeln('Run ashlar in the root of a Flutter project: there is no pubspec.yaml with a Flutter dependency here.');
    return 64;
  }
  switch (command) {
    case 'init':
      final pathAt = rest.indexOf('--path');
      final path = pathAt >= 0 && pathAt + 1 < rest.length ? rest[pathAt + 1] : 'lib/ui';
      File('${root.path}/ashlar.json').writeAsStringSync('${const JsonEncoder.withIndent('  ').convert({'path': path})}\n');
      o.writeln('ashlar.json: components go in $path');
      return _add(root, ['theme', 'app'], overwrite: rest.contains('--overwrite'), out: o);
    case 'add':
      final names = rest.contains('--all') ? registry.keys.toList() : rest.where((a) => !a.startsWith('--')).toList();
      if (names.isEmpty) {
        o.writeln('Name a component to add, or --all. ashlar list shows them.');
        return 64;
      }
      final unknown = names.where((n) => !registry.containsKey(n)).toList();
      if (unknown.isNotEmpty) {
        o.writeln('No component named ${unknown.join(', ')}. ashlar list shows them.');
        return 64;
      }
      return _add(root, names, overwrite: rest.contains('--overwrite'), out: o);
    case 'list':
      final path = _path(root);
      for (final MapEntry(key: name, value: c) in registry.entries) {
        final have = c.files.keys.every((f) => File('${root.path}/$path/$f').existsSync());
        o.writeln('${have ? '✓' : ' '} ${name.padRight(12)} ${c.description}');
      }
      return 0;
    default:
      o.writeln('No command $command.\n\n$_usage');
      return 64;
  }
}

String _path(Directory root) {
  final config = File('${root.path}/ashlar.json');
  if (!config.existsSync()) return 'lib/ui';
  return (jsonDecode(config.readAsStringSync()) as Map<String, dynamic>)['path'] as String? ?? 'lib/ui';
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

Future<int> _add(Directory root, List<String> names, {required bool overwrite, required StringSink out}) async {
  final path = _path(root);
  Directory('${root.path}/$path').createSync(recursive: true);
  final packages = <String>{};
  for (final name in resolve(names)) {
    final c = registry[name]!;
    packages.addAll(c.packages);
    for (final MapEntry(key: file, value: source) in c.files.entries) {
      final target = File('${root.path}/$path/$file');
      if (target.existsSync() && !overwrite) {
        out.writeln('  kept   $path/$file (yours; --overwrite replaces it)');
        continue;
      }
      target.writeAsStringSync(source);
      out.writeln('  wrote  $path/$file');
    }
  }
  final pubspec = File('${root.path}/pubspec.yaml').readAsStringSync();
  final missing = packages.where((p) => !RegExp('^\\s+$p:', multiLine: true).hasMatch(pubspec)).toList();
  if (missing.isEmpty) return 0;
  final specs = [for (final p in missing) '$p:${packageVersions[p] ?? 'any'}'];
  final fvm = File('${root.path}/.fvmrc').existsSync();
  final cmd = fvm ? ['fvm', 'flutter', 'pub', 'add', ...specs] : ['flutter', 'pub', 'add', ...specs];
  out.writeln('  adding ${specs.join(' ')}');
  try {
    final result = await Process.run(cmd.first, cmd.skip(1).toList(), workingDirectory: root.path, runInShell: true);
    if (result.exitCode != 0) throw ProcessException(cmd.first, cmd, '${result.stderr}', result.exitCode);
  } on Exception {
    out.writeln('Could not add the packages. Add them yourself: ${cmd.join(' ')}');
    return 1;
  }
  return 0;
}
