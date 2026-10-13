// Ashlar UI block: sidebar-08. Copied into your app by `ashlar add sidebar-08`; it is yours
// to change. The page set into the sidebar as a card, with help and feedback kept at the
// sidebar's foot.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/avatar.dart';
import '../ui/breadcrumb.dart';
import '../ui/button.dart';
import '../ui/dropdown_menu.dart';
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

/// An inset sidebar, with secondary navigation at its foot.
class Sidebar08 extends StatelessWidget {
  const Sidebar08({super.key});

  @override
  Widget build(BuildContext context) => SidebarLayout(
    variant: SidebarVariant.inset,
    header: const _Brand(),
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
          SidebarItem(
            label,
            icon: icon,
            onPressed: () {},
            action: SidebarAction(
              icon: AshlarIconsRoundedStroke.ellipsis,
              label: 'More for $label',
              onPressed: () {},
            ),
          ),
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
    child: const _Page(trail: ['Build Your App', 'Data Fetching']),
  );
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: c.sidebarPrimary,
              borderRadius: BorderRadius.circular(t.radiusLg),
            ),
            child: AshlarIcon(
              AshlarIconsRoundedStroke.command,
              color: c.sidebarPrimaryForeground,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acme Inc',
                  overflow: TextOverflow.ellipsis,
                  style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                ),
                Text('Enterprise', style: t.text.xs),
              ],
            ),
          ),
        ],
      ),
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

/// The page beside the sidebar: the trigger and where you are along the top, and room
/// for your content under it.
class _Page extends StatelessWidget {
  const _Page({required this.trail});

  /// Where you are, from the top down; the last is this page.
  final List<String> trail;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const SidebarTrigger(),
              const SizedBox(width: 8),
              const SizedBox(height: 16, child: Separator(axis: Axis.vertical)),
              const SizedBox(width: 8),
              Expanded(
                child: Breadcrumb(
                  items: [
                    for (final (i, label) in trail.indexed)
                      BreadcrumbItem(
                        label,
                        onPressed: i == trail.length - 1 ? null : () {},
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const Separator(),
      const Expanded(child: _Placeholder()),
    ],
  );
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
