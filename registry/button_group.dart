// Ashlar UI: Button Group. Copied into your app by `ashlar add button-group`; it is yours
// to change.

import 'package:flutter/widgets.dart';

import 'group.dart';

/// Buttons joined into one piece, for actions that belong together.
///
/// ```dart
/// ButtonGroup(children: [
///   Button(variant: ButtonVariant.outline, onPressed: archive, child: Text('Archive')),
///   Button(variant: ButtonVariant.outline, onPressed: report, child: Text('Report')),
///   Button(variant: ButtonVariant.outline, onPressed: snooze, child: Text('Snooze')),
/// ])
/// ```
class ButtonGroup extends StatelessWidget {
  const ButtonGroup({
    super.key,
    required this.children,
    this.axis = Axis.horizontal,
    this.semanticLabel,
  });

  final List<Widget> children;
  final Axis axis;

  /// What the buttons are for, read before them: 'Text alignment'.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: semanticLabel,
    child: IntrinsicHeight(
      child: JoinedGroup(axis: axis, children: children),
    ),
  );
}
