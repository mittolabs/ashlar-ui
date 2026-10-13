// Ashlar UI block: sidebar-16. Copied into your app by `ashlar add sidebar-16`; it is yours
// to change. A site header across the top that stays as the page scrolls, and the sidebar
// under it.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/avatar.dart';
import '../ui/breadcrumb.dart';
import '../ui/button.dart';
import '../ui/dropdown_menu.dart';
import '../ui/input.dart';
import '../ui/popover.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/theme.dart';

/// Sample sections, each with its pages.
const _platform = [
  (
    'Playground',
    AshlarIconsRoundedStroke.terminal,
    ['History', 'Starred', 'Settings'],
  ),
  ('Models', AshlarIconsRoundedStroke.bot, ['Genesis', 'Explorer', 'Quantum']),
  (
    'Documentation',
    AshlarIconsRoundedStroke.bookOpen,
    ['Introduction', 'Get Started', 'Tutorials', 'Changelog'],
  ),
  (
    'Settings',
    AshlarIconsRoundedStroke.settings,
    ['General', 'Team', 'Billing', 'Limits'],
  ),
];

/// Sample projects.
const _projects = [
  ('Design Engineering', AshlarIconsRoundedStroke.frame),
  ('Sales & Marketing', AshlarIconsRoundedStroke.chartPie),
  ('Travel', AshlarIconsRoundedStroke.map),
];

/// A site header over a sidebar and its page.
class Sidebar16 extends StatefulWidget {
  const Sidebar16({super.key});

  @override
  State<Sidebar16> createState() => _Sidebar16State();
}

class _Sidebar16State extends State<Sidebar16> {
  // The header is above the sidebar, so its button reaches the sidebar by this key.
  final _sidebar = GlobalKey<SidebarLayoutState>();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 640;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Button(
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.icon,
                  semanticLabel: 'Toggle sidebar',
                  onPressed: () => _sidebar.currentState?.toggle(),
                  child: const AshlarIcon(AshlarIconsRoundedStroke.panelLeft),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  height: 16,
                  child: Separator(axis: Axis.vertical),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Breadcrumb(
                    items: [
                      BreadcrumbItem('Build Your App', onPressed: () {}),
                      const BreadcrumbItem('Data Fetching'),
                    ],
                  ),
                ),
                if (wide)
                  const SizedBox(
                    width: 240,
                    child: Input(
                      placeholder: 'Type to search…',
                      semanticLabel: 'Search',
                      leading: AshlarIcon(AshlarIconsRoundedStroke.search),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Separator(),
        Expanded(
          child: SidebarLayout(
            key: _sidebar,
            groups: [
              SidebarGroup(label: 'Platform', [
                for (final (i, (label, icon, pages)) in _platform.indexed)
                  SidebarItem(
                    label,
                    icon: icon,
                    initiallyOpen: i == 0,
                    children: [
                      for (final page in pages)
                        SidebarItem(page, icon: null, onPressed: () {}),
                    ],
                  ),
              ]),
              SidebarGroup(label: 'Projects', [
                for (final (label, icon) in _projects)
                  SidebarItem(label, icon: icon, onPressed: () {}),
              ]),
              SidebarGroup(atEnd: true, [
                SidebarItem(
                  'Support',
                  icon: AshlarIconsRoundedStroke.lifeBuoy,
                  onPressed: () {},
                ),
                SidebarItem(
                  'Feedback',
                  icon: AshlarIconsRoundedStroke.send,
                  onPressed: () {},
                ),
              ]),
            ],
            footer: const _NavUser(),
            child: const _Placeholder(),
          ),
        ),
      ],
    );
  }
}

/// Who is signed in, and a menu for their account.
class _NavUser extends StatelessWidget {
  const _NavUser();

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return DropdownMenu(
      side: PopoverSide.top,
      width: 224,
      builder: (context, menu) => Button(
        variant: ButtonVariant.ghost,
        expand: true,
        semanticLabel: 'Account: Wanjiru Kamau',
        onPressed: menu.open,
        trailing: const AshlarIcon(AshlarIconsRoundedStroke.chevronsUpDown),
        child: Row(
          children: [
            const Avatar(fallback: 'WK'),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wanjiru Kamau',
                    overflow: TextOverflow.ellipsis,
                    style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'wanjiru@solutech.co.ke',
                    overflow: TextOverflow.ellipsis,
                    style: t.text.xs.copyWith(color: c.mutedForeground),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      items: [
        MenuItem(
          leading: const AshlarIcon(AshlarIconsRoundedStroke.sparkles),
          onPressed: () {},
          child: const Text('Upgrade to Pro'),
        ),
        const MenuSeparator(),
        MenuItem(
          leading: const AshlarIcon(AshlarIconsRoundedStroke.badgeCheck),
          onPressed: () {},
          child: const Text('Account'),
        ),
        MenuItem(
          leading: const AshlarIcon(AshlarIconsRoundedStroke.creditCard),
          onPressed: () {},
          child: const Text('Billing'),
        ),
        MenuItem(
          leading: const AshlarIcon(AshlarIconsRoundedStroke.bell),
          onPressed: () {},
          child: const Text('Notifications'),
        ),
        const MenuSeparator(),
        MenuItem(
          leading: const AshlarIcon(AshlarIconsRoundedStroke.logOut),
          onPressed: () {},
          child: const Text('Log out'),
        ),
      ],
    );
  }
}

/// Grey shapes where the page's content goes.
class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final box = BoxDecoration(
      color: t.colors.muted.withValues(alpha: .5),
      borderRadius: BorderRadius.circular(t.radiusXl),
    );
    return LayoutBuilder(
      builder: (context, size) => size.maxWidth >= 768
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: 16),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: DecoratedBox(decoration: box),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SizedBox.expand(
                      child: DecoratedBox(decoration: box),
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (var i = 0; i < 3; i++) ...[
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: DecoratedBox(decoration: box),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(height: 480, child: DecoratedBox(decoration: box)),
              ],
            ),
    );
  }
}
