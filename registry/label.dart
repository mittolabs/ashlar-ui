// Ashlar UI: Label. Copied into your app by `ashlar add label`; it is yours to change.

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// The name of a control, set above it or beside it. [Field] places one for you.
///
/// ```dart
/// Label(child: Text('Email'))
/// ```
class Label extends StatelessWidget {
  const Label({super.key, required this.child, this.enabled = true});

  final Widget child;

  /// False fades it with the control it names.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: DefaultTextStyle.merge(
        style: t.text.sm.copyWith(
          color: t.colors.foreground,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
        child: child,
      ),
    );
  }
}
