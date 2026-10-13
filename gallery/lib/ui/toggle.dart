// Ashlar UI: Toggle. Copied into your app by `ashlar add toggle`; it is yours to change.

import 'package:flutter/widgets.dart';

import 'group.dart';
import 'pressable.dart';
import 'theme.dart';

enum ToggleVariant {
  /// No border until it is on.
  plain,

  /// A border all the time.
  outline,
}

enum ToggleSize { sm, md, lg }

/// A button that stays pressed: bold, italic, a filter. Give an icon-only toggle a
/// [semanticLabel].
///
/// ```dart
/// Toggle(pressed: bold, onChanged: (v) => setState(() => bold = v), semanticLabel: 'Bold', child: AshlarIcon(AshlarIconsRoundedStroke.bold))
/// ```
class Toggle extends StatelessWidget {
  const Toggle({
    super.key,
    required this.pressed,
    required this.onChanged,
    required this.child,
    this.variant = ToggleVariant.plain,
    this.size = ToggleSize.md,
    this.semanticLabel,
  });

  /// Whether it is on.
  final bool pressed;

  /// Null disables it.
  final ValueChanged<bool>? onChanged;

  /// Its label or icon.
  final Widget child;

  /// Plain, or with a border all the time.
  final ToggleVariant variant;

  /// Small, medium or large.
  final ToggleSize size;

  /// What a screen reader calls it, for a toggle that shows an icon alone.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final height = t.control(switch (size) {
      ToggleSize.sm => 32.0,
      ToggleSize.md => 36.0,
      ToggleSize.lg => 40.0,
    });
    return Pressable(
      onPressed: onChanged == null ? null : () => onChanged!(!pressed),
      toggled: pressed,
      semanticLabel: semanticLabel,
      builder: (context, state) {
        final fg = pressed
            ? c.accentForeground
            : (state.hovered ? c.mutedForeground : c.foreground);
        return Opacity(
          opacity: state.enabled ? 1 : .5,
          child: AnimatedContainer(
            duration: t.duration,
            // A height at least: larger text makes it taller rather than being cut off.
            constraints: BoxConstraints(minWidth: height, minHeight: height),
            padding: EdgeInsets.symmetric(
              horizontal: size == ToggleSize.sm ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: pressed
                  ? c.accent
                  : (state.hovered ? c.muted : c.muted.withValues(alpha: 0)),
              borderRadius: joinedRadius(context, t.radiusMd),
              border: variant == ToggleVariant.outline
                  ? joinedBorder(context, state.focused ? c.ring : c.input)
                  : null,
              boxShadow: [
                if (state.focused) ...t.focusRing,
                if (variant == ToggleVariant.outline) ...t.shadowXs,
              ],
            ),
            // Centred, and as wide as its label unless a group stretches it.
            child: Align(
              widthFactor: 1,
              child: DefaultTextStyle.merge(
                style: t.text.sm.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                child: IconTheme.merge(
                  data: IconThemeData(color: fg, size: 16),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
