// Ashlar UI block: sidebar-12. Copied into your app by `ashlar add sidebar-12`; it is yours
// to change. A calendar app: who is signed in, a month to pick a day from, and the
// calendars to show.

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

/// A sidebar with a calendar.
class Sidebar12 extends StatefulWidget {
  const Sidebar12({super.key});

  @override
  State<Sidebar12> createState() => _Sidebar12State();
}

class _Sidebar12State extends State<Sidebar12> {
  var _day = DateTime(2026, 10, 13);

  @override
  Widget build(BuildContext context) {
    final names = DateNames.of(context);
    return SidebarLayout(
      collapse: SidebarCollapse.offcanvas,
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
      child: _Page(trail: [names.monthYear(_day), names.date(_day)]),
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
