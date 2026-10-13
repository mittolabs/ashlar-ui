// ashlar mcp: the ashlar command for coding agents, over the Model Context Protocol on
// standard input and output. Each tool runs the command a person would, so an agent sees
// what a person sees.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'cli.dart';

/// The version of ashlar_ui, as pubspec.yaml says.
const ashlarVersion = '0.1.0';

/// What the tools are, for tools/list.
const _tools = [
  {
    'name': 'search_components',
    'description':
        'Finds Ashlar UI components and blocks (whole screens) for Flutter by name or description; with no query, lists them all. A tick marks the ones this app has.',
    'inputSchema': {
      'type': 'object',
      'properties': {
        'query': {
          'type': 'string',
          'description': 'Words to look for, such as "date" or "menu".',
        },
      },
    },
  },
  {
    'name': 'view_component',
    'description':
        'Shows a component before adding it: what it is, what it needs, its tests, and its source, whose doc comments are its API and examples.',
    'inputSchema': {
      'type': 'object',
      'properties': {
        'name': {'type': 'string', 'description': 'Such as "button".'},
      },
      'required': ['name'],
    },
  },
  {
    'name': 'add_components',
    'description':
        'Copies components into this Flutter app, with the components they need, their tests in test/ashlar, and any package they need. A file the app already has is kept unless overwrite is true.',
    'inputSchema': {
      'type': 'object',
      'properties': {
        'names': {
          'type': 'array',
          'items': {'type': 'string'},
          'description': 'Such as ["button", "dialog"].',
        },
        'overwrite': {'type': 'boolean'},
      },
      'required': ['names'],
    },
  },
  {
    'name': 'update_components',
    'description':
        'Takes what is newer in this version of the components, keeping the app\'s own changes: merged line by line, with conflict markers where both changed the same lines. dry_run says what it would do.',
    'inputSchema': {
      'type': 'object',
      'properties': {
        'names': {
          'type': 'array',
          'items': {'type': 'string'},
          'description':
              'The components to update; all the app has if left out.',
        },
        'dry_run': {'type': 'boolean'},
      },
    },
  },
  {
    'name': 'check_app',
    'description':
        'Reports what can be proved about the app\'s accessibility: its theme\'s contrast, measured with flutter test, and in its source icon-only buttons without a label, physical left and right where start and end belong, and touch targets turned off.',
    'inputSchema': {
      'type': 'object',
      'properties': {
        'contrast': {
          'type': 'boolean',
          'description':
              'Measure the theme\'s contrast (slower); true unless false.',
        },
      },
    },
  },
];

/// Answers MCP requests read a line each from [input], writing a line each to [output],
/// for the app in [dir]. Ends when the input does.
Future<void> serveMcp(
  Stream<String> input,
  StringSink output, {
  Directory? dir,
}) async {
  final root = dir ?? Directory.current;
  void send(Map<String, Object?> message) =>
      output.writeln(jsonEncode({'jsonrpc': '2.0', ...message}));

  await for (final line in input) {
    if (line.trim().isEmpty) continue;
    final Object? id;
    final String method;
    final Map<String, dynamic> params;
    try {
      final m = jsonDecode(line) as Map<String, dynamic>;
      id = m['id'];
      method = m['method'] as String? ?? '';
      params = m['params'] as Map<String, dynamic>? ?? {};
    } on FormatException {
      send({
        'id': null,
        'error': {'code': -32700, 'message': 'Not JSON.'},
      });
      continue;
    }
    // A notification wants no answer.
    if (id == null) continue;
    switch (method) {
      case 'initialize':
        send({
          'id': id,
          'result': {
            'protocolVersion': params['protocolVersion'] ?? '2025-06-18',
            'capabilities': {'tools': <String, Object>{}},
            'serverInfo': {'name': 'ashlar', 'version': ashlarVersion},
            'instructions':
                'Ashlar UI: components for Flutter on the widgets layer, copied into the app as source it owns. Search, view a component\'s source and API, then add it; import it from the app\'s components folder (lib/ui unless ashlar.yaml says otherwise). The app needs ashlar init first, which a person runs.',
          },
        });
      case 'ping':
        send({'id': id, 'result': <String, Object>{}});
      case 'tools/list':
        send({
          'id': id,
          'result': {'tools': _tools},
        });
      case 'tools/call':
        final args = params['arguments'] as Map<String, dynamic>? ?? {};
        final command = _command(params['name'] as String? ?? '', args);
        if (command == null) {
          send({
            'id': id,
            'error': {
              'code': -32602,
              'message':
                  'No tool ${params['name']}, or its arguments are wrong.',
            },
          });
          continue;
        }
        final out = StringBuffer();
        final code = await run(command, dir: root, out: out);
        send({
          'id': id,
          'result': {
            'content': [
              {'type': 'text', 'text': '$out'.trimRight()},
            ],
            // 64 is a usage mistake; check's 1 means it found something, not a failure.
            'isError': code == 64 || (code != 0 && command.first != 'check'),
          },
        });
      default:
        send({
          'id': id,
          'error': {'code': -32601, 'message': 'No method $method.'},
        });
    }
  }
}

/// The ashlar command a tool call runs, or null when the call is wrong.
List<String>? _command(String tool, Map<String, dynamic> a) {
  List<String>? names(Object? v) =>
      v is List && v.every((n) => n is String) ? v.cast<String>() : null;
  switch (tool) {
    case 'search_components':
      return ['search', if (a['query'] case final String q) q];
    case 'view_component':
      final name = a['name'];
      return name is String ? ['view', name] : null;
    case 'add_components':
      final n = names(a['names']);
      if (n == null || n.isEmpty) return null;
      return ['add', ...n, if (a['overwrite'] == true) '--overwrite'];
    case 'update_components':
      final n = a.containsKey('names') ? names(a['names']) : <String>[];
      if (n == null) return null;
      return ['update', ...n, if (a['dry_run'] == true) '--dry-run'];
    case 'check_app':
      return ['check', if (a['contrast'] == false) '--no-contrast'];
  }
  return null;
}

/// Serves MCP on this process's standard input and output.
Future<int> serveStdio(Directory root) async {
  await serveMcp(
    stdin.transform(utf8.decoder).transform(const LineSplitter()),
    stdout,
    dir: root,
  );
  return 0;
}
