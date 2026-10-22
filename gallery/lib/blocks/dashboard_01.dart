// Ashlar UI block: dashboard-01. Copied into your app by `ashlar add dashboard-01`; it is
// yours to change. An app's home: a sidebar, a header, four figures, a chart over time and
// a table of documents.
//
// The figures, chart and rows are sample data, there to be replaced with yours.

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

/// A dashboard: navigation down the side, the page set into it as a card.
class Dashboard01 extends StatelessWidget {
  const Dashboard01({super.key});

  @override
  Widget build(BuildContext context) => SidebarLayout(
    variant: SidebarVariant.inset,
    collapse: SidebarCollapse.offcanvas,
    header: const _Brand(),
    groups: [
      const SidebarGroup.custom(_QuickCreate()),
      SidebarGroup([
        SidebarItem(
          'Dashboard',
          icon: AshlarIconsRoundedStroke.layoutDashboard,
          active: true,
          onPressed: () {},
        ),
        SidebarItem(
          'Lifecycle',
          icon: AshlarIconsRoundedStroke.listChecks,
          onPressed: () {},
        ),
        SidebarItem(
          'Analytics',
          icon: AshlarIconsRoundedStroke.chartBar,
          onPressed: () {},
        ),
        SidebarItem(
          'Projects',
          icon: AshlarIconsRoundedStroke.folder,
          onPressed: () {},
        ),
        SidebarItem(
          'Team',
          icon: AshlarIconsRoundedStroke.users,
          onPressed: () {},
        ),
      ]),
      SidebarGroup(label: 'Documents', [
        for (final (label, icon) in [
          ('Data Library', AshlarIconsRoundedStroke.database),
          ('Reports', AshlarIconsRoundedStroke.fileText),
          ('Word Assistant', AshlarIconsRoundedStroke.file),
        ])
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
          'Settings',
          icon: AshlarIconsRoundedStroke.settings,
          onPressed: () {},
        ),
        SidebarItem(
          'Get Help',
          icon: AshlarIconsRoundedStroke.circleQuestionMark,
          onPressed: () {},
        ),
        SidebarItem(
          'Search',
          icon: AshlarIconsRoundedStroke.search,
          onPressed: () {},
        ),
      ]),
    ],
    footer: const _User(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Header(title: 'Documents'),
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
                  child: _Visitors(),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _Documents(),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const AshlarIcon(AshlarIconsRoundedStroke.command, size: 20),
          const SizedBox(width: 8),
          Text(
            'Acme Inc.',
            style: t.text.base.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _QuickCreate extends StatelessWidget {
  const _QuickCreate();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Button(
          expand: true,
          leading: const AshlarIcon(AshlarIconsRoundedStroke.circlePlus),
          onPressed: () {},
          child: const Text('Quick Create'),
        ),
      ),
      const SizedBox(width: 8),
      Button(
        variant: ButtonVariant.outline,
        size: ButtonSize.icon,
        semanticLabel: 'Inbox',
        onPressed: () {},
        child: const AshlarIcon(AshlarIconsRoundedStroke.inbox),
      ),
    ],
  );
}

class _User extends StatelessWidget {
  const _User();

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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
          leading: const AshlarIcon(AshlarIconsRoundedStroke.circleUser),
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

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const SidebarTrigger(),
            const SizedBox(width: 8),
            const SizedBox(height: 16, child: Separator(axis: Axis.vertical)),
            const SizedBox(width: 12),
            Text(
              title,
              style: t.text.base.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// Four figures, each with how it moved: four across, two, or one, as there is room.
class _Figures extends StatelessWidget {
  const _Figures();

  static const _figures = [
    (
      'Total Revenue',
      r'$1,250.00',
      '+12.5%',
      true,
      'Trending up this month',
      'Visitors for the last 6 months',
    ),
    (
      'New Customers',
      '1,234',
      '-20%',
      false,
      'Down 20% this period',
      'Acquisition needs attention',
    ),
    (
      'Active Accounts',
      '45,678',
      '+12.5%',
      true,
      'Strong user retention',
      'Engagement exceeds targets',
    ),
    (
      'Growth Rate',
      '4.5%',
      '+4.5%',
      true,
      'Steady performance increase',
      'Meets growth projections',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return LayoutBuilder(
      builder: (context, box) {
        final across = box.maxWidth >= 1100 ? 4 : (box.maxWidth >= 640 ? 2 : 1);
        const gap = 16.0;
        final width = (box.maxWidth - 48 - gap * (across - 1)) / across;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final (label, value, change, up, line, note) in _figures)
                SizedBox(
                  width: width,
                  child: Card(
                    children: [
                      CardHeader(
                        description: Text(label),
                        title: Text(value, style: t.text.xxl),
                        action: Badge(
                          variant: BadgeVariant.outline,
                          leading: AshlarIcon(
                            up
                                ? AshlarIconsRoundedStroke.trendingUp
                                : AshlarIconsRoundedStroke.trendingDown,
                          ),
                          child: Text(change),
                        ),
                      ),
                      CardFooter(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        line,
                                        style: t.text.sm.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    AshlarIcon(
                                      up
                                          ? AshlarIconsRoundedStroke.trendingUp
                                          : AshlarIconsRoundedStroke
                                                .trendingDown,
                                    ),
                                  ],
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

/// Visitors over time, on desktop and mobile, for a range picked at the top.
class _Visitors extends StatefulWidget {
  const _Visitors();

  @override
  State<_Visitors> createState() => _VisitorsState();
}

/// A day's visitors, the chart's row.
typedef _Visits = ({DateTime day, double desktop, double mobile});

class _VisitorsState extends State<_Visitors> {
  var _range = 90;

  static const _ranges = [
    (90, 'Last 3 months'),
    (30, 'Last 30 days'),
    (7, 'Last 7 days'),
  ];

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  // Sample visits: a day's count for each of the last 91 days, ending 30 June.
  static int _desktop(int day) =>
      160 + (day * 53) % 240 + (day % 7 == 5 ? 90 : 0);
  static int _mobile(int day) =>
      110 + (day * 37) % 200 + (day % 7 == 6 ? 60 : 0);

  @override
  Widget build(BuildContext context) {
    final end = DateTime(2026, 6, 30);
    // A point a week for three months, every other day for 30 days, daily for 7.
    final step = switch (_range) {
      90 => 7,
      30 => 2,
      _ => 1,
    };
    final days = [
      for (var back = _range - 1; back >= 0; back -= step)
        end.subtract(Duration(days: back)),
    ];
    int sum(int Function(int) count, DateTime d) =>
        [for (var i = 0; i < step; i++) count(d.day + d.month * 31 + i)]
            .fold(0, (a, b) => a + b);
    final narrow = MediaQuery.sizeOf(context).width < 640;
    return Card(
      children: [
        CardHeader(
          title: const Text('Total Visitors'),
          description: Text(switch (_range) {
            90 => 'Total for the last 3 months',
            30 => 'Total for the last 30 days',
            _ => 'Total for the last 7 days',
          }),
          // Buttons where there is room, a select where there is not.
          action: narrow
              ? SizedBox(
                  width: 150,
                  child: Select<int>(
                    value: _range,
                    size: SelectSize.sm,
                    semanticLabel: 'Range',
                    options: [for (final (v, l) in _ranges) SelectOption(v, l)],
                    onChanged: (v) => setState(() => _range = v),
                  ),
                )
              : ToggleGroup<int>(
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
          child: AreaChart<_Visits>(
            semanticLabel: 'Visitors by day',
            data: [
              for (final d in days)
                (
                  day: d,
                  desktop: sum(_desktop, d).toDouble(),
                  mobile: sum(_mobile, d).toDouble(),
                ),
            ],
            x: (r) => r.day,
            children: [
              CartesianGrid(),
              XAxis(tickFormatter: (d) => '${_months[(d as DateTime).month - 1]} ${d.day}'),
              ChartTooltip(
                indicator: ChartIndicator.dot,
                labelFormatter: (_, r) => '${_months[r!.day.month - 1]} ${r.day.day}',
              ),
              Area(label: 'Mobile', value: (r) => r.mobile, stackId: 'a'),
              Area(label: 'Desktop', value: (r) => r.desktop, stackId: 'a'),
            ],
          ),
        ),
      ],
    );
  }
}

/// The documents, by tab: the outline as a table, the rest waiting for content.
class _Documents extends StatefulWidget {
  const _Documents();

  @override
  State<_Documents> createState() => _DocumentsState();
}

class _DocumentsState extends State<_Documents> {
  var _picked = <int>{};

  static const _rows = [
    ('Cover page', 'Cover page', 'In Process', 18, 5, 'Eddie Lake'),
    ('Table of contents', 'Table of contents', 'Done', 29, 24, 'Eddie Lake'),
    ('Executive summary', 'Narrative', 'Done', 10, 13, 'Eddie Lake'),
    ('Technical approach', 'Narrative', 'Done', 27, 23, 'Jamik Tashpulatov'),
    ('Design', 'Narrative', 'In Process', 2, 16, 'Jamik Tashpulatov'),
    ('Capabilities', 'Narrative', 'In Process', 20, 8, 'Jamik Tashpulatov'),
    (
      'Integration with existing systems',
      'Narrative',
      'In Process',
      19,
      21,
      'Jamik Tashpulatov',
    ),
    (
      'Innovation and advantages',
      'Narrative',
      'Done',
      25,
      26,
      'Assign reviewer',
    ),
    (
      'Overview of EMR system',
      'Technical content',
      'Done',
      7,
      23,
      'Assign reviewer',
    ),
    ('Risk management plan', 'Narrative', 'Done', 22, 15, 'Assign reviewer'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    Widget waiting(String what) => Container(
      height: 240,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(t.radiusLg),
        border: Border.all(color: c.border),
      ),
      child: Text(
        'No $what yet.',
        style: t.text.sm.copyWith(color: c.mutedForeground),
      ),
    );
    return Tabs(
      variant: TabsVariant.line,
      tabs: [
        TabItem(
          label: const Text('Outline'),
          content: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: DataTable(
              selected: _picked,
              onSelectChanged: (s) => setState(() => _picked = s),
              columns: const [
                DataColumn(Text('Header'), flex: 3),
                DataColumn(Text('Section Type'), flex: 2),
                DataColumn(Text('Status'), flex: 2),
                DataColumn(Text('Target'), numeric: true),
                DataColumn(Text('Limit'), numeric: true),
                DataColumn(Text('Reviewer'), flex: 2),
              ],
              rows: [
                for (final (header, type, status, target, limit, reviewer)
                    in _rows)
                  [
                    Text(
                      header,
                      overflow: TextOverflow.ellipsis,
                      style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Badge(
                        variant: BadgeVariant.outline,
                        child: Text(type, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Badge(
                        variant: BadgeVariant.outline,
                        leading: AshlarIcon(
                          status == 'Done'
                              ? AshlarIconsRoundedStroke.check
                              : AshlarIconsRoundedStroke.clock,
                        ),
                        child: Text(status),
                      ),
                    ),
                    Text('$target'),
                    Text('$limit'),
                    Text(
                      reviewer,
                      overflow: TextOverflow.ellipsis,
                      style: reviewer == 'Assign reviewer'
                          ? t.text.sm.copyWith(color: c.mutedForeground)
                          : null,
                    ),
                  ],
              ],
            ),
          ),
        ),
        TabItem(
          label: const Text('Past Performance'),
          content: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: waiting('past performance'),
          ),
        ),
        TabItem(
          label: const Text('Key Personnel'),
          content: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: waiting('key personnel'),
          ),
        ),
        TabItem(
          label: const Text('Focus Documents'),
          content: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: waiting('focus documents'),
          ),
        ),
      ],
    );
  }
}
