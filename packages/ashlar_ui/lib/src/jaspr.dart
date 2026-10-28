import 'dart:io';

import 'package:yaml/yaml.dart';

import 'component.dart';
import 'registry_jaspr.g.dart';

/// The version each pub.dev package a Jaspr component needs is added at.
const jasprPackageVersions = {'universal_web': '^1.1.1'};

const _usage = '''
Ashlar UI for Jaspr: components for the web, copied into your app.

  ashlar init [--path lib/ui]          set up the theme; --path is where components go
  ashlar add <item>... [--all]          copy components, with what they need
             [--overwrite]              replace files you already have
  ashlar view <item>...                 what an item is and its files, before adding it
  ashlar search [words]                 find items by name or description
  ashlar list                           what there is, and what you have

The other commands (apply, shot, diff, update, check, book, mcp, build) are for
Flutter projects so far.

Run it in a Jaspr project's root. The files are yours to change: ashlar never
replaces one unless you pass --overwrite.''';

/// Whether [root] is a Jaspr project: its pubspec depends on jaspr and not on Flutter.
bool isJasprProject(Directory root) {
  final pubspec = File('${root.path}/pubspec.yaml');
  if (!pubspec.existsSync()) return false;
  final text = pubspec.readAsStringSync();
  return RegExp(r'^\s+jaspr:', multiLine: true).hasMatch(text) &&
      !RegExp(r'^\s+sdk:\s*flutter', multiLine: true).hasMatch(text);
}

/// The ashlar command in a Jaspr project: init, add, view, search and list.
Future<int> runJaspr(List<String> args, Directory root, StringSink o) async {
  if (args.isEmpty || args.first == 'help' || args.contains('--help') || args.contains('-h')) {
    o.writeln(_usage);
    return 0;
  }
  final command = args.first;
  final rest = args.skip(1).toList();
  final pathAt = rest.indexOf('--path');
  final givenPath = pathAt >= 0 && pathAt + 1 < rest.length ? rest[pathAt + 1] : null;
  final words = [
    for (var i = 0; i < rest.length; i++)
      if (!rest[i].startsWith('--') && !(i > 0 && rest[i - 1] == '--path')) rest[i],
  ];
  final overwrite = rest.contains('--overwrite');
  final config = File('${root.path}/ashlar.yaml');

  String path() {
    if (!config.existsSync()) return 'lib/ui';
    final yaml = loadYaml(config.readAsStringSync());
    return yaml is YamlMap && yaml['path'] is String ? yaml['path'] as String : 'lib/ui';
  }

  switch (command) {
    case 'init':
      final folder = givenPath ?? 'lib/ui';
      if (!RegExp(r'^lib(/[\w-]+)+$').hasMatch(folder)) {
        o.writeln('--path $folder: name a folder inside lib, as lib/ui or lib/components.');
        return 64;
      }
      if (!config.existsSync() || overwrite) {
        config.writeAsStringSync(
          '# Ashlar UI: where components go. ashlar init writes it, and so can you.\n'
          'path: $folder\n',
        );
        o.writeln('ashlar.yaml: components go in $folder');
      }
      final code = await _add(['theme'], root, path(), overwrite, o);
      if (code != 0) return code;
      o.writeln(
        'Import ${path().substring(4)}/theme.dart once, from your app component, so its styles reach the page.',
      );
      return 0;
    case 'add':
      if (!config.existsSync()) {
        o.writeln('Run ashlar init first: it writes ashlar.yaml and the theme.');
        return 64;
      }
      final names = rest.contains('--all') ? jasprRegistry.keys.toList() : words;
      if (names.isEmpty) {
        o.writeln('Name what to add: ashlar add button card. ashlar list shows what there is.');
        return 64;
      }
      final unknown = names.where((n) => !jasprRegistry.containsKey(n)).toList();
      if (unknown.isNotEmpty) {
        o.writeln('Not in Ashlar UI for Jaspr: ${unknown.join(', ')}. ashlar list shows what there is.');
        return 64;
      }
      return _add(names, root, path(), overwrite, o);
    case 'view':
      for (final name in words) {
        final item = jasprRegistry[name];
        if (item == null) {
          o.writeln('$name: not in Ashlar UI for Jaspr.');
          return 64;
        }
        o
          ..writeln('$name: ${item.description}')
          ..writeln('  files     ${item.files.keys.join(', ')}');
        if (item.requires.isNotEmpty) o.writeln('  requires  ${item.requires.join(', ')}');
        if (item.packages.isNotEmpty) o.writeln('  packages  ${item.packages.join(', ')}');
      }
      return 0;
    case 'search' || 'list':
      final query = words.join(' ').toLowerCase();
      final have = Directory('${root.path}/${path()}');
      for (final MapEntry(key: name, value: item) in jasprRegistry.entries) {
        if (query.isNotEmpty &&
            !name.contains(query) &&
            !item.description.toLowerCase().contains(query)) {
          continue;
        }
        final added = item.files.keys.every((f) => File('${have.path}/$f').existsSync());
        o.writeln('${added ? '*' : ' '} ${name.padRight(14)} ${item.description}');
      }
      if (command == 'list') o.writeln('\n* in your project');
      return 0;
    default:
      o.writeln('ashlar $command is for Flutter projects so far. ashlar help shows what works here.');
      return 64;
  }
}

/// Writes [names] and what they need into [path], then adds the packages they use.
///
/// [overwrite] replaces the files of [names] only: what they need and you already have
/// (your theme, a button you changed) is kept.
Future<int> _add(
  List<String> names,
  Directory root,
  String path,
  bool overwrite,
  StringSink o,
) async {
  final order = <String>[];
  void visit(String name) {
    if (order.contains(name)) return;
    jasprRegistry[name]!.requires.forEach(visit);
    order.add(name);
  }

  names.forEach(visit);
  final packages = <String>{};
  for (final name in order) {
    final Component item = jasprRegistry[name]!;
    packages.addAll(item.packages);
    for (final MapEntry(key: file, value: source) in item.files.entries) {
      final at = '$path/$file';
      final target = File('${root.path}/$at');
      if (target.existsSync() && !(overwrite && names.contains(name))) {
        o.writeln('  kept   $at (yours${names.contains(name) ? '; --overwrite replaces it' : ''})');
        continue;
      }
      target.parent.createSync(recursive: true);
      target.writeAsStringSync(source);
      o.writeln('  wrote  $at');
    }
  }
  final pubspec = File('${root.path}/pubspec.yaml').readAsStringSync();
  final missing = [
    for (final p in packages)
      if (!RegExp('^\\s+$p:', multiLine: true).hasMatch(pubspec)) '$p:${jasprPackageVersions[p] ?? 'any'}',
  ];
  if (missing.isEmpty) return 0;
  final cmd = [if (_usesFvm(root)) 'fvm', 'dart', 'pub', 'add', ...missing];
  o.writeln('  adding ${missing.join(' ')}');
  final result = await Process.run(cmd.first, cmd.skip(1).toList(), workingDirectory: root.path, runInShell: true);
  if (result.exitCode != 0) {
    o.writeln('Could not add ${missing.join(' ')}: ${result.stderr}'.trim());
    return result.exitCode;
  }
  return 0;
}

/// Whether the project, or a folder above it (a workspace), pins its SDK with fvm.
bool _usesFvm(Directory root) {
  for (Directory? d = root.absolute; d != null; d = d.parent.path == d.path ? null : d.parent) {
    if (File('${d.path}/.fvmrc').existsSync()) return true;
  }
  return false;
}
