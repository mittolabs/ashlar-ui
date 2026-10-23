// Ashlar UI block: field-notes. Copied into your app by `ashlar add field-notes`; it is
// yours to change. A field officer's notes: today's visits and follow-ups at the top,
// pinned farms and the wards under them, the open note on the page, and its actions in a
// panel that opens from its header.
//
// The co-op, its farms and the note are sample content, there to be replaced.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/badge.dart';
import '../ui/breadcrumb.dart';
import '../ui/button.dart';
import '../ui/checkbox.dart';
import '../ui/popover.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/theme.dart';

/// Farms pinned to come back to.
const _pinned = [
  'Wairimu Njuguna, Githunguri',
  'Kamau dairy unit, Lari',
  'St. Mary\'s school garden',
];

/// The wards, each with the farms visited there.
const _wards = [
  ('Githunguri', ['Wairimu Njuguna', 'Peter Gitau', 'Ruth Wanjiku']),
  ('Limuru', ['Tea nursery, Tigoni', 'Samuel Mbugua']),
  ('Lari', ['Kamau dairy unit', 'Grace Nyambura']),
];

/// Field notes: the farms down the side, the open note on the page.
class FieldNotes extends StatelessWidget {
  const FieldNotes({super.key});

  @override
  Widget build(BuildContext context) => SidebarLayout(
    header: const _CoOp(),
    groups: [
      SidebarGroup([
        SidebarItem(
          'Search notes',
          icon: AshlarIconsRoundedStroke.search,
          onPressed: () {},
        ),
        SidebarItem(
          'Today\'s visits',
          icon: AshlarIconsRoundedStroke.mapPinned,
          active: true,
          onPressed: () {},
        ),
        SidebarItem(
          'Follow-ups',
          icon: AshlarIconsRoundedStroke.calendarClock,
          badge: '4',
          onPressed: () {},
        ),
      ]),
      SidebarGroup(label: 'Pinned', [
        for (final farm in _pinned)
          SidebarItem(
            farm,
            icon: AshlarIconsRoundedStroke.sprout,
            onPressed: () {},
            action: SidebarAction(
              icon: AshlarIconsRoundedStroke.ellipsis,
              label: 'More for $farm',
              onPressed: () {},
            ),
          ),
      ]),
      SidebarGroup(label: 'Wards', [
        for (final (i, (ward, farms)) in _wards.indexed)
          SidebarItem(
            ward,
            icon: AshlarIconsRoundedStroke.map,
            initiallyOpen: i == 0,
            children: [
              for (final farm in farms)
                SidebarItem(farm, icon: null, onPressed: () {}),
            ],
          ),
      ]),
      SidebarGroup(atEnd: true, [
        SidebarItem(
          'Photos',
          icon: AshlarIconsRoundedStroke.images,
          onPressed: () {},
        ),
        SidebarItem(
          'Settings',
          icon: AshlarIconsRoundedStroke.settings,
          onPressed: () {},
        ),
        SidebarItem(
          'Trash',
          icon: AshlarIconsRoundedStroke.trash,
          onPressed: () {},
        ),
      ]),
    ],
    child: const _Note(),
  );
}

class _CoOp extends StatelessWidget {
  const _CoOp();

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
              AshlarIconsRoundedStroke.leaf,
              color: c.sidebarPrimaryForeground,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Kilimo Bora Co-op',
                  overflow: TextOverflow.ellipsis,
                  style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                ),
                Text('Joseph Kariuki, field officer', style: t.text.xs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The open note: what was seen on the farm, what was advised, and when to come back.
class _Note extends StatefulWidget {
  const _Note();

  @override
  State<_Note> createState() => _NoteState();
}

class _NoteState extends State<_Note> {
  final _seen = [
    ('Maize at knee height, planted in rows', true),
    ('Fall armyworm on about one plant in ten', true),
    ('Two of the five cows due for deworming', false),
    ('Water tank half full after the rains', true),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(text, style: t.text.lg.copyWith(fontWeight: FontWeight.w600)),
    );
    return Column(
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
                  child: Breadcrumb(
                    items: [
                      BreadcrumbItem('Githunguri', onPressed: () {}),
                      const BreadcrumbItem('Wairimu Njuguna'),
                    ],
                  ),
                ),
                const _Actions(),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Wairimu Njuguna\'s farm', style: t.text.xxl),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: const [
                        Badge(
                          variant: BadgeVariant.outline,
                          child: Text('Visited Tue 30 June'),
                        ),
                        Badge(
                          variant: BadgeVariant.outline,
                          child: Text('2 acres'),
                        ),
                        Badge(
                          variant: BadgeVariant.outline,
                          child: Text('Maize and dairy'),
                        ),
                      ],
                    ),
                    heading('What I saw'),
                    for (final (i, (item, done)) in _seen.indexed)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Checkbox(
                              value: done,
                              semanticLabel: item,
                              onChanged: (v) =>
                                  setState(() => _seen[i] = (item, v)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(item, style: t.text.base)),
                          ],
                        ),
                      ),
                    heading('What I advised'),
                    Text(
                      'Spray the armyworm this week, early in the morning, and check the '
                      'funnels again in five days. Deworm the two cows before the vet\'s '
                      'next round. Keep the tank covered.',
                      style: t.text.base.copyWith(height: 1.6),
                    ),
                    heading('Come back'),
                    Text(
                      'Monday 6 July, to check the spraying worked.',
                      style: t.text.base.copyWith(color: c.mutedForeground),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// When the note was edited, a pin, and its actions in a popover.
class _Actions extends StatelessWidget {
  const _Actions();

  static const _groups = [
    [
      ('Send to the farmer by SMS', AshlarIconsRoundedStroke.messageSquare),
      ('Add a photo', AshlarIconsRoundedStroke.camera),
    ],
    [
      ('Copy link', AshlarIconsRoundedStroke.link),
      ('Move to another ward', AshlarIconsRoundedStroke.folderInput),
      ('Delete', AshlarIconsRoundedStroke.trash),
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
              'Edited 2 hours ago',
              style: t.text.sm.copyWith(color: t.colors.mutedForeground),
            ),
          ),
        Button(
          variant: ButtonVariant.ghost,
          size: ButtonSize.icon,
          semanticLabel: 'Pin this farm',
          onPressed: () {},
          child: const AshlarIcon(AshlarIconsRoundedStroke.pin),
        ),
        Popover(
          align: PopoverAlign.end,
          width: 240,
          builder: (context, menu) => Button(
            variant: ButtonVariant.ghost,
            size: ButtonSize.icon,
            semanticLabel: 'Note actions',
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
