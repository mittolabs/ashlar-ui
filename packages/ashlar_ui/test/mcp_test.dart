// ashlar mcp, run as an agent runs it: a process spoken to on its standard input.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  late Directory dir;
  late Process server;
  late StreamIterator<String> replies;
  var next = 0;

  Future<Map<String, dynamic>> ask(
    String method, [
    Map<String, Object?> params = const {},
  ]) async {
    final id = ++next;
    server.stdin.writeln(
      jsonEncode({
        'jsonrpc': '2.0',
        'id': id,
        'method': method,
        'params': params,
      }),
    );
    await server.stdin.flush();
    expect(await replies.moveNext(), isTrue);
    final reply = jsonDecode(replies.current) as Map<String, dynamic>;
    expect(reply['id'], id);
    return reply;
  }

  Future<(String, bool)> call(String tool, Map<String, Object?> args) async {
    final r = await ask('tools/call', {'name': tool, 'arguments': args});
    final result = r['result'] as Map<String, dynamic>;
    return (
      ((result['content'] as List).single as Map)['text'] as String,
      result['isError'] as bool,
    );
  }

  setUpAll(() async {
    dir = Directory.systemTemp.createTempSync('ashlar_mcp_');
    File('${dir.path}/pubspec.yaml').writeAsStringSync(
      'name: shop\ndependencies:\n  flutter:\n    sdk: flutter\n  ashlar_icons: ^0.2.0\n',
    );
    server = await Process.start(Platform.resolvedExecutable, [
      'run',
      File('bin/ashlar.dart').absolute.path,
      'mcp',
    ], workingDirectory: dir.path);
    replies = StreamIterator(
      server.stdout.transform(utf8.decoder).transform(const LineSplitter()),
    );
  });

  tearDownAll(() async {
    await server.stdin.close();
    expect(await server.exitCode, 0);
    dir.deleteSync(recursive: true);
  });

  test('it says who it is and offers its tools', () async {
    final init = await ask('initialize', {
      'protocolVersion': '2025-06-18',
      'capabilities': {},
      'clientInfo': {'name': 'test', 'version': '1'},
    });
    final result = init['result'] as Map<String, dynamic>;
    expect(result['protocolVersion'], '2025-06-18');
    expect((result['serverInfo'] as Map)['name'], 'ashlar');
    // A notification has no answer: the next reply is the next request's.
    server.stdin.writeln(
      jsonEncode({'jsonrpc': '2.0', 'method': 'notifications/initialized'}),
    );
    final tools = await ask('tools/list');
    expect(
      ((tools['result'] as Map)['tools'] as List).map(
        (t) => (t as Map)['name'],
      ),
      [
        'search_components',
        'view_component',
        'add_components',
        'update_components',
        'check_app',
        'shot_screen',
      ],
    );
  });

  test('search, view and add, as the command does them', () async {
    final (found, _) = await call('search_components', {'query': 'swipe'});
    expect(found, contains('swipe-actions'));

    final (view, _) = await call('view_component', {'name': 'bottom-bar'});
    expect(view, contains('class BottomBar'));
    expect(view, contains('with its tests: bottom_bar_test.dart'));

    final (added, failed) = await call('add_components', {
      'names': ['bottom-bar'],
    });
    expect(failed, isFalse);
    expect(added, contains('wrote  lib/ui/bottom_bar.dart'));
    expect(File('${dir.path}/lib/ui/bottom_bar.dart').existsSync(), isTrue);
  });

  test('a check that finds something is an answer, not an error', () async {
    File(
      '${dir.path}/lib/home.dart',
    ).writeAsStringSync("const a = Text('Hi', textAlign: TextAlign.left);\n");
    final (text, failed) = await call('check_app', {'contrast': false});
    expect(failed, isFalse);
    expect(text, contains('lib/home.dart:1  TextAlign.left'));
  });

  test('mistakes come back as errors', () async {
    final (text, failed) = await call('view_component', {'name': 'nothing'});
    expect(failed, isTrue);
    expect(text, contains('No item named nothing'));
    final wrong = await ask('tools/call', {'name': 'delete_everything'});
    expect((wrong['error'] as Map)['code'], -32602);
    final unknown = await ask('resources/list');
    expect((unknown['error'] as Map)['code'], -32601);
  });
}
