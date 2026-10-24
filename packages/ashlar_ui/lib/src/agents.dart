// What a coding agent should know about an app built with Ashlar UI, written by ashlar init
// (and kept current by ashlar apply) between markers in AGENTS.md, and in CLAUDE.md when
// the app has one. Everything outside the markers is the app's own.
import 'dart:io';

const _start =
    '<!-- ashlar: written by ashlar init and apply, and written again by them; keep notes of your own outside these lines -->';
const _end = '<!-- ashlar: end -->';

/// The rules, for components in [path], named as [named] gives them (under a prefix).
String agentRules({
  required String path,
  required String tests,
  required String Function(String) named,
}) {
  final theme = named('AshlarTheme');
  return '''
$_start
## Ashlar UI

This app's interface is built from Ashlar UI components, copied into `$path`: they are the
app's own code, to read and change.

- **Build from the components in `$path`**, not Material or Cupertino widgets: ${named('Button')},
  ${named('Input')}, ${named('Card')}, ${named('Dialog')} and the rest. `ashlar search <words>` finds one, with whole
  screens (blocks) among them; `ashlar view <name>` shows its source; `ashlar add <name>`
  copies it in with what it needs.
- **Take colours, text and corners from the theme**, never a colour written in the code:
  `final t = $theme.of(context);` then `t.colors.primary`, `t.colors.mutedForeground`,
  `t.text.sm`, `t.radiusMd`. The app's theme is `$path/app_theme.dart`.
- **Every control is a ${named('Pressable')}**, for hover, press, keyboard focus and a screen
  reader's label; an icon alone needs a `semanticLabel`.
- **Icons are ashlaricons**: `AshlarIcon(AshlarIconsRoundedStroke.plus)`.
- **Start and end, not left and right** (`EdgeInsetsDirectional`, `AlignmentDirectional`),
  so the app reads right to left too.
- **Look at what you built**: `ashlar shot lib/screens/home.dart --size phone,desktop --both`
  draws a screen to `.ashlar/shots/` without running the app and names any overflow with
  its line; read the pictures. A screen that needs providers or a route is drawn from a
  harness under `test/` that wraps it in them. `ashlar check` reports contrast and
  accessibility faults.
- **Each component's tests are in `$tests`**; run `flutter test` after changing one.
- `ashlar mcp` serves search, view, add, update, check and shot over MCP.
$_end
''';
}

/// Writes [rules] into AGENTS.md (made if missing), and into CLAUDE.md when the app has
/// one, replacing what an earlier run wrote between the markers.
void writeAgentRules(Directory root, String rules, StringSink out) {
  for (final name in ['AGENTS.md', 'CLAUDE.md']) {
    final f = File('${root.path}/$name');
    if (name == 'CLAUDE.md' && !f.existsSync()) continue;
    final had = f.existsSync() ? f.readAsStringSync() : '';
    final at = had.indexOf(_start), end = had.indexOf(_end);
    final String next;
    if (at >= 0 && end > at) {
      next =
          had.substring(0, at) +
          rules.trimRight() +
          had.substring(end + _end.length);
    } else {
      next = had.isEmpty
          ? '# AGENTS.md\n\n$rules'
          : '${had.trimRight()}\n\n$rules';
    }
    if (next == had) continue;
    f.writeAsStringSync(next);
    out.writeln('  wrote  $name (what coding agents should know)');
  }
}
