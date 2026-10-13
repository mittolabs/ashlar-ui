import 'dart:convert';
import 'dart:io';

import 'component.dart';
import 'diff.dart';
import 'registry.g.dart';
import 'remote.dart';

/// The version each pub.dev package a component needs is added at.
const packageVersions = {'ashlar_icons': '^0.2.0'};

/// The theme choices `ashlar init` and `ashlar apply` take, as palette.dart and theme.dart
/// name them.
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
  ashlar apply [--base] [--accent] [--style]
                                        choose the theme again; --accent none for none
  ashlar add <item>... [--all]          copy components, with what they need
             [--blocks]                 every block: whole screens, in lib/blocks
             [--overwrite]              replace files you already have
  ashlar view <item>...                 what an item is and its files, before adding it
  ashlar search [words] [@registry...]  find items by name or description
  ashlar list                           what there is, and what you have
  ashlar diff [item...]                 what changed in your copies, and what is newer
  ashlar build [registry.json]          make your own registry's files to host
             [--out public/r]

Items from a registry of your own are named @name/item, where ashlar.json says where
@name is: "registries": {"@acme": "https://acme.dev/r"} or a folder.

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
  String? option(String name) {
    final at = rest.indexOf('--$name');
    return at >= 0 && at + 1 < rest.length ? rest[at + 1] : null;
  }

  // The words after the command that are not options or their values.
  final options = {'path', 'base', 'accent', 'style', 'out'};
  final words = [
    for (var i = 0; i < rest.length; i++)
      if (!rest[i].startsWith('--') &&
          !(i > 0 &&
              rest[i - 1].startsWith('--') &&
              options.contains(rest[i - 1].substring(2))))
        rest[i],
  ];
  final needsFlutter = !{'list', 'search', 'view', 'build'}.contains(command);
  final pubspec = File('${root.path}/pubspec.yaml');
  if (needsFlutter &&
      (!pubspec.existsSync() ||
          !pubspec.readAsStringSync().contains(
            RegExp(r'^\s+sdk:\s*flutter', multiLine: true),
          ))) {
    o.writeln(
      'Run ashlar in the root of a Flutter project: there is no pubspec.yaml with a Flutter dependency here.',
    );
    return 64;
  }
  final project = Project(root);
  switch (command) {
    case 'init':
      final path = option('path') ?? 'lib/ui';
      final base = option('base') ?? 'neutral',
          accent = option('accent'),
          style = option('style') ?? 'standard';
      if (!_checkTheme(base, accent, style, o)) return 64;
      project.save({
        ...project.config,
        'path': path,
        'base': base,
        'accent': accent,
        'style': style,
      });
      o.writeln(
        'ashlar.json: components go in $path; $base${accent == null ? '' : ', $accent'}, $style',
      );
      final code = await project.add(
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
    case 'apply':
      final config = project.config;
      final base = option('base') ?? config['base'] as String? ?? 'neutral';
      final given = option('accent');
      final accent = given == 'none'
          ? null
          : given ?? config['accent'] as String?;
      final style = option('style') ?? config['style'] as String? ?? 'standard';
      if (!_checkTheme(base, accent, style, o)) return 64;
      project.save({...config, 'base': base, 'accent': accent, 'style': style});
      // The palette came after some projects began: add it if it is not there.
      final code = await project.add(['theme'], overwrite: false, out: o);
      if (code != 0) return code;
      writeAppTheme(
        root,
        project.path,
        base: base,
        accent: accent,
        style: style,
        out: o,
      );
      o.writeln(
        'Theme: $base${accent == null ? '' : ', $accent'}, $style. Your components are as they were.',
      );
      return 0;
    case 'add':
      final names = [
        if (rest.contains('--all'))
          ...registry.keys.where((n) => !registry[n]!.block),
        if (rest.contains('--blocks'))
          ...registry.keys.where((n) => registry[n]!.block),
        ...words,
      ];
      if (names.isEmpty) {
        o.writeln('Name a component to add, or --all. ashlar list shows them.');
        return 64;
      }
      return project.add(
        names,
        overwrite: rest.contains('--overwrite'),
        out: o,
      );
    case 'view':
      if (words.isEmpty) {
        o.writeln('Name an item to view. ashlar search finds them.');
        return 64;
      }
      for (final name in words) {
        final c = await project.find(name, o);
        if (c == null) return 64;
        o
          ..writeln('$name: ${c.description}')
          ..writeln(
            '  ${c.block ? 'a block, in ${project.blocks}' : 'a component, in ${project.path}'}',
          );
        if (c.requires.isNotEmpty) {
          o.writeln('  needs ${c.requires.join(', ')}');
        }
        if (c.packages.isNotEmpty) {
          o.writeln('  adds ${c.packages.join(', ')} from pub.dev');
        }
        for (final MapEntry(key: file, value: source) in c.files.entries) {
          o
            ..writeln('\n── $file (${source.split('\n').length} lines)')
            ..writeln(source);
        }
      }
      return 0;
    case 'search' || 'list':
      final registries = words.where((w) => w.startsWith('@')).toList();
      final query = words.where((w) => !w.startsWith('@')).join(' ');
      final sources = <String, Map<String, Component>>{
        if (registries.isEmpty) '': registry,
      };
      for (final r in registries) {
        final items = await project.index(r, o);
        if (items == null) return 64;
        sources[r] = items;
      }
      var found = 0;
      for (final MapEntry(key: source, value: items) in sources.entries) {
        for (final block in [false, true]) {
          final matches = items.entries.where(
            (e) => e.value.block == block && _matches(e, query),
          );
          if (matches.isEmpty) continue;
          o.writeln(
            '${source.isEmpty ? '' : '$source: '}${block ? 'Blocks, whole screens:' : 'Components:'}',
          );
          for (final MapEntry(key: name, value: c) in matches) {
            final full = source.isEmpty ? name : '$source/$name';
            final have = project.has(c);
            o.writeln(
              '${have ? '✓' : ' '} ${full.padRight(16)} ${c.description}',
            );
            found++;
          }
          o.writeln();
        }
      }
      if (found == 0) o.writeln('Nothing matches "$query".');
      return 0;
    case 'diff':
      return project.diff(words, o);
    case 'build':
      final file = words.firstOrNull ?? 'registry.json';
      return build(
        File(file.startsWith('/') ? file : '${root.path}/$file'),
        Directory('${root.path}/${option('out') ?? 'public/r'}'),
        o,
      );
    default:
      o.writeln('No command $command.\n\n$_usage');
      return 64;
  }
}

bool _checkTheme(String base, String? accent, String style, StringSink o) {
  for (final (what, value, allowed) in [
    ('base', base, bases),
    ('accent', accent, accents),
    ('style', style, styles),
  ]) {
    if (value != null && !allowed.contains(value)) {
      o.writeln('No $what named $value. Choose one of: ${allowed.join(', ')}.');
      return false;
    }
  }
  return true;
}

bool _matches(MapEntry<String, Component> e, String query) {
  if (query.isEmpty) return true;
  final text = '${e.key} ${e.value.description}'.toLowerCase();
  return query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .every((word) => text.contains(word));
}

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

/// A short fingerprint of a file's text, to tell later whether it changed.
String fingerprint(String text) {
  var hash = 0xcbf29ce484222325;
  for (final unit in utf8.encode(text)) {
    hash ^= unit;
    hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return hash.toUnsigned(64).toRadixString(16).padLeft(16, '0');
}

/// A Flutter project with Ashlar UI in it: where things go, and what was written.
class Project {
  Project(this.root);

  final Directory root;

  File get _file => File('${root.path}/ashlar.json');

  Map<String, dynamic> get config => _file.existsSync()
      ? jsonDecode(_file.readAsStringSync()) as Map<String, dynamic>
      : <String, dynamic>{};

  void save(Map<String, dynamic> config) => _file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert({for (final e in config.entries)
      if (e.value != null) e.key: e.value})}\n',
  );

  /// Where components go, from the project root.
  String get path => config['path'] as String? ?? 'lib/ui';

  /// Where blocks go: ashlar.json's "blocks", or a blocks folder beside the components.
  String get blocks {
    final set = config['blocks'] as String?;
    if (set != null) return set;
    final ui = path.split('/')..removeLast();
    return [...ui, 'blocks'].join('/');
  }

  /// Where [file] of [c] lands, from the project root.
  String target(Component c, String file) =>
      c.block ? '$blocks/${file.split('/').last}' : '$path/$file';

  /// [source] as it is written into this project: a block's imports point at the
  /// components, wherever they are.
  String written(Component c, String source) => c.block
      ? source.replaceAll(
          "import '../ui/",
          "import '${_relative(blocks, path)}/",
        )
      : source;

  bool has(Component c) => c.files.keys.every(
    (f) => File('${root.path}/${target(c, f)}').existsSync(),
  );

  /// The fingerprints of the files as ashlar wrote them, by path.
  Map<String, String> get _written =>
      (config['files'] as Map<String, dynamic>? ?? {}).cast<String, String>();

  /// Another registry: from ashlar.json's "registries".
  Remote? _remote(String namespace, StringSink out) {
    final at = (config['registries'] as Map<String, dynamic>? ?? {})[namespace];
    if (at is! String) {
      out.writeln(
        'No registry $namespace. Name it in ashlar.json: "registries": {"$namespace": "https://…/r"}.',
      );
      return null;
    }
    return Remote(at, root);
  }

  /// The items another registry has, by name.
  Future<Map<String, Component>?> index(
    String namespace,
    StringSink out,
  ) async {
    final remote = _remote(namespace, out);
    if (remote == null) return null;
    try {
      return await remote.index();
    } on RemoteException catch (e) {
      out.writeln('Could not read $namespace: ${e.message}');
      return null;
    }
  }

  /// The item [name]: ours, or @registry/item.
  Future<Component?> find(String name, StringSink out) async {
    if (!name.startsWith('@')) {
      final c = registry[name];
      if (c == null) {
        out.writeln('No item named $name. ashlar search finds them.');
      }
      return c;
    }
    final slash = name.indexOf('/');
    if (slash < 0) {
      out.writeln('Name an item of $name as $name/item.');
      return null;
    }
    final remote = _remote(name.substring(0, slash), out);
    if (remote == null) return null;
    try {
      return await remote.item(name.substring(slash + 1));
    } on RemoteException catch (e) {
      out.writeln('Could not read $name: ${e.message}');
      return null;
    }
  }

  /// Copies [names] and what they need, and adds the packages they use.
  Future<int> add(
    List<String> names, {
    required bool overwrite,
    required StringSink out,
  }) async {
    // Everything named and needed, needed first, read before anything is written.
    final order = <String>[];
    final items = <String, Component>{};
    Future<bool> visit(String name, String? namespace) async {
      final full =
          !name.startsWith('@') &&
              namespace != null &&
              !registry.containsKey(name)
          ? '$namespace/$name'
          : name;
      if (items.containsKey(full)) return true;
      final c = await find(full, out);
      if (c == null) return false;
      items[full] = c;
      final ns = full.startsWith('@')
          ? full.substring(0, full.indexOf('/'))
          : null;
      for (final r in c.requires) {
        if (!await visit(r, ns)) return false;
      }
      order.add(full);
      return true;
    }

    for (final n in names) {
      if (!await visit(n, null)) return 64;
    }
    final fingerprints = Map<String, String>.of(_written);
    final packages = <String>{};
    for (final name in order) {
      final c = items[name]!;
      packages.addAll(c.packages);
      for (final MapEntry(key: file, value: source) in c.files.entries) {
        final at = target(c, file);
        final f = File('${root.path}/$at');
        if (f.existsSync() && !overwrite) {
          out.writeln('  kept   $at (yours; --overwrite replaces it)');
          continue;
        }
        final text = written(c, source);
        f.parent.createSync(recursive: true);
        f.writeAsStringSync(text);
        fingerprints[at] = fingerprint(text);
        out.writeln('  wrote  $at');
      }
    }
    if (_file.existsSync() || fingerprints.isNotEmpty) {
      save({...config, 'files': fingerprints});
    }
    final pubspec = File('${root.path}/pubspec.yaml').readAsStringSync();
    final missing = packages
        .where((p) => !RegExp('^\\s+$p:', multiLine: true).hasMatch(pubspec))
        .toList();
    if (missing.isEmpty) return 0;
    final specs = [
      for (final p in missing) '$p:${packageVersions[p] ?? 'any'}',
    ];
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

  /// For each item you have (or each named), whether your copy is as it was written,
  /// changed by you, or older than this version of ashlar's; with the lines that differ
  /// when items are named.
  int diff(List<String> names, StringSink out) {
    final unknown = names.where((n) => !registry.containsKey(n)).toList();
    if (unknown.isNotEmpty) {
      out.writeln('No component named ${unknown.join(', ')}.');
      return 64;
    }
    final chosen = names.isEmpty
        ? registry.keys.where((n) => has(registry[n]!)).toList()
        : names;
    var differing = 0;
    for (final name in chosen) {
      final c = registry[name]!;
      for (final MapEntry(key: file, value: source) in c.files.entries) {
        final at = target(c, file);
        final f = File('${root.path}/$at');
        if (!f.existsSync()) {
          out.writeln('  $at: not added');
          continue;
        }
        final yours = f.readAsStringSync(), latest = written(c, source);
        if (yours == latest) continue;
        differing++;
        final then = _written[at];
        final mine = then != null && fingerprint(yours) != then;
        final newer = then == null || fingerprint(latest) != then;
        final what = switch ((mine, newer)) {
          (true, true) => 'changed by you, and newer here',
          (true, false) => 'changed by you',
          (false, true) => 'newer here: ashlar add $name --overwrite takes it',
          (false, false) => 'differs',
        };
        out.writeln('  $at: $what');
        if (names.isNotEmpty) {
          out.writeln(
            unifiedDiff(yours, latest, from: 'yours', to: 'this version'),
          );
        }
      }
    }
    if (differing == 0) {
      out.writeln('Your copies are as this version writes them.');
    }
    return 0;
  }
}

/// Makes the files of a registry of your own: [manifest] names the items as Ashlar's
/// registry.json does ({"name": {"description", "files", "requires", "packages",
/// "block"}}, files relative to it); [out] gets registry.json, the index, and an item
/// file for each, ready to host or to point ashlar.json at.
int build(File manifest, Directory out, StringSink o) {
  if (!manifest.existsSync()) {
    o.writeln('No ${manifest.path}: write one naming your items.');
    return 64;
  }
  final spec = jsonDecode(manifest.readAsStringSync()) as Map<String, dynamic>;
  final dir = manifest.parent.path;
  out.createSync(recursive: true);
  final index = <Map<String, Object?>>[];
  for (final MapEntry(key: name, value: item as Map<String, dynamic>)
      in spec.entries) {
    final files = <String, String>{};
    for (final path in (item['files'] as List).cast<String>()) {
      final f = File('$dir/$path');
      if (!f.existsSync()) {
        o.writeln('$name names $path, which is not there.');
        return 64;
      }
      files[path] = f.readAsStringSync();
    }
    final json = {
      'name': name,
      'description': item['description'] ?? '',
      'requires': item['requires'] ?? const [],
      'packages': item['packages'] ?? const [],
      'block': item['block'] ?? false,
      'files': files,
    };
    File('${out.path}/$name.json').writeAsStringSync(jsonEncode(json));
    index.add({
      'name': name,
      'description': json['description'],
      'block': json['block'],
    });
    o.writeln('  built  ${out.path}/$name.json');
  }
  File('${out.path}/registry.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({'items': index}),
  );
  o.writeln('  built  ${out.path}/registry.json (${index.length} items)');
  return 0;
}
