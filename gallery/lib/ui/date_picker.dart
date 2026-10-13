// Ashlar UI: Date Picker. Copied into your app by `ashlar add date-picker`; it is yours to
// change.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'calendar.dart';
import 'popover.dart';
import 'pressable.dart';
import 'select.dart';
import 'theme.dart';

/// A button that shows a date and opens a Calendar to change it. [DatePicker.range] picks
/// a start and an end, and closes once both are chosen.
///
/// ```dart
/// DatePicker(value: due, onChanged: (d) => setState(() => due = d))
/// DatePicker.range(range: stay, onRangeChanged: (r) => setState(() => stay = r))
/// ```
class DatePicker extends StatefulWidget {
  const DatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.placeholder = 'Pick a date',
    this.firstDate,
    this.lastDate,
    this.isDisabled,
    this.semanticLabel,
    this.presets = const [],
  }) : range = null,
       onRangeChanged = null;

  const DatePicker.range({
    super.key,
    required this.range,
    required this.onRangeChanged,
    this.placeholder = 'Pick dates',
    this.firstDate,
    this.lastDate,
    this.isDisabled,
    this.semanticLabel,
  }) : presets = const [],
       value = null,
       onChanged = null;

  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;
  final DateRange? range;
  final ValueChanged<DateRange>? onRangeChanged;
  final String placeholder;
  final DateTime? firstDate, lastDate;
  final bool Function(DateTime day)? isDisabled;

  /// What the date is for, read out before it: 'Due date'.
  final String? semanticLabel;

  /// Dates a tap away, offered above the calendar: ('Tomorrow', tomorrow).
  final List<(String, DateTime)> presets;

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  final _menu = MenuController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  bool get _isRange =>
      widget.onRangeChanged != null ||
      (widget.onChanged == null && widget.range != null);
  bool get _enabled =>
      widget.onChanged != null || widget.onRangeChanged != null;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final names = DateNames.of(context);
    final r = widget.range;
    final shown = _isRange
        ? (r == null
              ? null
              : (r.end == null
                    ? names.date(r.start)
                    : '${names.date(r.start)} to ${names.date(r.end!)}'))
        : (widget.value == null ? null : names.date(widget.value!));
    return RawMenuAnchor(
      controller: _menu,
      childFocusNode: _focus,
      onClose: _focus.requestFocus,
      overlayBuilder: (context, info) => PopoverPanel(
        info: info,
        // Scrolls when the room by the trigger is shorter than the calendar.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: _isRange
              ? Calendar.range(
                  autofocus: true,
                  range: widget.range,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  isDisabled: widget.isDisabled,
                  onRangeChanged: (v) {
                    widget.onRangeChanged?.call(v);
                    if (v.end != null) _menu.close();
                  },
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.presets.isNotEmpty) ...[
                      Select<int>(
                        value: null,
                        size: SelectSize.sm,
                        placeholder: 'Pick a preset',
                        options: [
                          for (final (i, p) in widget.presets.indexed)
                            SelectOption(i, p.$1),
                        ],
                        onChanged: (i) {
                          widget.onChanged?.call(widget.presets[i].$2);
                          _menu.close();
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    Calendar(
                      autofocus: widget.presets.isEmpty,
                      selected: widget.value,
                      firstDate: widget.firstDate,
                      lastDate: widget.lastDate,
                      isDisabled: widget.isDisabled,
                      onSelected: (d) {
                        widget.onChanged?.call(d);
                        _menu.close();
                      },
                    ),
                  ],
                ),
        ),
      ),
      child: Pressable(
        focusNode: _focus,
        onPressed: _enabled
            ? () => _menu.isOpen ? _menu.close() : _menu.open()
            : null,
        semanticLabel: widget.semanticLabel,
        semanticValue: widget.semanticLabel == null
            ? null
            : (shown ?? widget.placeholder),
        builder: (context, state) => Opacity(
          opacity: state.enabled ? 1 : .5,
          child: AnimatedContainer(
            duration: t.duration,
            height: t.control(36),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: state.hovered ? c.accent : c.background,
              borderRadius: BorderRadius.circular(t.radiusMd),
              border: Border.all(color: state.focused ? c.ring : c.input),
              boxShadow: [if (state.focused) ...t.focusRing, ...t.shadowXs],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AshlarIcon(
                  AshlarIconsRoundedStroke.calendar,
                  size: 16,
                  color: c.mutedForeground,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    shown ?? widget.placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.text.sm.copyWith(
                      color: shown == null ? c.mutedForeground : c.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
