// Ashlar UI block: clinic. Copied into your app by `ashlar add clinic`; it is yours to
// change. A clinic's app: its sidebar collapses to a strip of icons, a branch switcher
// at the top, its sections with their pages, the patients seen lately, and today's
// appointments on the page.
//
// The clinic, its patients and appointments are sample data, there to be replaced.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/avatar.dart';
import '../ui/badge.dart';
import '../ui/breadcrumb.dart';
import '../ui/button.dart';
import '../ui/card.dart';
import '../ui/dropdown_menu.dart';
import '../ui/popover.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/theme.dart';

/// The clinic's sections, each with its pages.
const _sections = [
  (
    'Appointments',
    AshlarIconsRoundedStroke.calendarDays,
    ['Today', 'This week', 'Waiting list'],
  ),
  (
    'Patients',
    AshlarIconsRoundedStroke.users,
    ['All patients', 'New patient', 'Referrals'],
  ),
  ('Lab', AshlarIconsRoundedStroke.flaskConical, ['Requests', 'Results']),
  (
    'Pharmacy',
    AshlarIconsRoundedStroke.pill,
    ['Prescriptions', 'Stock', 'Orders'],
  ),
  (
    'Billing',
    AshlarIconsRoundedStroke.receipt,
    ['Invoices', 'Insurance claims', 'Payments'],
  ),
];

/// Patients seen lately, to go back to.
const _recent = [
  ('Achieng Otieno', 'AO'),
  ('Daniel Kim', 'DK'),
  ('Fatuma Hassan', 'FH'),
];

/// A clinic's app: a sidebar that collapses to icons, each with its label in a tooltip.
class Clinic extends StatelessWidget {
  const Clinic({super.key});

  @override
  Widget build(BuildContext context) => SidebarLayout(
    header: const _Branches(),
    groups: [
      SidebarGroup(label: 'Clinic', [
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
      SidebarGroup(label: 'Seen lately', [
        for (final (name, _) in _recent)
          SidebarItem(
            name,
            icon: AshlarIconsRoundedStroke.circleUser,
            onPressed: () {},
            action: SidebarAction(
              icon: AshlarIconsRoundedStroke.ellipsis,
              label: 'More for $name',
              onPressed: () {},
            ),
          ),
      ]),
    ],
    footer: const _Doctor(),
    child: const _Today(),
  );
}

/// The branch you are working at, and a menu to change it.
class _Branches extends StatefulWidget {
  const _Branches();

  @override
  State<_Branches> createState() => _BranchesState();
}

class _BranchesState extends State<_Branches> {
  static const _branches = [
    ('Lakeside Family Clinic', 'Downtown'),
    ('Lakeside Family Clinic', 'Northgate'),
    ('Lakeside Family Clinic', 'Riverside'),
  ];
  var _branch = 0;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final (name, place) = _branches[_branch];
    return DropdownMenu(
      width: 224,
      builder: (context, menu) => Button(
        variant: ButtonVariant.ghost,
        expand: true,
        semanticLabel: 'Branch: $place',
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
              child: AshlarIcon(
                AshlarIconsRoundedStroke.hospital,
                color: c.sidebarPrimaryForeground,
              ),
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
                  Text(place, style: t.text.xs),
                ],
              ),
            ),
          ],
        ),
      ),
      items: [
        const MenuLabel(child: Text('Branches')),
        for (final (i, (_, place)) in _branches.indexed)
          MenuItem(
            leading: const AshlarIcon(AshlarIconsRoundedStroke.mapPin),
            shortcut: Text('⌘${i + 1}'),
            onPressed: () => setState(() => _branch = i),
            child: Text(place),
          ),
        const MenuSeparator(),
        MenuItem(
          leading: const AshlarIcon(AshlarIconsRoundedStroke.plus),
          onPressed: () {},
          child: const Text('Add a branch'),
        ),
      ],
    );
  }
}

/// The doctor signed in, and a menu for their account.
class _Doctor extends StatelessWidget {
  const _Doctor();

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
        semanticLabel: 'Account: Dr. Sarah Chen',
        onPressed: menu.open,
        trailing: const AshlarIcon(AshlarIconsRoundedStroke.chevronsUpDown),
        child: Row(
          children: [
            const Avatar(fallback: 'SC'),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. Sarah Chen',
                    overflow: TextOverflow.ellipsis,
                    style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'General practice',
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
          leading: const AshlarIcon(AshlarIconsRoundedStroke.circleUser),
          onPressed: () {},
          child: const Text('My profile'),
        ),
        MenuItem(
          leading: const AshlarIcon(AshlarIconsRoundedStroke.calendarClock),
          onPressed: () {},
          child: const Text('My hours'),
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

/// Today's appointments, in the order the patients are seen.
class _Today extends StatelessWidget {
  const _Today();

  static const _appointments = [
    ('8:30', 'Achieng Otieno', 'Follow-up, blood pressure', 'Done'),
    ('9:00', 'Daniel Kim', 'Blood test results', 'Done'),
    ('9:30', 'Fatuma Hassan', 'Antenatal visit', 'With the doctor'),
    ('10:00', 'Ethan Brooks', 'Sprained ankle', 'Waiting'),
    ('10:30', 'Sofia Rossi', 'Child immunisation', 'Waiting'),
    ('11:00', 'Raj Patel', 'Diabetes review', 'Booked'),
    ('11:30', 'Grace Liu', 'Skin rash', 'Booked'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return Column(
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
                const SizedBox(
                  height: 16,
                  child: Separator(axis: Axis.vertical),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Breadcrumb(
                    items: [
                      BreadcrumbItem('Appointments', onPressed: () {}),
                      const BreadcrumbItem('Today'),
                    ],
                  ),
                ),
                Button(
                  size: ButtonSize.sm,
                  leading: const AshlarIcon(AshlarIconsRoundedStroke.plus),
                  onPressed: () {},
                  child: const Text('Book'),
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
              Row(
                children: [
                  for (final (i, (label, value)) in [
                    ('Booked today', '18'),
                    ('Waiting now', '2'),
                    ('Seen', '9'),
                  ].indexed) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        size: CardSize.sm,
                        children: [
                          CardHeader(
                            description: Text(label),
                            title: Text(value, style: t.text.xxl),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Card(
                children: [
                  const CardHeader(
                    title: Text('Today'),
                    description: Text('Dr. Chen, room 2'),
                  ),
                  CardContent(
                    child: Column(
                      children: [
                        for (final (i, (time, patient, reason, status))
                            in _appointments.indexed) ...[
                          if (i > 0) const Separator(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 52,
                                  child: Text(
                                    time,
                                    style: t.text.sm.copyWith(
                                      color: c.mutedForeground,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                                Avatar(
                                  fallback: patient
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
                                        patient,
                                        overflow: TextOverflow.ellipsis,
                                        style: t.text.sm.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        reason,
                                        overflow: TextOverflow.ellipsis,
                                        style: t.text.xs.copyWith(
                                          color: c.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Badge(
                                  variant: switch (status) {
                                    'With the doctor' => BadgeVariant.primary,
                                    'Waiting' => BadgeVariant.secondary,
                                    _ => BadgeVariant.outline,
                                  },
                                  child: Text(status),
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
