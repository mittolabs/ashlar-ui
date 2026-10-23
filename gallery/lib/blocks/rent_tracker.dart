// Ashlar UI block: rent-tracker. Copied into your app by `ashlar add rent-tracker`; it is
// yours to change. A letting agent's app: a header across the top that stays as the page
// scrolls, the sidebar under it, and this month's rent by unit on the page.
//
// The buildings, tenants and rent are sample data, there to be replaced.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/avatar.dart';
import '../ui/badge.dart';
import '../ui/button.dart';
import '../ui/card.dart';
import '../ui/dropdown_menu.dart';
import '../ui/input.dart';
import '../ui/popover.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/theme.dart';

/// The agent's buildings.
const _buildings = ['Elm Court', 'Riverside Flats', 'Park Road Villas'];

/// The units in the open building: unit, tenant, monthly rent, and how they stand.
const _units = [
  ('A1', 'Noah Williams', 1450, 'Paid'),
  ('A2', 'Kamau Mwangi', 1450, 'Paid'),
  ('A3', 'Lena Fischer', 1680, 'Part paid'),
  ('B1', 'Carlos Mendes', 1200, 'Due on the 5th'),
  ('B2', 'Aisha Bello', 1200, 'Two months behind'),
  ('B3', '', 1200, 'Empty'),
  ('C1', 'Otieno Ouma', 1950, 'Paid'),
];

String _dollars(int v) =>
    '\$${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';

/// A header over a sidebar and its page.
class RentTracker extends StatefulWidget {
  const RentTracker({super.key});

  @override
  State<RentTracker> createState() => _RentTrackerState();
}

class _RentTrackerState extends State<RentTracker> {
  // The header is above the sidebar, so its button reaches the sidebar by this key.
  final _sidebar = GlobalKey<SidebarLayoutState>();
  var _building = 'Elm Court';

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
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
                  semanticLabel: 'Show or hide the sidebar',
                  onPressed: () => _sidebar.currentState?.toggle(),
                  child: const AshlarIcon(AshlarIconsRoundedStroke.panelLeft),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: c.primary,
                    borderRadius: BorderRadius.circular(t.radiusMd),
                  ),
                  child: AshlarIcon(
                    AshlarIconsRoundedStroke.house,
                    size: 16,
                    color: c.primaryForeground,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Greenway Rentals',
                  style: t.text.sm.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (wide) ...[
                  const SizedBox(
                    width: 260,
                    child: Input(
                      placeholder: 'Find a tenant or unit…',
                      semanticLabel: 'Find a tenant or unit',
                      leading: AshlarIcon(AshlarIconsRoundedStroke.search),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Button(
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.icon,
                  semanticLabel: 'Notifications',
                  onPressed: () {},
                  child: const AshlarIcon(AshlarIconsRoundedStroke.bell),
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
              SidebarGroup(label: 'Buildings', [
                for (final name in _buildings)
                  SidebarItem(
                    name,
                    icon: AshlarIconsRoundedStroke.buildingComplex,
                    active: name == _building,
                    onPressed: () => setState(() => _building = name),
                  ),
              ]),
              SidebarGroup(label: 'Money', [
                SidebarItem(
                  'Rent',
                  icon: AshlarIconsRoundedStroke.wallet,
                  onPressed: () {},
                ),
                SidebarItem(
                  'Deposits',
                  icon: AshlarIconsRoundedStroke.landmark,
                  onPressed: () {},
                ),
                SidebarItem(
                  'Statements to owners',
                  icon: AshlarIconsRoundedStroke.fileText,
                  onPressed: () {},
                ),
              ]),
              SidebarGroup(label: 'Upkeep', [
                SidebarItem(
                  'Repairs',
                  icon: AshlarIconsRoundedStroke.wrench,
                  badge: '3',
                  onPressed: () {},
                ),
                SidebarItem(
                  'Water and power',
                  icon: AshlarIconsRoundedStroke.droplet,
                  onPressed: () {},
                ),
              ]),
              SidebarGroup(atEnd: true, [
                SidebarItem(
                  'Help',
                  icon: AshlarIconsRoundedStroke.lifeBuoy,
                  onPressed: () {},
                ),
              ]),
            ],
            footer: const _Agent(),
            child: _Rent(building: _building),
          ),
        ),
      ],
    );
  }
}

class _Agent extends StatelessWidget {
  const _Agent();

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
        semanticLabel: 'Account: Hannah Lee',
        onPressed: menu.open,
        trailing: const AshlarIcon(AshlarIconsRoundedStroke.chevronsUpDown),
        child: Row(
          children: [
            const Avatar(fallback: 'HL'),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hannah Lee',
                    overflow: TextOverflow.ellipsis,
                    style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Property manager',
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

/// This month's rent in [building]: what has come in, and how each unit stands.
class _Rent extends StatelessWidget {
  const _Rent({required this.building});

  final String building;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(building, style: t.text.xxl),
                  Text(
                    'Rent for July',
                    style: t.text.sm.copyWith(color: c.mutedForeground),
                  ),
                ],
              ),
            ),
            Button(
              size: ButtonSize.sm,
              variant: ButtonVariant.outline,
              leading: const AshlarIcon(AshlarIconsRoundedStroke.messageSquare),
              onPressed: () {},
              child: const Text('Remind those due'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (final (i, (label, value)) in [
              ('Collected', '\$21,600'),
              ('Still due', '\$14,100'),
              ('Empty units', '1'),
            ].indexed) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: Card(
                  size: CardSize.sm,
                  children: [
                    CardHeader(
                      description: Text(label),
                      title: Text(
                        value,
                        style: t.text.xl.copyWith(fontWeight: FontWeight.w600),
                      ),
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
            CardHeader(
              title: const Text('Units'),
              description: Text(
                '${_units.length} units, '
                '${_units.where((u) => u.$2.isEmpty).length} empty',
              ),
            ),
            CardContent(
              child: Column(
                children: [
                  for (final (i, (unit, tenant, rent, status))
                      in _units.indexed) ...[
                    if (i > 0) const Separator(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 36,
                            child: Text(
                              unit,
                              style: t.text.sm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tenant.isEmpty ? 'No tenant' : tenant,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.text.sm.copyWith(
                                    color: tenant.isEmpty
                                        ? c.mutedForeground
                                        : c.foreground,
                                  ),
                                ),
                                Text(
                                  '${_dollars(rent)} a month',
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
                              'Paid' => BadgeVariant.secondary,
                              'Two months behind' => BadgeVariant.destructive,
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
    );
  }
}
