import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'book.dart';
import 'check.dart';
import 'component.dart';
import 'diff.dart';
import 'mcp.dart';
import 'prefix.dart';
import 'preset.dart';
import 'merge.dart';
import 'registry.g.dart';
import 'agents.dart';
import 'review.dart';
import 'shot.dart';
import 'remote.dart';

/// The version each pub.dev package a component needs is added at.
const packageVersions = {'ashlar_icons': '^0.3.0'};

final _usage =
    '''
Ashlar UI: components for Flutter on the widgets layer, copied into your app.

  ashlar init [--path lib/ui]          set up the theme and AshlarApp; --path is where
             [--blocks lib/blocks]      components go, --blocks the blocks (beside them
             [--tests test/ashlar]      unless you say), --tests their tests
             [--prefix SL]              your own prefix on every name: SLButton, SLTheme
             [--base neutral]           the greys: ${bases.join(', ')}
             [--accent blue]            a colour for main actions: ${accents.join(', ')}
             [--style standard]         spacing and shape: ${styles.join(', ')}
             [--preset a1...]           a theme made on ui.ashlar.ke/themes, colours and all
             [--no-agents]              no Ashlar UI section in AGENTS.md (and CLAUDE.md)
  ashlar apply [--base] [--accent] [--style] [--preset] [--prefix]
                                        choose the theme again; --accent none for none;
                                        --preset none drops a preset's changes;
                                        --prefix renames everywhere, your code too
  ashlar add <item>... [--all]          copy components, with what they need
             [--blocks]                 every block: whole screens, in lib/blocks
             [--overwrite]              replace files you already have
             [--no-tests]               leave out their tests (test/ashlar)
  ashlar shot <file>[:Widget]...        draw your screens to pictures without running the app,
             [--size phone]             in your theme: phone, tablet, desktop or 390x844, several
             [--dark] [--both]          with commas; light, dark or both; --center for a part of
             [--out .ashlar/shots]      a screen. Says what Flutter complained of, and where
  ashlar view <item>...                 what an item is and its files, before adding it
  ashlar search [words] [@registry...]  find items by name or description
  ashlar list                           what there is, and what you have
  ashlar diff [item...]                 what changed in your copies, and what is newer
  ashlar update [item...] [--dry-run]   take what is newer, keeping your changes
             [--preview]                draw what it would change, before and after
  ashlar check [--no-contrast]          what can be proved about your app's accessibility:
                                        theme contrast, labels, right to left, touch targets
  ashlar book                           a catalog of your components, in your theme,
                                        to run as an app of its own
  ashlar mcp                            these commands for a coding agent, over MCP on
                                        standard input and output
  ashlar build [registry.json]          make your own registry's files to host
             [--out public/r]

Items from a registry of your own are named @name/item, where ashlar.yaml says where
@name is, under registries: "@acme": https://acme.dev/r, or a folder.

Each component comes with its tests, in test/ashlar, so you can change it and check it
still does what it promised. tests: false in ashlar.yaml leaves them out.

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
  // Folders for init; for add, --blocks is a word of its own.
  final options = {
    'path',
    'base',
    'accent',
    'style',
    'preset',
    'out',
    'size',
    'scale',
    'prefix',
    if (command == 'init') ...['blocks', 'tests'],
  };
  final named = [
    for (var i = 0; i < rest.length; i++)
      if (!rest[i].startsWith('--') &&
          !(i > 0 &&
              rest[i - 1].startsWith('--') &&
              options.contains(rest[i - 1].substring(2))))
        rest[i],
  ];
  // A name an item went by before finds it, and says what it is called now.
  final renamed = {
    for (final MapEntry(key: name, value: item) in registry.entries)
      for (final old in item.replaces) old: name,
  };
  final aliases = ['add', 'view', 'diff', 'update'].contains(command);
  final words = [
    for (final word in named)
      if (aliases && renamed[word] != null) renamed[word]! else word,
  ];
  for (final word in named.where((w) => aliases && renamed.containsKey(w))) {
    o.writeln('$word is now ${renamed[word]}.');
  }
  final needsFlutter = ![
    'list',
    'search',
    'view',
    'build',
    'mcp',
  ].contains(command);
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
      final folders = <String, String?>{};
      for (final name in ['path', 'blocks', 'tests']) {
        final given = option(name);
        if (given == null) continue;
        final folder = _folder(given);
        if (folder == null) {
          o.writeln(
            '--$name $given: name a folder inside the project, as lib/ui or test/ui.',
          );
          return 64;
        }
        folders[name] = folder;
      }
      final path = folders['path'] ?? 'lib/ui';
      var preset = const ThemePreset();
      if (option('preset') case final code?) {
        try {
          preset = ThemePreset.parse(code);
        } on FormatException catch (e) {
          o.writeln('--preset: ${e.message}');
          return 64;
        }
      }
      // Options given beside a preset change its choices.
      final givenAccent = option('accent');
      if (givenAccent != null && givenAccent != 'none') {
        if (!_checkTheme(preset.base, givenAccent, preset.style, o)) return 64;
      }
      preset = preset.withChoices(
        base: option('base'),
        accent: givenAccent == 'none' ? null : givenAccent,
        noAccent: givenAccent == 'none',
        style: option('style'),
      );
      final base = preset.base, accent = preset.accent, style = preset.style;
      if (!_checkTheme(base, accent, style, o)) return 64;
      final prefix = option('prefix');
      if (prefix != null && !validPrefix.hasMatch(prefix)) {
        o.writeln(
          'A prefix is a capital, then letters or digits: SL, Mz, Acme.',
        );
        return 64;
      }
      project.save({
        'prefix': ?prefix,
        'path': path,
        'blocks': ?folders['blocks'],
        'tests': ?folders['tests'],
        'base': base,
        'accent': accent,
        'style': style,
        'preset': preset.changed ? preset.code : null,
      });
      final tests = project.tests;
      o.writeln(
        'ashlar.yaml: components go in $path, blocks in ${project.blocks}'
        '${tests == null ? '' : ', tests in $tests'}; '
        '$base${accent == null ? '' : ', $accent'}, $style'
        '${preset.changed ? ', and the preset\'s changes' : ''}',
      );
      if (!path.startsWith('lib/')) {
        o.writeln(
          '  note   $path is not under lib: its components get no tests, since a test cannot import them.',
        );
      } else if (tests != null && !'$tests/'.startsWith('test/')) {
        o.writeln(
          '  note   flutter test looks in test; run these with flutter test $tests.',
        );
      }
      final code = await project.add(
        ['theme', 'app'],
        overwrite: rest.contains('--overwrite'),
        tests: !rest.contains('--no-tests'),
        out: o,
      );
      if (code != 0) return code;
      writeAppTheme(root, path, preset: preset, prefix: prefix, out: o);
      if (!rest.contains('--no-agents')) {
        writeAgentRules(
          root,
          agentRules(
            path: path,
            tests: project.tests ?? 'test/ashlar',
            named: project.named,
          ),
          o,
        );
      } else {
        project.save({'agents': false});
      }
      o.writeln(
        'Give ${project.named('AshlarApp')} theme: appTheme and darkTheme: appDarkTheme from $path/app_theme.dart.',
      );
      return 0;
    case 'apply':
      final config = project.config;
      // The theme as it is: the preset kept in ashlar.yaml, or its choices alone.
      var preset = ThemePreset(
        base: config['base'] as String? ?? 'neutral',
        accent: config['accent'] as String?,
        style: config['style'] as String? ?? 'standard',
      );
      final kept = config['preset'] as String?;
      final givenPreset = option('preset');
      try {
        if (givenPreset != null && givenPreset != 'none') {
          preset = ThemePreset.parse(givenPreset);
        } else if (kept != null && givenPreset != 'none') {
          preset = ThemePreset.parse(kept);
        }
      } on FormatException catch (e) {
        o.writeln(
          givenPreset != null
              ? '--preset: ${e.message}'
              : 'The preset in ashlar.yaml: ${e.message} Give --preset again, or --preset none.',
        );
        return 64;
      }
      final given = option('accent');
      preset = preset.withChoices(
        base: option('base'),
        accent: given == 'none' ? null : given,
        noAccent: given == 'none',
        style: option('style'),
      );
      if (givenPreset == 'none') {
        preset = ThemePreset(
          base: preset.base,
          accent: preset.accent,
          style: preset.style,
        );
      }
      final base = preset.base, accent = preset.accent, style = preset.style;
      if (!_checkTheme(base, accent, style, o)) return 64;
      if (option('prefix') case final given?) {
        final prefix = given == 'none' ? null : given;
        if (prefix != null && !validPrefix.hasMatch(prefix)) {
          o.writeln(
            'A prefix is a capital, then letters or digits: SL, Mz, Acme.',
          );
          return 64;
        }
        project.renamePrefix(prefix, o);
      }
      project.save({
        'base': base,
        'accent': accent,
        'style': style,
        'preset': preset.changed ? preset.code : null,
      });
      // The palette came after some projects began: add it if it is not there.
      final code = await project.add(['theme'], overwrite: false, out: o);
      if (code != 0) return code;
      writeAppTheme(
        root,
        project.path,
        prefix: project.prefix,
        preset: preset,
        out: o,
      );
      // The rules name the components under the prefix: write them again.
      if (project.config['agents'] != false) {
        writeAgentRules(
          root,
          agentRules(
            path: project.path,
            tests: project.tests ?? 'test/ashlar',
            named: project.named,
          ),
          o,
        );
      }
      o.writeln(
        'Theme: $base${accent == null ? '' : ', $accent'}, $style'
        '${preset.changed ? ', and the preset\'s changes' : ''}. Your components are as they were.',
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
        tests: !rest.contains('--no-tests'),
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
        if (c.tests.isNotEmpty) {
          // AshlarApp and the theme come with init; name only what else the tests use.
          final uses = c.testNeeds.where((n) => n != 'app' && n != 'theme');
          o.writeln(
            '  with its tests: ${c.tests.keys.join(', ')}${uses.isEmpty ? '' : ', which also use ${uses.join(', ')}'}',
          );
        }
        for (final MapEntry(key: file, value: source) in c.files.entries) {
          final shown = project.written(c, source);
          o
            ..writeln('\n── $file (${shown.split('\n').length} lines)')
            ..writeln(shown);
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
    case 'book':
      return project.book(o);
    case 'mcp':
      return serveStdio(root);
    case 'check':
      return project.check(contrast: !rest.contains('--no-contrast'), out: o);
    case 'shot':
      if (words.isEmpty) {
        o.writeln(
          'Name what to draw: a Dart file in the app, and its widget if it has several, as lib/screens/home.dart:HomeScreen. A file under test can wrap a screen in what it needs (providers, a route) to be drawn.',
        );
        return 64;
      }
      final targets = <ShotTarget>[];
      for (final w in words) {
        final t = resolveShot(root, w);
        if (t is String) {
          o.writeln(t);
          return 64;
        }
        targets.add(t as ShotTarget);
      }
      final sizes = (option('size') ?? 'phone').split(',');
      for (final s in sizes) {
        if (!shotSizes.containsKey(s) && !RegExp(r'^\d+x\d+$').hasMatch(s)) {
          o.writeln(
            '--size $s: name ${shotSizes.keys.join(', ')}, or a size as 390x844; several with commas.',
          );
          return 64;
        }
      }
      final scale = double.tryParse(option('scale') ?? '2') ?? 2;
      final darks = rest.contains('--both')
          ? [false, true]
          : [rest.contains('--dark')];
      return drawShots(
        root: root,
        package: project.package ?? '',
        path: project.path,
        targets: targets,
        sizes: sizes,
        darks: darks,
        out: option('out') ?? '.ashlar/shots',
        scale: scale,
        center: rest.contains('--center'),
        named: project.named,
        o: o,
      );
    case 'diff':
      return await project.diff(words, o);
    case 'update':
      return project.update(
        words,
        dryRun: rest.contains('--dry-run'),
        preview: rest.contains('--preview'),
        out: o,
      );
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

/// Writes the chosen theme to [path]/app_theme.dart, for AshlarApp to use: the preset's
/// base, accent and style, and whatever it changes on top of them.
void writeAppTheme(
  Directory root,
  String path, {
  required ThemePreset preset,
  String? prefix,
  required StringSink out,
}) {
  final text = preset.appThemeDart();
  File('${root.path}/$path/app_theme.dart').writeAsStringSync(
    prefix == null ? text : withPrefix(text, prefixedNames(prefix)),
  );
  out.writeln('  wrote  $path/app_theme.dart');
}

/// [given] as a folder from the project root, without a trailing slash; null when it
/// is not one inside the project.
String? _folder(String given) {
  final folder = given.replaceAll(RegExp(r'^\./|/+$'), '');
  final parts = folder.split('/');
  if (folder.isEmpty ||
      folder.startsWith('/') ||
      folder.contains(r'\') ||
      parts.any((p) => p.isEmpty || p == '.' || p == '..')) {
    return null;
  }
  return folder;
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

  /// The choices made for this project: where things go, the theme, registries.
  File get _file => File('${root.path}/ashlar.yaml');

  /// What ashlar wrote, by path: a fingerprint of each file, beside the copies in
  /// .ashlar/base. Machine-written; commit it with the copies.
  File get _files => File('${root.path}/.ashlar/files.json');

  Map<String, dynamic> get config {
    if (!_file.existsSync()) return <String, dynamic>{};
    final yaml = loadYaml(_file.readAsStringSync());
    return yaml is YamlMap
        ? _plain(yaml) as Map<String, dynamic>
        : <String, dynamic>{};
  }

  /// Sets [values] in ashlar.yaml, a null removing its key; the rest of the file, its
  /// comments too, is left as it was.
  void save(Map<String, Object?> values) {
    final existing = _file.existsSync() ? _file.readAsStringSync() : '';
    // From nothing: a block, with a word on what the file is.
    if (existing.trim().isEmpty) {
      final all = <String, dynamic>{
        ...config,
        for (final e in values.entries)
          if (e.value != null) e.key: e.value,
      };
      _file.writeAsStringSync(
        '# Ashlar UI: where components go and how they look. ashlar init and apply\n'
        '# change these, and so can you.\n${_block(all)}',
      );
      return;
    }
    final edit = YamlEditor(existing);
    final top = edit.parseAt([]);
    for (final MapEntry(:key, :value) in values.entries) {
      if (value != null) {
        edit.update([key], value);
      } else if (top is YamlMap && top.containsKey(key)) {
        edit.remove([key]);
      }
    }
    final text = edit.toString();
    _file.writeAsStringSync(text.endsWith('\n') ? text : '$text\n');
  }

  /// [map] as block YAML, for a file written from nothing.
  static String _block(Map<String, dynamic> map, [String indent = '']) {
    final out = StringBuffer();
    for (final MapEntry(:key, :value) in map.entries) {
      if (value is Map) {
        out
          ..writeln('$indent$key:')
          ..write(_block(value.cast<String, dynamic>(), '$indent  '));
      } else {
        out.writeln('$indent$key: ${value is String ? _scalar(value) : value}');
      }
    }
    return out.toString();
  }

  /// A string as YAML writes it, quoted only when it must be.
  static String _scalar(String s) =>
      RegExp(r'^[\w./@-][\w./@ -]*$').hasMatch(s) &&
          s.trim() == s &&
          !const {
            'true',
            'false',
            'null',
            'yes',
            'no',
            'on',
            'off',
          }.contains(s.toLowerCase())
      ? s
      : jsonEncode(s);

  /// YAML read into plain maps and lists.
  static Object? _plain(Object? node) => switch (node) {
    YamlMap m => <String, dynamic>{
      for (final e in m.entries) '${e.key}': _plain(e.value),
    },
    YamlList l => [for (final v in l) _plain(v)],
    _ => node,
  };

  /// The project's own prefix on the components' names, if it has one: SL for SLButton.
  String? get prefix => config['prefix'] as String?;

  /// Each component name and its name here, under the prefix; none without one.
  late final Map<String, String> _names = prefix == null
      ? const {}
      : prefixedNames(prefix!);

  /// A component's name as this project has it: SLButton for Button under SL.
  String named(String name) => _names[name] ?? name;

  /// Renames the components to [to] (none for null) everywhere: the files ashlar wrote,
  /// its copies of them, and every use in the app's own code under lib and test, so the
  /// app still builds. Only code is renamed, never strings or prose.
  void renamePrefix(String? to, StringSink out) {
    final from = prefix;
    if (from == to) return;
    final before = from == null ? null : prefixedNames(from);
    final after = to == null ? null : prefixedNames(to);
    final names = before?.keys ?? after!.keys;
    // Each name as it is now, to the name it becomes.
    final map = <String, String>{};
    for (final n in names) {
      final was = before?[n] ?? n, becomes = after?[n] ?? n;
      if (was != becomes) map[was] = becomes;
    }
    var changed = 0;
    for (final folder in ['lib', 'test', '.ashlar/base']) {
      final d = Directory('${root.path}/$folder');
      if (!d.existsSync()) continue;
      for (final f in d.listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        final text = f.readAsStringSync();
        final renamed = withPrefix(text, map);
        if (renamed != text) {
          f.writeAsStringSync(renamed);
          changed++;
        }
      }
    }
    // The fingerprints follow the copies they are of.
    final fingerprints = Map<String, String>.of(_written);
    for (final at in fingerprints.keys.toList()) {
      if (_base(at).existsSync()) {
        fingerprints[at] = fingerprint(_base(at).readAsStringSync());
      }
    }
    _saveWritten(fingerprints);
    save({'prefix': to});
    out.writeln(
      to == null
          ? 'Prefix taken away: ${map.length} names, in $changed files.'
          : 'Prefix $to: ${map.length} names renamed in $changed files, yours included.',
    );
  }

  /// Where components go, from the project root.
  String get path => config['path'] as String? ?? 'lib/ui';

  /// Where blocks go: ashlar.yaml's blocks, or a blocks folder beside the components.
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
  String written(Component c, String source) => withPrefix(
    c.block
        ? source.replaceAll(
            "import '../ui/",
            "import '${_relative(blocks, path)}/",
          )
        : source,
    _names,
  );

  /// Where components' tests go: ashlar.yaml's tests, or test/ashlar; null when it
  /// says false.
  String? get tests {
    final set = config['tests'];
    if (set == false) return null;
    return set is String ? set : 'test/ashlar';
  }

  /// The project's package name, from pubspec.yaml.
  /// The app's name, as pubspec.yaml gives it.
  String? get package => _package;

  String? get _package => RegExp(
    r'^name:\s*(\S+)',
    multiLine: true,
  ).firstMatch(File('${root.path}/pubspec.yaml').readAsStringSync())?[1];

  /// A test's [source] as it is written into this project: its imports point at the
  /// components in this package. Null when the components are not under lib, where a
  /// test cannot import them from.
  String? testSource(String source) {
    final package = _package;
    if (!path.startsWith('lib/') || package == null) return null;
    return withPrefix(
      source.replaceAll(
        'package:ashlar_ui_gallery/ui/',
        'package:$package/${path.substring(4)}/',
      ),
      _names,
    );
  }

  /// Where each of [c]'s files lands here, as ashlar writes it: its source files, then
  /// its tests.
  Iterable<({String at, String text, bool test})> _placed(Component c) sync* {
    for (final MapEntry(key: file, value: source) in c.files.entries) {
      yield (at: target(c, file), text: written(c, source), test: false);
    }
    final dir = tests;
    if (dir == null) return;
    for (final MapEntry(key: file, value: source) in c.tests.entries) {
      final text = testSource(source);
      if (text != null) yield (at: '$dir/$file', text: text, test: true);
    }
  }

  bool has(Component c) => c.files.keys.every(
    (f) => File('${root.path}/${target(c, f)}').existsSync(),
  );

  /// The fingerprints of the files as ashlar wrote them, by path.
  Map<String, String> get _written => _files.existsSync()
      ? (jsonDecode(_files.readAsStringSync()) as Map<String, dynamic>)
            .cast<String, String>()
      : <String, String>{};

  void _saveWritten(Map<String, String> fingerprints) => _files
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(Map.fromEntries(fingerprints.entries.toList()..sort((a, b) => a.key.compareTo(b.key))))}\n',
    );

  /// Another registry: from ashlar.yaml's registries.
  Remote? _remote(String namespace, StringSink out) {
    final at = (config['registries'] as Map<String, dynamic>? ?? {})[namespace];
    if (at is! String) {
      out.writeln(
        'No registry $namespace. Name it in ashlar.yaml, under registries: "$namespace": https://…/r',
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

  /// Copies [names] and what they need, with their [tests], and adds the packages they
  /// use.
  Future<int> add(
    List<String> names, {
    required bool overwrite,
    required StringSink out,
    bool tests = true,
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
        _keep(at, text);
        out.writeln('  wrote  $at');
      }
    }
    if (tests) _addTests(order, overwrite, fingerprints, out);
    if (fingerprints.isNotEmpty) _saveWritten(fingerprints);
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

  /// Writes the tests of the components you have whose tests can now run: those of
  /// [added], and those that were waiting for a component just added. A test written
  /// before is not written again, even if you deleted it, unless its component is
  /// added again with [overwrite].
  void _addTests(
    List<String> added,
    bool overwrite,
    Map<String, String> fingerprints,
    StringSink out,
  ) {
    final dir = tests;
    if (dir == null) return;
    for (final MapEntry(key: name, value: c) in registry.entries) {
      if (c.tests.isEmpty || !has(c)) continue;
      final adding = added.contains(name);
      final waiting = c.testNeeds.where((n) => !has(registry[n]!)).toList();
      for (final MapEntry(key: file, value: source) in c.tests.entries) {
        final at = '$dir/$file';
        final f = File('${root.path}/$at');
        if ((f.existsSync() || fingerprints.containsKey(at)) &&
            !(adding && overwrite)) {
          continue;
        }
        if (waiting.isNotEmpty) {
          if (adding) {
            out.writeln('  later  $at, once you have ${waiting.join(', ')}');
          }
          continue;
        }
        final text = testSource(source);
        if (text == null) {
          if (adding) {
            out.writeln(
              '  no     $at: a test imports components from lib, and $path is not in it',
            );
          }
          continue;
        }
        f.parent.createSync(recursive: true);
        f.writeAsStringSync(text);
        fingerprints[at] = fingerprint(text);
        _keep(at, text);
        out.writeln('  wrote  $at');
      }
    }
  }

  /// [texts] (Dart sources, by a name ending in .dart) as dart format lays them out in
  /// this app, with its analysis_options.yaml: its line length and style. Formatted in a
  /// folder inside the app so its settings apply; as they were if dart format cannot run.
  Future<Map<String, String>> _inYourStyle(Map<String, String> texts) async {
    if (texts.isEmpty) return texts;
    final dir = Directory('${root.path}/.ashlar/format');
    try {
      for (final MapEntry(key: name, value: text) in texts.entries) {
        File('${dir.path}/$name')
          ..createSync(recursive: true)
          ..writeAsStringSync(text);
      }
      final fvm = File('${root.path}/.fvmrc').existsSync();
      final cmd = [if (fvm) 'fvm', 'dart', 'format', '.ashlar/format'];
      final result = await Process.run(
        cmd.first,
        cmd.skip(1).toList(),
        workingDirectory: root.path,
        runInShell: true,
      );
      if (result.exitCode != 0) return texts;
      return {
        for (final name in texts.keys)
          name: File('${dir.path}/$name').readAsStringSync(),
      };
    } on ProcessException {
      return texts;
    } finally {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    }
  }

  /// A copy of [at] as ashlar wrote it, for [update] to merge from.
  File _base(String at) => File('${root.path}/.ashlar/base/$at');

  void _keep(String at, String text) => _base(at)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(text);

  /// Brings the items you have (or those named) up to this version: a file you have not
  /// changed is replaced; one you have is merged with this version's, line by line, from
  /// the copy ashlar wrote; where you and this version changed the same lines, both are
  /// kept between conflict markers for you to choose. Items they now need are added.
  Future<int> update(
    List<String> names, {
    required bool dryRun,
    required StringSink out,
    bool preview = false,
  }) async {
    // A preview changes nothing: it draws what would change.
    if (preview) dryRun = true;
    final would = <String, String>{};
    final unsure = <String>{};
    final unknown = names.where((n) => !registry.containsKey(n)).toList();
    if (unknown.isNotEmpty) {
      out.writeln('No component named ${unknown.join(', ')}.');
      return 64;
    }
    final chosen = names.isEmpty
        ? registry.keys.where((n) => has(registry[n]!)).toList()
        : names;
    final fingerprints = Map<String, String>.of(_written);
    var took = 0, merged = 0, conflicts = 0, kept = 0;
    // What each file needs merged from: what ashlar wrote, and what it writes now.
    final pending = <({String at, String yours, String base, String latest})>[];
    for (final name in chosen) {
      final c = registry[name]!;
      for (final (:at, text: latest, test: _) in _placed(c)) {
        final f = File('${root.path}/$at');
        if (!f.existsSync()) continue;
        final yours = f.readAsStringSync();
        if (yours == latest) continue;
        // What ashlar wrote: kept since this version of ashlar; before that, the file
        // itself if it is as written.
        final base = _base(at).existsSync()
            ? _base(at).readAsStringSync()
            : (fingerprint(yours) == _written[at] ? yours : null);
        if (base == null) {
          out.writeln(
            '  kept   $at: changed by you, and there is no copy of what ashlar wrote to merge from. ashlar diff $name shows the lines.',
          );
          kept++;
          continue;
        }
        if (base == latest) continue;
        pending.add((at: at, yours: yours, base: base, latest: latest));
      }
    }
    // Both laid out as the app lays out its code, so a different line length or style is
    // not taken for a change of yours.
    final styled = await _inYourStyle({
      for (final p in pending) ...{
        'base/${p.at}': p.base,
        'latest/${p.at}': p.latest,
        'yours/${p.at}': p.yours,
      },
    });
    for (final p in pending) {
      final at = p.at, yours = p.yours, latest = p.latest;
      final base = styled['base/$at']!, now = styled['latest/$at']!;
      // Yours, laid out by your formatter too: a file never formatted is not a change.
      final own = styled['yours/$at']!;
      final String text;
      if (own == now) {
        // Already as this version writes it.
        text = yours;
      } else if (own == base) {
        text = now;
        took++;
        out.writeln('  took   $at');
      } else {
        final m = merge3(base, own, now);
        text = m.text;
        if (m.conflicts > 0) {
          unsure.add(at);
          conflicts += m.conflicts;
          out.writeln(
            '  merged $at, ${m.conflicts} place${m.conflicts == 1 ? '' : 's'} to choose: between <<<<<<< yours and >>>>>>> ashlar',
          );
        } else {
          merged++;
          out.writeln('  merged $at, your changes kept');
        }
      }
      if (text != yours) would[at] = text;
      if (dryRun) continue;
      if (text != yours) File('${root.path}/$at').writeAsStringSync(text);
      fingerprints[at] = fingerprint(latest);
      _keep(at, latest);
    }
    if (!dryRun) {
      _saveWritten(fingerprints);
      // What the updated items need now and the project does not have.
      final needed = resolve(chosen).where((n) => !has(registry[n]!)).toList();
      if (needed.isNotEmpty) {
        out.writeln('  adding what they now need: ${needed.join(', ')}');
        final code = await add(needed, overwrite: false, out: out);
        if (code != 0) return code;
      }
    }
    if (preview) await _review(chosen, would, unsure, out);
    final changed = took + merged + conflicts;
    out.writeln(
      changed == 0 && kept == 0
          ? 'Everything is up to date.'
          : '${dryRun ? 'Would update' : 'Updated'}: $took taken, $merged merged, $conflicts to choose, $kept kept as they were.',
    );
    return conflicts > 0 ? 1 : 0;
  }

  /// Writes a catalog of the components the app has, in its theme, to run as an app.
  int book(StringSink out) {
    final items = <ReviewItem>[
      for (final MapEntry(key: name, value: c) in registry.entries)
        if (!c.block && c.preview != null && has(c))
          (name: name, widget: named(c.previewWidget!), preview: c.preview!),
    ];
    final r = writeBook(
      root: root,
      package: _package ?? '',
      path: path,
      items: items,
      named: named,
      rename: (s) => withPrefix(s, _names),
    );
    if (r.main == null) {
      out.writeln('No catalog: ${r.why}.');
      return 64;
    }
    final fvm = File('${root.path}/.fvmrc').existsSync();
    out
      ..writeln(
        'Your catalog of ${items.length} component${items.length == 1 ? '' : 's'}: ${r.main}',
      )
      ..writeln('Run it: ${fvm ? 'fvm ' : ''}flutter run -t ${r.main}');
    return 0;
  }

  /// Draws each of [chosen] that [would] changes, before and after; one with places to
  /// choose ([unsure]) is not drawn, since it does not build until they are chosen.
  Future<void> _review(
    List<String> chosen,
    Map<String, String> would,
    Set<String> unsure,
    StringSink out,
  ) async {
    final items = <ReviewItem>[];
    final undrawn = <String>[];
    for (final name in chosen) {
      final c = registry[name]!;
      final ats = [for (final f in c.files.keys) target(c, f)];
      if (!ats.any(would.containsKey)) continue;
      if (ats.any(unsure.contains) || c.preview == null || c.block) {
        undrawn.add(name);
        continue;
      }
      items.add((
        name: name,
        widget: named(c.previewWidget!),
        preview: c.preview!,
      ));
    }
    if (items.isEmpty) {
      out.writeln(
        undrawn.isEmpty
            ? 'Nothing to draw: no component would look different.'
            : 'Nothing drawn: ${undrawn.join(', ')} would change, with no picture to draw or places to choose first.',
      );
      return;
    }
    out.writeln(
      '  drawing ${items.length} component${items.length == 1 ? '' : 's'} before and after…',
    );
    final r = await drawReview(
      root: root,
      package: _package ?? '',
      path: path,
      after: would,
      items: items,
      named: named,
      rename: (s) => withPrefix(s, _names),
    );
    if (r.page != null) {
      out.writeln('Before and after, side by side: ${r.page}');
    } else {
      out.writeln('Could not draw them: ${r.why}');
    }
    if (undrawn.isNotEmpty) {
      out.writeln(
        'Not drawn, with places to choose first or no picture: ${undrawn.join(', ')}',
      );
    }
  }

  /// Finds what can be proved about the app's accessibility: the contrast of its theme,
  /// measured, if [contrast]; and in its source under lib, icon-only controls without a
  /// label, left and right where start and end belong, and touch targets turned off.
  /// Returns 1 when it finds something, for CI.
  Future<int> check({required bool contrast, required StringSink out}) async {
    final found = <Finding>[];
    final lib = Directory('${root.path}/lib');
    var files = 0;
    if (lib.existsSync()) {
      final dart =
          lib
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));
      for (final f in dart) {
        files++;
        found.addAll(
          checkSource(
            f.path.substring(root.path.length + 1),
            f.readAsStringSync(),
            button: named('Button'),
            toggle: named('Toggle'),
          ),
        );
      }
    }
    String? unmeasured;
    if (contrast) {
      final measured = await _measureContrast();
      if (measured case (final List<Finding> f, null)) found.insertAll(0, f);
      unmeasured = measured.$2;
    }
    for (final kind in [
      'contrast',
      'labels',
      'right to left',
      'touch targets',
    ]) {
      final these = found.where((f) => f.kind == kind).toList();
      if (these.isEmpty) continue;
      out.writeln(
        kind == 'contrast'
            ? 'Contrast, measured in $path/app_theme.dart:'
            : '${kind[0].toUpperCase()}${kind.substring(1)}:',
      );
      for (final f in these) {
        out.writeln(
          '  ${f.at.padRight(kind == 'contrast' ? 6 : 0)}  ${f.message}',
        );
      }
      out.writeln();
    }
    if (unmeasured != null) out.writeln('Contrast not measured: $unmeasured\n');
    out
      ..writeln(
        '${found.isEmpty ? 'Nothing found' : '${found.length} found'} in $files file${files == 1 ? '' : 's'} under lib${contrast && unmeasured == null ? ' and your theme' : ''}. A line that means it can say // ashlar: ignore.',
      )
      ..writeln(
        'Not checked, as source cannot show it: the size of your own tap areas, labels on your own controls, and contrast of colours you set outside the theme. A widget test with meetsGuideline(androidTapTargetGuideline) and labeledTapTargetGuideline checks a screen.',
      );
    return found.isEmpty ? 0 : 1;
  }

  /// Measures the theme in app_theme.dart with flutter test: the findings, or why it
  /// could not be measured.
  Future<(List<Finding>, String?)> _measureContrast() async {
    if (!File('${root.path}/$path/app_theme.dart').existsSync()) {
      return (
        <Finding>[],
        'there is no $path/app_theme.dart; ashlar init writes it.',
      );
    }
    final package = _package;
    if (!path.startsWith('lib/') || package == null) {
      return (
        <Finding>[],
        'the theme is not under lib, where a test can import it from.',
      );
    }
    final dir = Directory('${root.path}/.ashlar/check')
      ..createSync(recursive: true);
    final harness = File('${dir.path}/contrast_test.dart')
      ..writeAsStringSync(
        contrastHarness('package:$package/${path.substring(4)}'),
      );
    final fvm = File('${root.path}/.fvmrc').existsSync();
    final cmd = [
      if (fvm) 'fvm',
      'flutter',
      'test',
      '--reporter',
      'expanded',
      harness.path.substring(root.path.length + 1),
    ];
    try {
      final result = await Process.run(
        cmd.first,
        cmd.skip(1).toList(),
        workingDirectory: root.path,
        runInShell: true,
      );
      final output = '${result.stdout}';
      if (!output.contains('ASHLAR\t')) {
        final why = '${result.stdout}${result.stderr}'
            .split('\n')
            .where((l) => l.contains('Error') || l.contains('error'))
            .take(3)
            .join(' ');
        return (
          <Finding>[],
          '${cmd.join(' ')} did not run it${why.isEmpty ? '' : ': $why'}',
        );
      }
      return (contrastFindings(output), null);
    } on ProcessException {
      return (<Finding>[], '${cmd.first} could not be run here.');
    } finally {
      dir.deleteSync(recursive: true);
    }
  }

  /// For each item you have (or each named), whether your copy is as it was written,
  /// changed by you, or older than this version of ashlar's; with the lines that differ
  /// when items are named.
  Future<int> diff(List<String> names, StringSink out) async {
    final unknown = names.where((n) => !registry.containsKey(n)).toList();
    if (unknown.isNotEmpty) {
      out.writeln('No component named ${unknown.join(', ')}.');
      return 64;
    }
    final chosen = names.isEmpty
        ? registry.keys.where((n) => has(registry[n]!)).toList()
        : names;
    final found = <({String name, String at, String yours, String latest})>[];
    for (final name in chosen) {
      final c = registry[name]!;
      for (final (:at, text: latest, :test) in _placed(c)) {
        final f = File('${root.path}/$at');
        if (!f.existsSync()) {
          // A test not written, or deleted, is yours to leave out.
          if (!test) out.writeln('  $at: not added');
          continue;
        }
        final yours = f.readAsStringSync();
        if (yours != latest) {
          found.add((name: name, at: at, yours: yours, latest: latest));
        }
      }
    }
    // What ashlar wrote and writes now, laid out as the app lays out its code, so a
    // different line length is not taken for a change.
    final styled = await _inYourStyle({
      for (final x in found) ...{
        'latest/${x.at}': x.latest,
        'yours/${x.at}': x.yours,
        if (_base(x.at).existsSync())
          'base/${x.at}': _base(x.at).readAsStringSync(),
      },
    });
    var differing = 0;
    for (final (name: _, :at, :yours, latest: _) in found) {
      final now = styled['latest/$at']!, base = styled['base/$at'];
      // Yours, laid out by your formatter too: a file never formatted is not a change.
      final own = styled['yours/$at']!;
      if (own == now) continue;
      differing++;
      final then = _written[at];
      final mine = base != null
          ? own != base
          : then != null && fingerprint(yours) != then;
      final newer = base != null ? now != base : then == null;
      final what = switch ((mine, newer)) {
        (true, true) =>
          'changed by you, and newer here: ashlar update merges them',
        (true, false) => 'changed by you',
        (false, true) => 'newer here: ashlar update takes it',
        (false, false) => 'differs',
      };
      out.writeln('  $at: $what');
      if (names.isNotEmpty) {
        out.writeln(unifiedDiff(own, now, from: 'yours', to: 'this version'));
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
/// file for each, ready to host or to point ashlar.yaml at.
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
