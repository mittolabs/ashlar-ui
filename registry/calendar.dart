// Ashlar UI: Calendar. Copied into your app by `ashlar add calendar`; it is yours to change.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'button.dart';
import 'theme.dart';

/// The words dates are written in: month and weekday names, which day a week starts on,
/// and how a date is written out. English unless an app puts others above it with
/// [DateNamesScope], for another language or another week.
@immutable
class DateNames {
  const DateNames({
    required this.months,
    required this.weekdays,
    required this.weekdaysShort,
    this.firstWeekday = DateTime.monday,
    this.format = _dayMonthYear,
  });

  /// January to December.
  final List<String> months;

  /// Monday to Sunday, in full, for screen readers.
  final List<String> weekdays;

  /// Monday to Sunday, as short as a column heading takes.
  final List<String> weekdaysShort;

  /// [DateTime.monday] to [DateTime.sunday].
  final int firstWeekday;

  /// A date written out: "13 October 2026".
  final String Function(DateNames names, DateTime date) format;

  static String _dayMonthYear(DateNames n, DateTime d) =>
      '${d.day} ${n.months[d.month - 1]} ${d.year}';

  static const english = DateNames(
    months: [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ],
    weekdays: [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ],
    weekdaysShort: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'],
  );

  /// The names above [context], or English.
  static DateNames of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DateNamesScope>()?.names ??
      english;

  String date(DateTime d) => format(this, d);
  String monthYear(DateTime d) => '${months[d.month - 1]} ${d.year}';
}

/// Puts [names] above a part of the app, or the whole of it.
class DateNamesScope extends InheritedWidget {
  const DateNamesScope({super.key, required this.names, required super.child});

  final DateNames names;

  @override
  bool updateShouldNotify(DateNamesScope old) => old.names != names;
}

/// From [start] to [end], both days included. While a range is being chosen, [end] is null.
@immutable
class DateRange {
  const DateRange(this.start, [this.end]);

  final DateTime start;
  final DateTime? end;

  bool contains(DateTime d) =>
      end != null && !d.isBefore(_day(start)) && !d.isAfter(_day(end!));

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
bool _same(DateTime? a, DateTime? b) =>
    a != null &&
    b != null &&
    a.year == b.year &&
    a.month == b.month &&
    a.day == b.day;

/// A month of days to pick from: one day, or with [Calendar.range] a start and an end.
/// The arrows on either side change the month. From the keyboard the arrow keys move a
/// day or a week, Page Up and Page Down a month, Home and End to the week's ends, and
/// Enter or Space picks.
///
/// ```dart
/// Calendar(selected: day, onSelected: (d) => setState(() => day = d))
/// Calendar.range(range: stay, onRangeChanged: (r) => setState(() => stay = r))
/// ```
class Calendar extends StatefulWidget {
  const Calendar({
    super.key,
    required this.selected,
    required ValueChanged<DateTime> this.onSelected,
    this.initialMonth,
    this.firstDate,
    this.lastDate,
    this.isDisabled,
    this.autofocus = false,
  }) : range = null,
       onRangeChanged = null;

  const Calendar.range({
    super.key,
    required this.range,
    required ValueChanged<DateRange> this.onRangeChanged,
    this.initialMonth,
    this.firstDate,
    this.lastDate,
    this.isDisabled,
    this.autofocus = false,
  }) : selected = null,
       onSelected = null;

  final DateTime? selected;
  final ValueChanged<DateTime>? onSelected;
  final DateRange? range;
  final ValueChanged<DateRange>? onRangeChanged;

  /// The month shown first: the selected one, else this month.
  final DateTime? initialMonth;

  /// The earliest and latest days that can be picked.
  final DateTime? firstDate, lastDate;

  /// Days that cannot be picked: weekends, booked days.
  final bool Function(DateTime day)? isDisabled;
  final bool autofocus;

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late DateTime _month = _monthOf(
    widget.initialMonth ??
        widget.selected ??
        widget.range?.start ??
        DateTime.now(),
  );
  late DateTime _focus = _day(
    widget.selected ??
        widget.range?.start ??
        widget.initialMonth ??
        DateTime.now(),
  );
  final _node = FocusNode(debugLabel: 'Calendar');
  bool _keyboard = false;

  static DateTime _monthOf(DateTime d) => DateTime(d.year, d.month);

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  bool _off(DateTime d) =>
      (widget.firstDate != null && d.isBefore(_day(widget.firstDate!))) ||
      (widget.lastDate != null && d.isAfter(_day(widget.lastDate!))) ||
      (widget.isDisabled?.call(d) ?? false);

  void _pick(DateTime d) {
    if (_off(d)) return;
    setState(() => _focus = d);
    if (widget.onSelected != null) {
      widget.onSelected!(d);
      return;
    }
    final r = widget.range;
    // A finished range, or none: start again. A start only: this is the other end.
    if (r == null || r.end != null) {
      widget.onRangeChanged!(DateRange(d));
    } else {
      widget.onRangeChanged!(
        d.isBefore(r.start) ? DateRange(d, r.start) : DateRange(r.start, d),
      );
    }
  }

  void _showMonth(int by) =>
      setState(() => _month = DateTime(_month.year, _month.month + by));

  void _moveFocus(DateTime to) {
    setState(() {
      _focus = to;
      _month = _monthOf(to);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final names = DateNames.of(context);
    final first = names.firstWeekday;
    // The grid starts on the first weekday on or before the 1st, and runs whole weeks.
    final lead = (_month.weekday - first + 7) % 7;
    final start = DateTime(_month.year, _month.month, 1 - lead);
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final weeks = ((lead + days) / 7).ceil();
    final today = _day(DateTime.now());
    final canBack =
        widget.firstDate == null || _month.isAfter(_monthOf(widget.firstDate!));
    final canOn =
        widget.lastDate == null || _month.isBefore(_monthOf(widget.lastDate!));

    Widget day(DateTime d) {
      final outside = d.month != _month.month;
      final off = _off(d);
      final r = widget.range;
      final isStart = _same(d, r?.start) || _same(d, widget.selected);
      final isEnd = _same(d, r?.end);
      final middle = !isStart && !isEnd && (r?.contains(d) ?? false);
      final picked = isStart || isEnd;
      final focused = _keyboard && _node.hasFocus && _same(d, _focus);
      final isToday = _same(d, today);
      final fg = picked
          ? c.primaryForeground
          : (middle
                ? c.accentForeground
                : (outside ? c.mutedForeground : c.foreground));
      // A range is one band: the ends round only on their outer side.
      final radius = Radius.circular(t.radiusMd);
      final inRange = r?.end != null && !_same(r!.start, r.end);
      final band = BorderRadius.horizontal(
        left: middle || (isEnd && inRange) ? Radius.zero : radius,
        right: middle || (isStart && inRange && r.end != null)
            ? Radius.zero
            : radius,
      );
      return Semantics(
        button: true,
        enabled: !off,
        selected: picked || middle,
        label:
            '${names.weekdays[d.weekday - 1]}, ${names.date(d)}${isToday ? ', today' : ''}',
        onTap: off ? null : () => _pick(d),
        child: ExcludeSemantics(
          child: _Day(
            onTap: off ? null : () => _pick(d),
            builder: (hovered) => Container(
              decoration: BoxDecoration(
                color: picked
                    ? c.primary
                    : (middle
                          ? c.accent
                          : ((hovered || isToday) && !off
                                ? c.accent
                                : const Color(0x00000000))),
                borderRadius: middle || picked
                    ? band
                    : BorderRadius.all(radius),
                boxShadow: [if (focused) ...t.focusRing],
              ),
              alignment: Alignment.center,
              child: Opacity(
                opacity: off ? .5 : 1,
                child: Text(
                  '${d.day}',
                  style: t.text.sm.copyWith(
                    color: fg,
                    decoration: off ? TextDecoration.lineThrough : null,
                    decorationColor: fg,
                    fontWeight: picked ? FontWeight.w500 : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Focus(
      focusNode: _node,
      autofocus: widget.autofocus,
      onFocusChange: (f) => setState(
        () => _keyboard =
            f &&
            FocusManager.instance.highlightMode ==
                FocusHighlightMode.traditional,
      ),
      onKeyEvent: (node, e) {
        if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        final k = e.logicalKey;
        final f = _focus;
        final DateTime? to = switch (k) {
          LogicalKeyboardKey.arrowLeft => f.subtract(const Duration(days: 1)),
          LogicalKeyboardKey.arrowRight => f.add(const Duration(days: 1)),
          LogicalKeyboardKey.arrowUp => DateTime(f.year, f.month, f.day - 7),
          LogicalKeyboardKey.arrowDown => DateTime(f.year, f.month, f.day + 7),
          LogicalKeyboardKey.pageUp => DateTime(f.year, f.month - 1, f.day),
          LogicalKeyboardKey.pageDown => DateTime(f.year, f.month + 1, f.day),
          LogicalKeyboardKey.home => DateTime(
            f.year,
            f.month,
            f.day - (f.weekday - first + 7) % 7,
          ),
          LogicalKeyboardKey.end => DateTime(
            f.year,
            f.month,
            f.day + 6 - (f.weekday - first + 7) % 7,
          ),
          _ => null,
        };
        if (to != null) {
          setState(() => _keyboard = true);
          _moveFocus(_day(to));
          return KeyEventResult.handled;
        }
        if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.space) {
          _pick(_focus);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        container: true,
        label: names.monthYear(_month),
        explicitChildNodes: true,
        child: SizedBox(
          width: 7 * 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 32,
                child: Row(
                  children: [
                    _Nav(
                      icon: AshlarIconsRoundedStroke.chevronLeft,
                      label: 'Previous month',
                      onPressed: canBack ? () => _showMonth(-1) : null,
                    ),
                    Expanded(
                      child: Text(
                        names.monthYear(_month),
                        textAlign: TextAlign.center,
                        style: t.text.sm.copyWith(
                          fontWeight: FontWeight.w500,
                          color: c.foreground,
                        ),
                      ),
                    ),
                    _Nav(
                      icon: AshlarIconsRoundedStroke.chevronRight,
                      label: 'Next month',
                      onPressed: canOn ? () => _showMonth(1) : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ExcludeSemantics(
                child: Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      SizedBox(
                        width: 32,
                        height: 24,
                        child: Center(
                          child: Text(
                            names.weekdaysShort[(first - 1 + i) % 7],
                            style: t.text.xs.copyWith(
                              color: c.mutedForeground,
                              fontSize: 12.8,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              for (var w = 0; w < weeks; w++)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    children: [
                      for (var i = 0; i < 7; i++)
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: day(
                            DateTime(
                              start.year,
                              start.month,
                              start.day + w * 7 + i,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A day that lights up under the pointer.
class _Day extends StatefulWidget {
  const _Day({required this.onTap, required this.builder});

  final VoidCallback? onTap;
  final Widget Function(bool hovered) builder;

  @override
  State<_Day> createState() => _DayState();
}

class _DayState extends State<_Day> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: widget.onTap == null
        ? SystemMouseCursors.basic
        : SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: widget.builder(_hovered),
    ),
  );
}

/// The previous and next month buttons.
class _Nav extends StatelessWidget {
  const _Nav({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 32,
    height: 32,
    child: Button(
      variant: ButtonVariant.ghost,
      size: ButtonSize.icon,
      semanticLabel: label,
      onPressed: onPressed,
      child: AshlarIcon(icon),
    ),
  );
}
