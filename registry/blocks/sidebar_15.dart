// Ashlar UI block: sidebar-15. Copied into your app by `ashlar add sidebar-15`; it is yours
// to change. A sidebar on each side: pages on the left, folding away; a calendar and the
// calendars to show on the right, staying put.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/avatar.dart';
import '../ui/breadcrumb.dart';
import '../ui/button.dart';
import '../ui/calendar.dart';
import '../ui/checkbox.dart';
import '../ui/dropdown_menu.dart';
import '../ui/field.dart';
import '../ui/popover.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/theme.dart';

/// Sample pages and workspaces.
const _favorites = [
  'Project Management & Task Tracking',
  'Family Recipe Collection & Meal Planning',
  'Fitness Tracker & Workout Routines',
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
];

/// A sidebar on the left and another on the right.
class Sidebar15 extends StatefulWidget {
  const Sidebar15({super.key});

  @override
  State<Sidebar15> createState() => _Sidebar15State();
}

class _Sidebar15State extends State<Sidebar15> {
  var _day = DateTime(2026, 10, 13);

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
          'Settings',
          icon: AshlarIconsRoundedStroke.settings,
          onPressed: () {},
        ),
        SidebarItem(
          'Help',
          icon: AshlarIconsRoundedStroke.circleQuestionMark,
          onPressed: () {},
        ),
      ]),
    ],
    child: SidebarLayout(
      side: SidebarSide.end,
      collapse: SidebarCollapse.none,
      width: 288,
      narrow: 1024,
      header: const _NavUser(),
      groups: [
        SidebarGroup.custom(
          Calendar(selected: _day, onSelected: (d) => setState(() => _day = d)),
        ),
        const SidebarGroup.custom(Separator()),
        const SidebarGroup.custom(_Calendars()),
      ],
      footer: Button(
        variant: ButtonVariant.ghost,
        expand: true,
        leading: const AshlarIcon(AshlarIconsRoundedStroke.plus),
        onPressed: () {},
        child: const Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text('New Calendar'),
        ),
      ),
      child: _Page(trail: [_favorites.first]),
    ),
  );
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

/// Sample calendars, in groups.
const _calendars = [
  ('My Calendars', ['Personal', 'Work', 'Family']),
  ('Favorites', ['Holidays', 'Birthdays']),
  ('Other', ['Travel', 'Reminders', 'Deadlines']),
];

/// The calendars to show, by group, each group folding away.
class _Calendars extends StatefulWidget {
  const _Calendars();

  @override
  State<_Calendars> createState() => _CalendarsState();
}

class _CalendarsState extends State<_Calendars> {
  final _shown = {'Personal', 'Work', 'Holidays'};
  final _open = {'My Calendars'};

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (group, names) in _calendars) ...[
          Button(
            variant: ButtonVariant.ghost,
            size: ButtonSize.sm,
            expand: true,
            onPressed: () => setState(
              () => _open.contains(group)
                  ? _open.remove(group)
                  : _open.add(group),
            ),
            trailing: AnimatedRotation(
              turns: _open.contains(group) ? .25 : 0,
              duration: t.duration,
              child: AshlarIcon(
                isRtl(context)
                    ? AshlarIconsRoundedStroke.chevronLeft
                    : AshlarIconsRoundedStroke.chevronRight,
              ),
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(group),
            ),
          ),
          if (_open.contains(group))
            for (final name in names)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 12,
                  top: 4,
                  bottom: 4,
                ),
                child: Field(
                  axis: Axis.horizontal,
                  label: Text(name),
                  child: Checkbox(
                    value: _shown.contains(name),
                    onChanged: (v) => setState(
                      () => v ? _shown.add(name) : _shown.remove(name),
                    ),
                  ),
                ),
              ),
        ],
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
