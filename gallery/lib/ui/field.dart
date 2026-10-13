// Ashlar UI: Field. Copied into your app by `ashlar add field`; it is yours to change.

import 'package:flutter/widgets.dart';

import 'label.dart';
import 'theme.dart';

/// A control with its label, a description under it and an error when it is wrong. A
/// screen reader hears the label and description as part of the control.
///
/// Vertical puts the label above (inputs, selects); horizontal puts the control first and
/// the label beside it (checkboxes, switches, radios).
///
/// ```dart
/// Field(label: Text('Email'), description: Text('We send receipts here.'), child: Input(placeholder: 'you@solutech.co.ke'))
/// Field(axis: Axis.horizontal, label: Text('Accept the terms'), child: Checkbox(value: agreed, onChanged: agree))
/// ```
class Field extends StatelessWidget {
  const Field({
    super.key,
    required this.child,
    this.label,
    this.description,
    this.error,
    this.axis = Axis.vertical,
    this.enabled = true,
  });

  final Widget child;
  final Widget? label;
  final Widget? description;

  /// Shown under the description in the destructive colour, and read out with the field.
  final Widget? error;
  final Axis axis;

  /// False fades the label and description with the control.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final notes = [
      if (description != null)
        Opacity(
          opacity: enabled ? 1 : .5,
          child: DefaultTextStyle.merge(
            style: t.text.sm.copyWith(color: c.mutedForeground),
            child: description!,
          ),
        ),
      if (error != null)
        DefaultTextStyle.merge(
          style: t.text.sm.copyWith(color: c.destructive),
          child: error!,
        ),
    ];
    final label = this.label == null
        ? null
        : Label(enabled: enabled, child: this.label!);
    return MergeSemantics(
      child: axis == Axis.vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (label != null) ...[label, const SizedBox(height: 12)],
                child,
                for (final n in notes) ...[const SizedBox(height: 8), n],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                child,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lines the label up with the middle of a 16 tall control.
                      if (label != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: label,
                        ),
                      for (final n in notes) ...[const SizedBox(height: 6), n],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
