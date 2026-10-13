import 'dart:convert';
import 'dart:io';

import 'component.dart';

/// Reading another registry went wrong: it was not there, or not what it should be.
class RemoteException implements Exception {
  RemoteException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A registry of someone's own, at a web address or in a folder, as `ashlar build` makes
/// it: registry.json listing the items, and an item's files in `name.json`.
class Remote {
  Remote(this.at, this.root);

  /// The address or folder, as ashlar.yaml gives it; a folder is from the project root.
  final String at;
  final Directory root;

  static final _name = RegExp(r'^[a-z0-9][a-z0-9_-]*$');

  bool get _web => at.startsWith('https://') || at.startsWith('http://');

  Future<String> _read(String file) async {
    if (_web) {
      final uri = Uri.parse('${at.endsWith('/') ? at : '$at/'}$file');
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);
      try {
        final response = await (await client.getUrl(uri)).close();
        final body = await response.transform(utf8.decoder).join();
        if (response.statusCode != 200) {
          throw RemoteException('$uri answered ${response.statusCode}');
        }
        return body;
      } on SocketException catch (e) {
        throw RemoteException('$uri: ${e.message}');
      } on HttpException catch (e) {
        throw RemoteException('$uri: ${e.message}');
      } finally {
        client.close();
      }
    }
    final dir = at.startsWith('/') ? at : '${root.path}/$at';
    final f = File('$dir/$file');
    if (!f.existsSync()) throw RemoteException('${f.path} is not there');
    return f.readAsString();
  }

  Future<Map<String, dynamic>> _json(String file) async {
    try {
      return jsonDecode(await _read(file)) as Map<String, dynamic>;
    } on FormatException {
      throw RemoteException('$file is not JSON');
    } on TypeError {
      throw RemoteException('$file is not a JSON object');
    }
  }

  /// The items it lists, by name, without their files.
  Future<Map<String, Component>> index() async {
    final json = await _json('registry.json');
    return {
      for (final item in (json['items'] as List? ?? const []).cast<Map>())
        if (item['name'] is String && _name.hasMatch(item['name'] as String))
          item['name'] as String: Component(
            description: '${item['description'] ?? ''}',
            files: const {},
            block: item['block'] == true,
          ),
    };
  }

  /// The item [name], with its files.
  Future<Component> item(String name) async {
    if (!_name.hasMatch(name)) {
      throw RemoteException('$name is not an item name');
    }
    final json = await _json('$name.json');
    final files = <String, String>{};
    for (final MapEntry(:key, :value)
        in (json['files'] as Map? ?? const {}).entries) {
      // A file goes in the components or blocks folder, never outside it.
      final path = '$key';
      if (path.startsWith('/') ||
          path.split('/').any((part) => part == '..' || part.isEmpty) ||
          value is! String) {
        throw RemoteException('$name has a file that cannot be written: $path');
      }
      files[path] = value;
    }
    return Component(
      description: '${json['description'] ?? ''}',
      files: files,
      requires: [for (final r in json['requires'] as List? ?? const []) '$r'],
      packages: [
        for (final p in json['packages'] as List? ?? const [])
          if (_name.hasMatch('$p')) '$p',
      ],
      block: json['block'] == true,
    );
  }
}
