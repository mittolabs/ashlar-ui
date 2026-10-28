import 'dart:io';

/// The command moved to the ashlar package in 0.11.0. This says so, for one release.
void main(List<String> args) {
  stderr.writeln(
    'The ashlar command is now its own package. Install it with:\n\n'
    '  dart pub global deactivate ashlar_ui\n'
    '  dart pub global activate ashlar\n',
  );
  exit(64);
}
