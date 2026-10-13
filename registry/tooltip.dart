// Ashlar UI: Tooltip. Copied into your app by `ashlar add tooltip`; it is yours to change.
//
// Built on RawTooltip from Flutter's widgets layer, which shows it on hover and on a long
// press. This file also shows it on keyboard focus and gives screen readers the message.

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// A short label that appears over [child] when it is hovered, focused from the keyboard
/// or long pressed. Use it for what an icon button does, not for anything a person needs.
///
/// ```dart
/// Tooltip(message: 'Add to library', child: Button(size: ButtonSize.icon, semanticLabel: 'Add', onPressed: add, child: AshlarIcon(AshlarIconsRoundedStroke.plus)))
/// ```
class Tooltip extends StatefulWidget {
  const Tooltip({
    super.key,
    required this.message,
    required this.child,
    this.below = false,
  });

  final String message;
  final Widget child;

  /// Under the child instead of over it. It flips when there is no room.
  final bool below;

  @override
  State<Tooltip> createState() => _TooltipState();
}

class _TooltipState extends State<Tooltip> {
  final _tip = GlobalKey<RawTooltipState>();

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (focused) {
        if (!focused) {
          RawTooltip.dismissAllToolTips();
        } else if (FocusManager.instance.highlightMode ==
            FocusHighlightMode.traditional) {
          _tip.currentState?.ensureTooltipVisible();
        }
      },
      child: RawTooltip(
        key: _tip,
        // The message goes on the control itself, so a screen reader hears it with the
        // control's name rather than as a separate item.
        semanticsTooltip: null,
        hoverDelay: Duration.zero,
        positionDelegate: (p) {
          const gap = 4.0, margin = 8.0;
          final above =
              p.target.dy -
              p.targetSize.height / 2 -
              gap -
              p.tooltipSize.height;
          final under = p.target.dy + p.targetSize.height / 2 + gap;
          final fitsAbove = above >= margin,
              fitsUnder =
                  under + p.tooltipSize.height <= p.overlaySize.height - margin;
          final down = widget.below
              ? (fitsUnder || !fitsAbove)
              : !(fitsAbove || !fitsUnder);
          final x = (p.target.dx - p.tooltipSize.width / 2).clamp(
            margin,
            (p.overlaySize.width - p.tooltipSize.width - margin).clamp(
              margin,
              double.infinity,
            ),
          );
          return Offset(x, down ? under : above);
        },
        tooltipBuilder: (context, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: .95, end: 1.0).animate(animation),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: c.primary,
                borderRadius: BorderRadius.circular(t.radiusMd),
              ),
              child: Text(
                widget.message,
                style: t.text.xs.copyWith(color: c.primaryForeground),
              ),
            ),
          ),
        ),
        child: MergeSemantics(
          child: Semantics(tooltip: widget.message, child: widget.child),
        ),
      ),
    );
  }
}
