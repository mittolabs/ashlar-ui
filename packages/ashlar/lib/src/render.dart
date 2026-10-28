// Drawing an app's widgets to pictures with flutter test, in the app's own fonts: what
// ashlar update --preview and ashlar shot share.
import 'dart:convert';
import 'dart:io';

/// The flutter command for the app at [root] (through fvm when it has a .fvmrc), and the
/// folder of Flutter's own Roboto, for text that names no font; '' when it cannot be found.
Future<(List<String> flutter, String fonts)> flutterFor(Directory root) async {
  final fvm = File('${root.path}/.fvmrc').existsSync();
  final flutter = [if (fvm) 'fvm', 'flutter'];
  var fonts = '';
  try {
    final v = await Process.run(
      flutter.first,
      [...flutter.skip(1), '--version', '--machine'],
      workingDirectory: root.path,
      runInShell: true,
    );
    final flutterRoot =
        (jsonDecode('${v.stdout}'.substring('${v.stdout}'.indexOf('{')))
            as Map)['flutterRoot'];
    fonts = '$flutterRoot/bin/cache/artifacts/material_fonts';
  } on Object {
    // Without it, text in the pictures is drawn in Flutter's test font, as boxes.
  }
  return (flutter, fonts);
}

/// Runs the test at [test] (a path from [root]) with [flutter], telling it where
/// Roboto is.
Future<ProcessResult> runDrawing(
  Directory root,
  List<String> flutter,
  String fonts,
  String test,
) => Process.run(
  flutter.first,
  [...flutter.skip(1), 'test', '--dart-define=FONTS=$fonts', test],
  workingDirectory: root.path,
  runInShell: true,
);

/// A test's function loading the app's fonts, and Roboto from Flutter itself for text that
/// names none, as source to write into it.
const fontsSource = r'''
/// The app's fonts, and Roboto from Flutter itself for text that names none.
Future<void> _fonts() async {
  final manifest = jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(family['family'] as String);
    for (final font in (family['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
  final roboto = FontLoader('Roboto');
  for (final w in ['Regular', 'Medium', 'Bold']) {
    final f = File('${const String.fromEnvironment('FONTS')}/Roboto-$w.ttf');
    if (f.existsSync()) roboto.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
  }
  await roboto.load();
  // Code names the family monospace, which a test has not got: the system's own, or Roboto
  // where there is none, so code reads as text rather than boxes.
  final mono = FontLoader('monospace');
  final found = [
    '/System/Library/Fonts/SFNSMono.ttf',
    '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf',
    '/usr/share/fonts/TTF/DejaVuSansMono.ttf',
    'C:/Windows/Fonts/consola.ttf',
    '${const String.fromEnvironment('FONTS')}/Roboto-Regular.ttf',
  ].map(File.new).where((f) => f.existsSync()).firstOrNull;
  if (found != null) {
    mono.addFont(Future.value(ByteData.sublistView(found.readAsBytesSync())));
    await mono.load();
  }
}
''';
