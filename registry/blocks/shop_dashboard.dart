// Ashlar UI block: shop-dashboard. Copied into your app by `ashlar add shop-dashboard`; it
// is yours to change. A shop's day at a glance: what sold and how it was paid, the hours it
// sold in, what is waiting to go out and what is running low.
//
// The shop, figures and orders are sample data, there to be replaced with yours.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/avatar.dart';
import '../ui/badge.dart';
import '../ui/button.dart';
import '../ui/card.dart';
import '../ui/chart.dart';
import '../ui/data_table.dart';
import '../ui/dropdown_menu.dart';
import '../ui/popover.dart';
import '../ui/select.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/tabs.dart';
import '../ui/theme.dart';
import '../ui/toggle_group.dart';

/// A shop's dashboard: the till and the stock down the side, the day set into it as a card.
class ShopDashboard extends StatelessWidget {
  const ShopDashboard({super.key});

  @override
  Widget build(BuildContext context) => SidebarLayout(
    variant: SidebarVariant.inset,
    collapse: SidebarCollapse.offcanvas,
    header: const _Shop(),
    groups: [
      const SidebarGroup.custom(_NewSale()),
      SidebarGroup([
        SidebarItem(
          'Today',
          icon: AshlarIconsRoundedStroke.sun,
          active: true,
          onPressed: () {},
        ),
        SidebarItem(
          'Orders',
          icon: AshlarIconsRoundedStroke.shoppingBag,
          badge: '7',
          onPressed: () {},
        ),
        SidebarItem(
          'Stock',
          icon: AshlarIconsRoundedStroke.package,
          onPressed: () {},
        ),
        SidebarItem(
          'Customers',
          icon: AshlarIconsRoundedStroke.users,
          onPressed: () {},
        ),
        SidebarItem(
          'Suppliers',
          icon: AshlarIconsRoundedStroke.truck,
          onPressed: () {},
        ),
      ]),
      SidebarGroup(label: 'Payments', [
        for (final (label, icon) in [
          ('Payments in', AshlarIconsRoundedStroke.arrowDownLeft),
          ('Statements', AshlarIconsRoundedStroke.fileText),
          ('Card readers', AshlarIconsRoundedStroke.creditCard),
        ])
          SidebarItem(label, icon: icon, onPressed: () {}),
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
    footer: const _Owner(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Header(),
        const Separator(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                _Figures(),
                SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _Sales(),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _Orders(),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _Shop extends StatelessWidget {
  const _Shop();

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
              color: c.primary,
              borderRadius: BorderRadius.circular(t.radiusMd),
            ),
            child: AshlarIcon(
              AshlarIconsRoundedStroke.store,
              size: 18,
              color: c.primaryForeground,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Corner Pantry',
                  overflow: TextOverflow.ellipsis,
                  style: t.text.sm.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Elm Street',
                  style: t.text.xs.copyWith(color: c.mutedForeground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewSale extends StatelessWidget {
  const _NewSale();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Button(
          expand: true,
          leading: const AshlarIcon(AshlarIconsRoundedStroke.plus),
          onPressed: () {},
          child: const Text('New sale'),
        ),
      ),
      const SizedBox(width: 8),
      Button(
        variant: ButtonVariant.outline,
        size: ButtonSize.icon,
        semanticLabel: 'Scan a barcode',
        onPressed: () {},
        child: const AshlarIcon(AshlarIconsRoundedStroke.scanBarcode),
      ),
    ],
  );
}

class _Owner extends StatelessWidget {
  const _Owner();

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
        semanticLabel: 'Account: Rosa Delgado',
        onPressed: menu.open,
        trailing: const AshlarIcon(AshlarIconsRoundedStroke.chevronsUpDown),
        child: Row(
          children: [
            const Avatar(fallback: 'RD'),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rosa Delgado',
                    overflow: TextOverflow.ellipsis,
                    style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Owner',
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
          child: const Text('My account'),
        ),
        MenuItem(
          leading: const AshlarIcon(AshlarIconsRoundedStroke.users),
          onPressed: () {},
          child: const Text('Staff'),
        ),
        MenuItem(
          leading: const AshlarIcon(AshlarIconsRoundedStroke.store),
          onPressed: () {},
          child: const Text('Switch shop'),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final wide = MediaQuery.sizeOf(context).width >= 760;
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const SidebarTrigger(),
            const SizedBox(width: 8),
            const SizedBox(height: 16, child: Separator(axis: Axis.vertical)),
            const SizedBox(width: 12),
            Text(
              'Today',
              style: t.text.base.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            // Takes the room between the title and the actions, and gives way first.
            Expanded(
              child: Text(
                'Thursday 2 July',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.text.sm.copyWith(color: c.mutedForeground),
              ),
            ),
            if (wide) ...[
              const Badge(
                variant: BadgeVariant.outline,
                leading: AshlarIcon(AshlarIconsRoundedStroke.circleCheck),
                child: Text('Open since 7:02'),
              ),
              const SizedBox(width: 8),
            ],
            Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.sm,
              onPressed: () {},
              child: const Text('Close the day'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The day in four figures, each with what it is measured against: four across, two, or
/// one, as there is room.
class _Figures extends StatelessWidget {
  const _Figures();

  static const _figures = [
    (
      'Sales today',
      '\$4,835',
      '+12%',
      true,
      'Up on last Thursday',
      '132 sales since 7:02',
    ),
    (
      'Paid by card',
      '\$3,142',
      '65%',
      true,
      'Two in three sales',
      '\$1,693 in cash',
    ),
    (
      'Orders to deliver',
      '7',
      '2 late',
      false,
      'Two past their time',
      'Next driver back at 2:30',
    ),
    (
      'Running low',
      '4 items',
      'Reorder',
      false,
      'Coffee, olive oil and more',
      'Reorder by Friday',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return LayoutBuilder(
      builder: (context, box) {
        final across = box.maxWidth >= 960 ? 4 : (box.maxWidth >= 640 ? 2 : 1);
        const gap = 16.0;
        final width = (box.maxWidth - 48 - gap * (across - 1)) / across;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final (label, value, tag, good, line, note) in _figures)
                SizedBox(
                  width: width,
                  child: Card(
                    children: [
                      CardHeader(
                        description: Text(label),
                        title: Text(value, style: t.text.xxl),
                        action: Badge(
                          variant: good
                              ? BadgeVariant.outline
                              : BadgeVariant.secondary,
                          child: Text(tag),
                        ),
                      ),
                      CardFooter(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  line,
                                  style: t.text.sm.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  note,
                                  style: t.text.sm.copyWith(
                                    color: c.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Sales paid by card and in cash, by the hour today, by the day this week, or by the
/// day this month.
class _Sales extends StatefulWidget {
  const _Sales();

  @override
  State<_Sales> createState() => _SalesState();
}

/// One bar's sales, in dollars.
typedef _Takings = ({String when, double card, double cash});

class _SalesState extends State<_Sales> {
  var _range = 'today';

  static const _ranges = [
    ('today', 'Today'),
    ('week', 'This week'),
    ('month', 'This month'),
  ];

  // Sample takings: busy first thing, at lunch and after work.
  static List<_Takings> _rows(String range) => switch (range) {
    'today' => [
      for (var hour = 7; hour <= 20; hour++)
        (
          when: hour < 12
              ? '${hour}am'
              : hour == 12
              ? '12pm'
              : '${hour - 12}pm',
          card:
              [
                1800,
                4200,
                2100,
                1500,
                1900,
                3600,
                3200,
                1700,
                1400,
                1900,
                3100,
                2900,
                1220,
                900,
              ][hour - 7] /
              10,
          cash:
              [
                1600,
                2200,
                900,
                800,
                1100,
                1700,
                1500,
                700,
                600,
                1000,
                1800,
                1500,
                900,
                630,
              ][hour - 7] /
              10,
        ),
    ],
    'week' => [
      for (final (i, day) in [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ].indexed)
        (
          when: day,
          card: [29800, 27400, 30100, 31420, 0, 0, 0][i] / 10,
          cash: [15900, 14800, 16200, 16930, 0, 0, 0][i] / 10,
        ),
    ],
    _ => [
      for (var day = 1; day <= 30; day++)
        (
          when: '$day',
          card: day > 2 ? 0 : (2600 + (day * 317) % 900).toDouble(),
          cash: day > 2 ? 0 : (1300 + (day * 221) % 600).toDouble(),
        ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 640;
    return Card(
      children: [
        CardHeader(
          title: const Text('Sales'),
          description: Text(switch (_range) {
            'today' => 'By the hour since opening',
            'week' => 'By the day, Monday to today',
            _ => 'By the day, this month so far',
          }),
          // Buttons where there is room, a select where there is not.
          action: narrow
              ? SizedBox(
                  width: 140,
                  child: Select<String>(
                    value: _range,
                    size: SelectSize.sm,
                    semanticLabel: 'Range',
                    options: [for (final (v, l) in _ranges) SelectOption(v, l)],
                    onChanged: (v) => setState(() => _range = v),
                  ),
                )
              : ToggleGroup<String>(
                  values: {_range},
                  semanticLabel: 'Range',
                  onChanged: (v) {
                    if (v.isNotEmpty) setState(() => _range = v.first);
                  },
                  items: [
                    for (final (v, l) in _ranges) ToggleGroupItem(v, Text(l)),
                  ],
                ),
        ),
        CardContent(
          child: BarChart<_Takings>(
            height: 240,
            semanticLabel: 'Sales paid by card and in cash',
            data: _rows(_range),
            x: (r) => r.when,
            children: [
              CartesianGrid(),
              XAxis(),
              ChartTooltip(indicator: ChartIndicator.dot),
              ChartLegend(),
              Bar(label: 'Card', value: (r) => r.card, stackId: 'paid'),
              Bar(label: 'Cash', value: (r) => r.cash, stackId: 'paid'),
            ],
          ),
        ),
      ],
    );
  }
}

/// Today's orders, by tab: what is still to go out, and everything.
class _Orders extends StatefulWidget {
  const _Orders();

  @override
  State<_Orders> createState() => _OrdersState();
}

class _OrdersState extends State<_Orders> {
  var _picked = <int>{};

  static const _rows = [
    (
      '#1042',
      'Maya Thompson',
      'Flour 5lb, milk, bread',
      18,
      'Card',
      'Out for delivery',
    ),
    ('#1041', 'Kenji Sato', 'Olive oil, sugar 4lb', 24, 'Card', 'Packed'),
    ('#1040', 'Amara Okoye', 'Rice 10lb, black tea', 31, 'Cash', 'Late'),
    ('#1039', 'Luis Herrera', 'Eggs (dozen), spinach', 12, 'Card', 'Packed'),
    (
      '#1038',
      'Priya Nair',
      'Soap, toothpaste, tissue',
      17,
      'On account',
      'Late',
    ),
    ('#1037', 'Sam Becker', 'Bread, milk', 7, 'Cash', 'Delivered'),
    ('#1036', 'Achieng Otieno', 'Flour 5lb, beans', 11, 'Card', 'Delivered'),
    ('#1035', 'Omar Haddad', 'Charcoal, matches', 9, 'Cash', 'Delivered'),
  ];

  static String _dollars(int v) =>
      '\$${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    Widget table(bool waiting) => Padding(
      padding: const EdgeInsets.only(top: 16),
      child: DataTable(
        selected: _picked,
        onSelectChanged: (s) => setState(() => _picked = s),
        columns: const [
          DataColumn(Text('Order')),
          DataColumn(Text('Customer'), flex: 2),
          DataColumn(Text('Items'), flex: 3),
          DataColumn(Text('Total'), numeric: true, flex: 2),
          DataColumn(Text('Paid by'), flex: 2),
          DataColumn(Text('Status'), flex: 2),
        ],
        rows: [
          for (final (order, customer, items, total, paid, status) in _rows)
            if (!waiting || status != 'Delivered')
              [
                Text(
                  order,
                  style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(customer, overflow: TextOverflow.ellipsis),
                Text(
                  items,
                  overflow: TextOverflow.ellipsis,
                  style: t.text.sm.copyWith(color: c.mutedForeground),
                ),
                Text(_dollars(total)),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Badge(
                    variant: BadgeVariant.outline,
                    child: Text(paid),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Badge(
                    variant: status == 'Late'
                        ? BadgeVariant.destructive
                        : status == 'Delivered'
                        ? BadgeVariant.secondary
                        : BadgeVariant.outline,
                    leading: AshlarIcon(switch (status) {
                      'Delivered' => AshlarIconsRoundedStroke.check,
                      'Out for delivery' => AshlarIconsRoundedStroke.bike,
                      'Late' => AshlarIconsRoundedStroke.clockAlert,
                      _ => AshlarIconsRoundedStroke.package,
                    }),
                    child: Text(status),
                  ),
                ),
              ],
        ],
      ),
    );
    return Tabs(
      variant: TabsVariant.line,
      tabs: [
        TabItem(label: const Text('To deliver'), content: table(true)),
        TabItem(label: const Text('All today'), content: table(false)),
      ],
    );
  }
}
