// Ashlar UI block: sidebar-13. Copied into your app by `ashlar add sidebar-13`; it is yours
// to change. Settings in a dialog: their sections down the side, the open one beside them.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/breadcrumb.dart';
import '../ui/button.dart';
import '../ui/dialog.dart';
import '../ui/separator.dart';
import '../ui/theme.dart';

/// Sample settings sections.
const _sections = [
  ('Notifications', AshlarIconsRoundedStroke.bell),
  ('Navigation', AshlarIconsRoundedStroke.menu),
  ('Home', AshlarIconsRoundedStroke.house),
  ('Appearance', AshlarIconsRoundedStroke.paintbrush),
  ('Messages & media', AshlarIconsRoundedStroke.messageCircle),
  ('Language & region', AshlarIconsRoundedStroke.globe),
  ('Accessibility', AshlarIconsRoundedStroke.keyboard),
  ('Mark as read', AshlarIconsRoundedStroke.check),
  ('Audio & video', AshlarIconsRoundedStroke.video),
  ('Connected accounts', AshlarIconsRoundedStroke.link),
  ('Privacy & visibility', AshlarIconsRoundedStroke.lock),
  ('Advanced', AshlarIconsRoundedStroke.settings),
];

/// A page with a button that opens the settings dialog.
class Sidebar13 extends StatelessWidget {
  const Sidebar13({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Button(
      onPressed: () => showAshlarDialog<void>(
        context: context,
        builder: (context) => const Dialog(maxWidth: 800, content: _Settings()),
      ),
      child: const Text('Open Dialog'),
    ),
  );
}

/// The settings: sections down the side where there is room, the open one beside them.
class _Settings extends StatefulWidget {
  const _Settings();

  @override
  State<_Settings> createState() => _SettingsState();
}

class _SettingsState extends State<_Settings> {
  var _section = 'Messages & media';

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final wide = MediaQuery.sizeOf(context).width >= 768;
    final box = BoxDecoration(
      color: c.muted.withValues(alpha: .5),
      borderRadius: BorderRadius.circular(t.radiusXl),
    );
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Breadcrumb(
          items: [
            BreadcrumbItem('Settings', onPressed: () {}),
            BreadcrumbItem(_section),
          ],
        ),
        const SizedBox(height: 12),
        const Separator(),
        const SizedBox(height: 16),
        for (var i = 0; i < 6; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: DecoratedBox(decoration: box),
          ),
        ],
      ],
    );
    if (!wide) return content;
    return SizedBox(
      height: 480,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 200,
            child: ListView(
              children: [
                for (final (name, icon) in _sections)
                  Button(
                    variant: name == _section
                        ? ButtonVariant.secondary
                        : ButtonVariant.ghost,
                    size: ButtonSize.sm,
                    expand: true,
                    leading: AshlarIcon(icon),
                    onPressed: () => setState(() => _section = name),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(name, overflow: TextOverflow.ellipsis),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: SingleChildScrollView(child: content)),
        ],
      ),
    );
  }
}
