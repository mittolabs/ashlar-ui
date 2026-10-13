// Tests every component as an app gets it: the files `ashlar add --all` copied into lib/ui.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nothing uses Material or Cupertino', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final f in files) {
      expect(
        f.readAsStringSync(),
        isNot(matches(RegExp(r"package:flutter/(material|cupertino)\.dart"))),
        reason: f.path,
      );
    }
    expect(
      File('pubspec.yaml').readAsStringSync(),
      isNot(contains('uses-material-design')),
    );
  });
}
