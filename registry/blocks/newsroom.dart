// Ashlar UI block: newsroom. Copied into your app by `ashlar add newsroom`; it is yours to
// change. A newsroom's desk: its sections open their desks as menus from the sidebar, the
// morning brief's sign-up sits at its foot, and the page lists the desk's stories.
//
// The paper, its desks and stories are sample content, there to be replaced.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/avatar.dart';
import '../ui/badge.dart';
import '../ui/breadcrumb.dart';
import '../ui/button.dart';
import '../ui/card.dart';
import '../ui/dropdown_menu.dart';
import '../ui/input.dart';
import '../ui/popover.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/theme.dart';

/// The paper's sections, each with its icon and its desks.
const _sections = [
  ('News', AshlarIconsRoundedStroke.newspaper, ['City', 'Region', 'Politics']),
  (
    'Business',
    AshlarIconsRoundedStroke.briefcase,
    ['Markets', 'Farming', 'Tech'],
  ),
  (
    'Sport',
    AshlarIconsRoundedStroke.trophy,
    ['Football', 'Athletics', 'Rugby'],
  ),
  (
    'Opinion',
    AshlarIconsRoundedStroke.messageSquareQuote,
    ['Columns', 'Letters'],
  ),
  ('Life', AshlarIconsRoundedStroke.coffee, ['Food', 'Travel', 'Music']),
];

/// A newsroom whose sections open their desks as menus.
class Newsroom extends StatefulWidget {
  const Newsroom({super.key});

  @override
  State<Newsroom> createState() => _NewsroomState();
}

class _NewsroomState extends State<Newsroom> {
  var _desk = 'Farming';

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return SidebarLayout(
      collapse: SidebarCollapse.offcanvas,
      header: const _Paper(),
      groups: [
        SidebarGroup.custom(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (section, icon, desks) in _sections)
                DropdownMenu(
                  side: PopoverSide.right,
                  width: 192,
                  builder: (context, menu) => Button(
                    variant: ButtonVariant.ghost,
                    size: ButtonSize.sm,
                    expand: true,
                    onPressed: menu.open,
                    leading: AshlarIcon(icon),
                    trailing: const AshlarIcon(
                      AshlarIconsRoundedStroke.chevronRight,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        section,
                        style: t.text.sm.copyWith(
                          fontWeight: desks.contains(_desk)
                              ? FontWeight.w600
                              : null,
                        ),
                      ),
                    ),
                  ),
                  items: [
                    MenuLabel(child: Text(section)),
                    for (final desk in desks)
                      MenuItem(
                        selected: desk == _desk,
                        onPressed: () => setState(() => _desk = desk),
                        child: Text(desk),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
      footer: const _MorningBrief(),
      child: _Desk(
        section: _sections.firstWhere((s) => s.$3.contains(_desk)).$1,
        desk: _desk,
      ),
    );
  }
}

class _Paper extends StatelessWidget {
  const _Paper();

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
              AshlarIconsRoundedStroke.newspaper,
              color: c.sidebarPrimaryForeground,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The Harbor Post',
                  overflow: TextOverflow.ellipsis,
                  style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                ),
                Text('Newsroom', style: t.text.xs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A small card asking for a number to send the morning brief to.
class _MorningBrief extends StatelessWidget {
  const _MorningBrief();

  @override
  Widget build(BuildContext context) => Card(
    size: CardSize.sm,
    children: [
      const CardHeader(
        title: Text('The morning brief'),
        description: Text('Five stories before 6am, on WhatsApp.'),
      ),
      CardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Input(
              placeholder: 'Your WhatsApp number',
              semanticLabel: 'Phone number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            Button(
              size: ButtonSize.sm,
              variant: ButtonVariant.secondary,
              expand: true,
              onPressed: () {},
              child: const Text('Send it to me'),
            ),
          ],
        ),
      ),
    ],
  );
}

/// The desk's stories, newest first, each where it is on its way to print.
class _Desk extends StatelessWidget {
  const _Desk({required this.section, required this.desk});

  final String section;
  final String desk;

  static const _stories = [
    (
      'Wheat prices fall as the harvest comes in early',
      'Wairimu Ndungu',
      '10 min ago',
      'In review',
    ),
    (
      'Avocado growers find a new market overseas',
      'Jonah Price',
      '1 hr ago',
      'Draft',
    ),
    (
      'What the new water rules mean for small farms',
      'Wairimu Ndungu',
      '3 hrs ago',
      'Published',
    ),
    (
      'Coffee auction: a better week for growers',
      'Amina Yusuf',
      'Yesterday',
      'Published',
    ),
    ('A dairy co-op goes cashless', 'Elena Petrova', 'Yesterday', 'Published'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      BreadcrumbItem(section, onPressed: () {}),
                      BreadcrumbItem(desk),
                    ],
                  ),
                ),
                Button(
                  size: ButtonSize.sm,
                  leading: const AshlarIcon(AshlarIconsRoundedStroke.penLine),
                  onPressed: () {},
                  child: const Text('New story'),
                ),
              ],
            ),
          ),
        ),
        const Separator(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final (i, (headline, writer, ago, stage))
                  in _stories.indexed) ...[
                if (i > 0) const Separator(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              headline,
                              style: t.text.base.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Avatar(
                                  size: 20,
                                  fallback: writer
                                      .split(' ')
                                      .map((w) => w[0])
                                      .join(),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '$writer  ·  $ago',
                                    overflow: TextOverflow.ellipsis,
                                    style: t.text.xs.copyWith(
                                      color: c.mutedForeground,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Badge(
                        variant: switch (stage) {
                          'Published' => BadgeVariant.secondary,
                          'In review' => BadgeVariant.primary,
                          _ => BadgeVariant.outline,
                        },
                        child: Text(stage),
                      ),
                    ],
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
