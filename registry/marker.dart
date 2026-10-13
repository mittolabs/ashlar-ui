// Ashlar UI: Marker. Copied into your app by `ashlar add marker`; it is yours to change.

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// How a [Marker] sets itself apart.
enum MarkerVariant {
  /// Faint text, nothing more.
  plain,

  /// Centred between two lines: a day changing, someone joining.
  separator,

  /// A line under it.
  border,
}

/// A note in a conversation that nobody said: "Today", "Ama joined", "Thinking…". Faint,
/// with an optional icon.
///
/// ```dart
/// Marker(variant: MarkerVariant.separator, child: Text('Today'))
/// Marker(icon: Spinner(size: 16), child: Text('Searching the docs…'))
/// ```
class Marker extends StatelessWidget {
  const Marker({
    super.key,
    required this.child,
    this.variant = MarkerVariant.plain,
    this.icon,
  });

  /// The note: Text('Today').
  final Widget child;

  /// Faint text, between two lines, or with a line under it.
  final MarkerVariant variant;

  /// 16 square, before the text. Hidden from screen readers: the text says it.
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final text = DefaultTextStyle.merge(
      style: t.text.sm.copyWith(color: c.mutedForeground),
      textAlign: variant == MarkerVariant.separator ? TextAlign.center : null,
      child: child,
    );
    final content = [
      if (icon != null) ...[
        ExcludeSemantics(
          child: IconTheme.merge(
            data: IconThemeData(color: c.mutedForeground, size: 16),
            child: SizedBox.square(dimension: 16, child: Center(child: icon)),
          ),
        ),
        const SizedBox(width: 8),
      ],
    ];
    Widget line() => Expanded(child: Container(height: 1, color: c.border));
    final body = switch (variant) {
      // The text takes what it needs, up to most of the width; the lines share the rest.
      MarkerVariant.separator => LayoutBuilder(
        builder: (context, box) => Row(
          children: [
            line(),
            const SizedBox(width: 12),
            ...content,
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: box.maxWidth * .7),
              child: text,
            ),
            const SizedBox(width: 12),
            line(),
          ],
        ),
      ),
      _ => Row(
        children: [
          ...content,
          Expanded(child: text),
        ],
      ),
    };
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 16),
      child: variant == MarkerVariant.border
          ? Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: c.border)),
              ),
              child: body,
            )
          : body,
    );
  }
}
