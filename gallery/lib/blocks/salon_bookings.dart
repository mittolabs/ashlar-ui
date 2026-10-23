// Ashlar UI block: salon-bookings. Copied into your app by `ashlar add salon-bookings`; it
// is yours to change. A salon's bookings: a month to pick a day from and the staff to
// show in the sidebar, and the picked day on the page, a column for each of them.
//
// The salon, its staff and bookings are sample data, there to be replaced.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/breadcrumb.dart';
import '../ui/button.dart';
import '../ui/calendar.dart';
import '../ui/checkbox.dart';
import '../ui/field.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/theme.dart';

/// The salon's staff, and what each does.
const _staff = [
  ('Chloe', 'Braids'),
  ('Marcus', 'Barber'),
  ('Joy', 'Nails'),
  ('Leila', 'Massage'),
];

/// The day's bookings: who with, from what hour, for how long, the client and the service.
const _bookings = [
  ('Chloe', 9.0, 3.0, 'Achieng O.', 'Knotless braids'),
  ('Chloe', 13.0, 2.0, 'Fatuma H.', 'Cornrows'),
  ('Marcus', 9.5, .5, 'Kamau M.', 'Haircut'),
  ('Marcus', 10.5, .5, 'Brian K.', 'Haircut and beard'),
  ('Marcus', 14.0, .5, 'Raj P.', 'Haircut'),
  ('Joy', 10.0, 1.0, 'Grace L.', 'Gel manicure'),
  ('Joy', 12.0, 1.5, 'Sofia R.', 'Pedicure'),
  ('Leila', 11.0, 1.0, 'Amina A.', 'Back massage'),
  ('Leila', 15.0, 1.0, 'Hana S.', 'Full body massage'),
];

/// A salon's bookings, the day picked from a month in the sidebar.
class SalonBookings extends StatefulWidget {
  const SalonBookings({super.key});

  @override
  State<SalonBookings> createState() => _SalonBookingsState();
}

class _SalonBookingsState extends State<SalonBookings> {
  var _day = DateTime(2026, 7, 4);
  final _shown = {'Chloe', 'Marcus', 'Joy'};

  @override
  Widget build(BuildContext context) {
    final names = DateNames.of(context);
    final t = AshlarTheme.of(context);
    return SidebarLayout(
      collapse: SidebarCollapse.offcanvas,
      header: const _Salon(),
      groups: [
        SidebarGroup.custom(
          Calendar(selected: _day, onSelected: (d) => setState(() => _day = d)),
        ),
        const SidebarGroup.custom(Separator()),
        SidebarGroup.custom(
          label: 'Staff',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (name, does) in _staff)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 8,
                    top: 4,
                    bottom: 4,
                  ),
                  child: Field(
                    axis: Axis.horizontal,
                    label: Text(name),
                    description: Text(does, style: t.text.xs),
                    child: Checkbox(
                      value: _shown.contains(name),
                      onChanged: (v) => setState(
                        () => v ? _shown.add(name) : _shown.remove(name),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
      footer: Button(
        expand: true,
        leading: const AshlarIcon(AshlarIconsRoundedStroke.plus),
        onPressed: () {},
        child: const Text('New booking'),
      ),
      child: Column(
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
                        BreadcrumbItem(names.monthYear(_day), onPressed: () {}),
                        BreadcrumbItem(names.date(_day)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Separator(),
          Expanded(
            child: _Day(
              staff: [
                for (final (name, _) in _staff)
                  if (_shown.contains(name)) name,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Salon extends StatelessWidget {
  const _Salon();

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
              AshlarIconsRoundedStroke.scissors,
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
                  'Lumen Salon & Barber',
                  overflow: TextOverflow.ellipsis,
                  style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                ),
                Text('High Street', style: t.text.xs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The day from opening to closing, a column for each of [staff], their bookings placed
/// at their hours.
class _Day extends StatelessWidget {
  const _Day({required this.staff});

  final List<String> staff;

  static const _open = 9, _close = 18, _hour = 64.0;

  static String _time(double h) {
    final hour = h.floor();
    final minutes = ((h - hour) * 60).round();
    final twelve = hour > 12 ? hour - 12 : hour;
    return '$twelve${minutes == 0 ? '' : ':${minutes.toString().padLeft(2, '0')}'}${hour < 12 ? 'am' : 'pm'}';
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    const gutter = 52.0;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 24),
      child: Column(
        children: [
          // Who each column is.
          Row(
            children: [
              const SizedBox(width: gutter),
              for (final name in staff)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: (_close - _open) * _hour,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: gutter,
                  child: Stack(
                    children: [
                      for (var h = _open; h < _close; h++)
                        Positioned(
                          top: h == _open ? 0 : (h - _open) * _hour - 7,
                          right: 8,
                          child: Text(
                            _time(h.toDouble()),
                            style: t.text.xs.copyWith(color: c.mutedForeground),
                          ),
                        ),
                    ],
                  ),
                ),
                for (final name in staff)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: BorderDirectional(
                          start: BorderSide(color: c.border),
                        ),
                      ),
                      child: Stack(
                        children: [
                          for (var h = 0; h < _close - _open; h++)
                            Positioned(
                              top: h * _hour,
                              left: 0,
                              right: 0,
                              child: Container(height: 1, color: c.border),
                            ),
                          for (final (who, from, length, client, service)
                              in _bookings)
                            if (who == name)
                              Positioned(
                                top: (from - _open) * _hour + 2,
                                height: length * _hour - 4,
                                left: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: c.secondary,
                                    borderRadius: BorderRadius.circular(
                                      t.radiusMd,
                                    ),
                                    border: BorderDirectional(
                                      start: BorderSide(
                                        color: c.primary,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                  // An hour or more has room for two lines;
                                  // a shorter one says it all on one.
                                  child: length >= 1
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              client,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: t.text.xs.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: c.secondaryForeground,
                                              ),
                                            ),
                                            Text(
                                              '$service, ${_time(from)}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: t.text.xs.copyWith(
                                                color: c.mutedForeground,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: client,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: c.secondaryForeground,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    '  $service, ${_time(from)}',
                                              ),
                                            ],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: t.text.xs.copyWith(
                                            color: c.mutedForeground,
                                          ),
                                        ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
