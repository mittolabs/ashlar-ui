// Ashlar UI: Switch. Copied into your app by `ashlar add switch`; it is yours to change.

import 'package:flutter/widgets.dart';

import 'pressable.dart';
import 'theme.dart';

/// An on and off switch, for a setting that takes effect at once. Give it a
/// [semanticLabel], or put it in a row with a Text.
///
/// ```dart
/// Switch(value: notify, onChanged: (v) => setState(() => notify = v), semanticLabel: 'Notifications')
/// ```
class Switch extends StatelessWidget {
  const Switch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return Pressable(
      onPressed: onChanged == null ? null : () => onChanged!(!value),
      toggled: value,
      semanticLabel: semanticLabel,
      focusNode: focusNode,
      autofocus: autofocus,
      builder: (context, state) => Opacity(
        opacity: state.enabled ? 1 : .5,
        child: AnimatedContainer(
          duration: t.duration,
          width: 32,
          height: 18,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: value ? c.primary : c.input,
            borderRadius: BorderRadius.circular(9),
            boxShadow: [if (state.focused) ...t.focusRing, ...t.shadowXs],
          ),
          child: AnimatedAlign(
            duration: t.duration,
            curve: Curves.easeOutCubic,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: t.brightness == Brightness.dark && !value
                    ? c.foreground
                    : c.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
