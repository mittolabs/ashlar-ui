import 'dart:io';

import 'package:ashlar_ui/ashlar_ui.dart';

/// The same command `ashlar_ui` installs, under the name people type.
Future<void> main(List<String> args) async => exit(await run(args));
