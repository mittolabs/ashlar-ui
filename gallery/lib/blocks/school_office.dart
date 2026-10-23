// Ashlar UI block: school-office. Copied into your app by `ashlar add school-office`; it
// is yours to change. A school office's app: the page set into the sidebar as a card,
// support and feedback at the sidebar's foot, and the term's fees on the page.
//
// The school, its pupils and fees are sample data, there to be replaced.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/avatar.dart';
import '../ui/badge.dart';
import '../ui/breadcrumb.dart';
import '../ui/button.dart';
import '../ui/card.dart';
import '../ui/dropdown_menu.dart';
import '../ui/popover.dart';
import '../ui/progress.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/theme.dart';

/// The office's sections, each with its pages.
const _sections = [
  (
    'Fees',
    AshlarIconsRoundedStroke.wallet,
    ['Balances', 'Payments in', 'Reminders'],
  ),
  (
    'Pupils',
    AshlarIconsRoundedStroke.users,
    ['All pupils', 'Admissions', 'Transfers'],
  ),
  (
    'Classes',
    AshlarIconsRoundedStroke.school,
    ['Timetable', 'Attendance', 'Teachers'],
  ),
  (
    'Exams',
    AshlarIconsRoundedStroke.clipboardCheck,
    ['Results', 'Report cards'],
  ),
];

/// The school's classes, to go straight to.
const _classes = ['Grade 4 East', 'Grade 5 West', 'Grade 6 East'];

/// A school office's app: the page inset as a card beside the sidebar.
class SchoolOffice extends StatelessWidget {
  const SchoolOffice({super.key});

  @override
  Widget build(BuildContext context) => SidebarLayout(
    variant: SidebarVariant.inset,
    header: const _School(),
    groups: [
      SidebarGroup(label: 'Office', [
        for (final (i, (label, icon, pages)) in _sections.indexed)
          SidebarItem(
            label,
            icon: icon,
            initiallyOpen: i == 0,
            children: [
              for (final (k, page) in pages.indexed)
                SidebarItem(
                  page,
                  icon: null,
                  active: i == 0 && k == 0,
                  onPressed: () {},
                ),
            ],
          ),
      ]),
      SidebarGroup(label: 'Classes', [
        for (final name in _classes)
          SidebarItem(
            name,
            icon: AshlarIconsRoundedStroke.bookBookmark,
            onPressed: () {},
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
    footer: const _Bursar(),
    child: const _Balances(),
  );
}

class _School extends StatelessWidget {
  const _School();

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
              AshlarIconsRoundedStroke.graduationCap,
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
                  'Maple Grove Elementary',
                  overflow: TextOverflow.ellipsis,
                  style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                ),
                Text('Term 2, 2026', style: t.text.xs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bursar extends StatelessWidget {
  const _Bursar();

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
        semanticLabel: 'Account: Helen Brooks',
        onPressed: menu.open,
        trailing: const AshlarIcon(AshlarIconsRoundedStroke.chevronsUpDown),
        child: Row(
          children: [
            const Avatar(fallback: 'HB'),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Helen Brooks',
                    overflow: TextOverflow.ellipsis,
                    style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Bursar',
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
          leading: const AshlarIcon(AshlarIconsRoundedStroke.circleUser),
          onPressed: () {},
          child: const Text('My account'),
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
          child: const Text('Sign out'),
        ),
      ],
    );
  }
}

/// The term's fees: how much is in, and who still owes.
class _Balances extends StatelessWidget {
  const _Balances();

  static const _owing = [
    ('Olivia Martin', 'Grade 5 West', 1850, 'Reminded Monday'),
    ('Diego Alvarez', 'Grade 4 East', 1200, 'Paying in parts'),
    ('Amina Abdi', 'Grade 6 East', 975, 'Not yet reminded'),
    ('Kevin Nguyen', 'Grade 4 East', 620, 'Promised by Friday'),
    ('Faith Chebet', 'Grade 5 West', 340, 'Not yet reminded'),
  ];

  static String _dollars(int v) =>
      '\$${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';

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
                      BreadcrumbItem('Fees', onPressed: () {}),
                      const BreadcrumbItem('Balances'),
                    ],
                  ),
                ),
                Button(
                  size: ButtonSize.sm,
                  variant: ButtonVariant.outline,
                  leading: const AshlarIcon(
                    AshlarIconsRoundedStroke.messageSquare,
                  ),
                  onPressed: () {},
                  child: const Text('Remind all'),
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
              Card(
                children: [
                  CardHeader(
                    description: const Text('Collected this term'),
                    title: Text('\$241,860', style: t.text.xxl),
                    action: const Badge(
                      variant: BadgeVariant.outline,
                      child: Text('78%'),
                    ),
                  ),
                  CardContent(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Progress(value: .78),
                        const SizedBox(height: 8),
                        Text(
                          '\$68,240 still owed by 41 families. Term ends 7 August.',
                          style: t.text.sm.copyWith(color: c.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                children: [
                  const CardHeader(
                    title: Text('Most owed'),
                    description: Text('The largest balances first'),
                  ),
                  CardContent(
                    child: Column(
                      children: [
                        for (final (i, (pupil, grade, owed, note))
                            in _owing.indexed) ...[
                          if (i > 0) const Separator(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Avatar(
                                  fallback: pupil
                                      .split(' ')
                                      .map((w) => w[0])
                                      .join(),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pupil,
                                        overflow: TextOverflow.ellipsis,
                                        style: t.text.sm.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '$grade  ·  $note',
                                        overflow: TextOverflow.ellipsis,
                                        style: t.text.xs.copyWith(
                                          color: c.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _dollars(owed),
                                  style: t.text.sm.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
