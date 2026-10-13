// Ashlar UI: what every control is built on. Copied in by `ashlar add` with the first
// component that needs it; it is yours to change.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The states a control draws.
@immutable
class PressableState {
  const PressableState({this.hovered = false, this.pressed = false, this.focused = false, this.enabled = true});

  /// The pointer is over it.
  final bool hovered;

  /// It is held down, by pointer or key.
  final bool pressed;

  /// It has focus that came from the keyboard: the time to show a focus ring.
  final bool focused;
  final bool enabled;
}

/// A control's behaviour without its look: hover, press, keyboard focus, activation by
/// Enter and Space, a click cursor, and what a screen reader announces. [builder] draws
/// the look for each [PressableState].
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onPressed,
    required this.builder,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.button = true,
    this.toggled,
    this.checked,
  });

  /// Null disables it.
  final VoidCallback? onPressed;
  final Widget Function(BuildContext context, PressableState state) builder;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;

  /// Announced as a button.
  final bool button;

  /// Announced as a switch that is on or off.
  final bool? toggled;

  /// Announced as a checkbox that is checked or not.
  final bool? checked;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hovered = false, _pressed = false, _focused = false;

  bool get _enabled => widget.onPressed != null;

  void _activate([Intent? _]) {
    if (!_enabled) return;
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    // The visible text merges into the control's announcement: "Save, button".
    return MergeSemantics(
      child: Semantics(
      button: widget.button && widget.toggled == null && widget.checked == null,
      toggled: widget.toggled,
      checked: widget.checked,
      enabled: _enabled,
      label: widget.semanticLabel,
      onTap: _enabled ? _activate : null,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        enabled: _enabled,
        mouseCursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: _activate)},
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
          onTap: _enabled ? _activate : null,
          child: widget.builder(
            context,
            PressableState(hovered: _hovered && _enabled, pressed: _pressed, focused: _focused, enabled: _enabled),
          ),
        ),
      ),
      ),
    );
  }
}
