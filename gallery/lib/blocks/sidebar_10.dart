// Ashlar UI block: sidebar-10. Copied into your app by `ashlar add sidebar-10`; it is yours
// to change. A notes app: search and the inbox at the top, favourites and workspaces under
// them, and the page's actions in a panel that opens from its header.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/breadcrumb.dart';
import '../ui/button.dart';
import '../ui/dropdown_menu.dart';
import '../ui/popover.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/theme.dart';

/// Sample pages and workspaces.
const _favorites = [
  'Project Management & Task Tracking',
  'Family Recipe Collection & Meal Planning',
  'Fitness Tracker & Workout Routines',
  'Book Notes & Reading List',
];
const _workspaces = [
  (
    'Personal Life Management',
    ['Daily Journal & Reflection', 'Health & Wellness Tracker'],
  ),
  (
    'Professional Development',
    ['Career Objectives & Milestones', 'Skill Acquisition Plan'],
  ),
  (
    'Creative Projects',
    ['Writing Ideas & Story Outlines', 'Art & Design Portfolio'],
  ),
];

/// A sidebar of pages, and the page's actions in a popover.
class Sidebar10 extends StatelessWidget {
  const Sidebar10({super.key});

  @override
  Widget build(BuildContext context) => SidebarLayout(
    header: const _TeamSwitcher(),
    groups: [
      SidebarGroup([
        SidebarItem(
          'Search',
          icon: AshlarIconsRoundedStroke.search,
          onPressed: () {},
        ),
        SidebarItem(
          'Ask AI',
          icon: AshlarIconsRoundedStroke.sparkles,
          onPressed: () {},
        ),
        SidebarItem(
          'Home',
          icon: AshlarIconsRoundedStroke.house,
          active: true,
          onPressed: () {},
        ),
        SidebarItem(
          'Inbox',
          icon: AshlarIconsRoundedStroke.inbox,
          badge: '10',
          onPressed: () {},
        ),
      ]),
      SidebarGroup(label: 'Favorites', [
        for (final page in _favorites)
          SidebarItem(
            page,
            icon: AshlarIconsRoundedStroke.fileText,
            onPressed: () {},
            action: SidebarAction(
              icon: AshlarIconsRoundedStroke.ellipsis,
              label: 'More for $page',
              onPressed: () {},
            ),
          ),
      ]),
      SidebarGroup(label: 'Workspaces', [
        for (final (name, pages) in _workspaces)
          SidebarItem(
            name,
            icon: AshlarIconsRoundedStroke.folder,
            children: [
              for (final page in pages)
                SidebarItem(page, icon: null, onPressed: () {}),
            ],
          ),
      ]),
      SidebarGroup(atEnd: true, [
        SidebarItem(
          'Calendar',
          icon: AshlarIconsRoundedStroke.calendar,
          onPressed: () {},
        ),
        SidebarItem(
          'Settings',
          icon: AshlarIconsRoundedStroke.settings,
          onPressed: () {},
        ),
        SidebarItem(
          'Templates',
          icon: AshlarIconsRoundedStroke.blocks,
          onPressed: () {},
        ),
        SidebarItem(
          'Trash',
          icon: AshlarIconsRoundedStroke.trash,
          onPressed: () {},
        ),
        SidebarItem(
          'Help',
          icon: AshlarIconsRoundedStroke.circleQuestionMark,
          onPressed: () {},
        ),
      ]),
    ],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const SidebarTrigger(),
                const SizedBox(width: 8),
                const SizedBox(
                  height: 16,
                  child: Separator(axis: Axis.vertical),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Breadcrumb(items: [BreadcrumbItem(_favorites.first)]),
                ),
                const _Actions(),
              ],
            ),
          ),
        ),
        const Expanded(child: _Placeholder()),
      ],
    ),
  );
}

/// When the page was edited, a star, and the page's actions in a popover.
class _Actions extends StatelessWidget {
  const _Actions();

  static const _groups = [
    [
      ('Customize Page', AshlarIconsRoundedStroke.settings),
      ('Turn into wiki', AshlarIconsRoundedStroke.fileText),
    ],
    [
      ('Copy Link', AshlarIconsRoundedStroke.link),
      ('Duplicate', AshlarIconsRoundedStroke.layers),
      ('Move to Trash', AshlarIconsRoundedStroke.trash),
    ],
    [
      ('View analytics', AshlarIconsRoundedStroke.chartLine),
      ('Version History', AshlarIconsRoundedStroke.clock),
      ('Notifications', AshlarIconsRoundedStroke.bell),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 768;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (wide)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: Text(
              'Edit Oct 08',
              style: t.text.sm.copyWith(color: t.colors.mutedForeground),
            ),
          ),
        Button(
          variant: ButtonVariant.ghost,
          size: ButtonSize.icon,
          semanticLabel: 'Add to favorites',
          onPressed: () {},
          child: const AshlarIcon(AshlarIconsRoundedStroke.star),
        ),
        Popover(
          align: PopoverAlign.end,
          width: 224,
          builder: (context, menu) => Button(
            variant: ButtonVariant.ghost,
            size: ButtonSize.icon,
            semanticLabel: 'Page actions',
            onPressed: menu.open,
            child: const AshlarIcon(AshlarIconsRoundedStroke.ellipsis),
          ),
          content: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, group) in _groups.indexed) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Separator(),
                  ),
                for (final (label, icon) in group)
                  Button(
                    variant: ButtonVariant.ghost,
                    size: ButtonSize.sm,
                    expand: true,
                    leading: AshlarIcon(icon),
                    onPressed: () {},
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(label),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The team you are working in, and a menu to change it.
class _TeamSwitcher extends StatefulWidget {
  const _TeamSwitcher();

  @override
  State<_TeamSwitcher> createState() => _TeamSwitcherState();
}

class _TeamSwitcherState extends State<_TeamSwitcher> {
  // Sample teams.
  static const _teams = [
    ('Acme Inc', 'Enterprise', AshlarIconsRoundedStroke.galleryVerticalEnd),
    ('Acme Corp.', 'Startup', AshlarIconsRoundedStroke.audioLines),
    ('Evil Corp.', 'Free', AshlarIconsRoundedStroke.command),
  ];
  var _team = 0;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final (name, plan, icon) = _teams[_team];
    return DropdownMenu(
      width: 224,
      builder: (context, menu) => Button(
        variant: ButtonVariant.ghost,
        expand: true,
        semanticLabel: 'Team: $name',
        onPressed: menu.open,
        trailing: const AshlarIcon(AshlarIconsRoundedStroke.chevronsUpDown),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: c.sidebarPrimary,
                borderRadius: BorderRadius.circular(t.radiusLg),
              ),
              child: AshlarIcon(icon, color: c.sidebarPrimaryForeground),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(plan, style: t.text.xs),
                ],
              ),
            ),
          ],
        ),
      ),
      items: [
        const MenuLabel(child: Text('Teams')),
        for (final (i, (name, _, icon)) in _teams.indexed)
          MenuItem(
            leading: AshlarIcon(icon),
            shortcut: Text('⌘${i + 1}'),
            onPressed: () => setState(() => _team = i),
            child: Text(name),
          ),
        const MenuSeparator(),
        MenuItem(
          leading: const AshlarIcon(AshlarIconsRoundedStroke.plus),
          onPressed: () {},
          child: const Text('Add team'),
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
