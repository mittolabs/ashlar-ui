// Ashlar UI: Select. Copied into your app by `ashlar add select`; it is yours to change.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'dropdown_menu.dart';
import 'popover.dart';
import 'pressable.dart';
import 'theme.dart';

/// One choice in a [Select].
@immutable
class SelectOption<T> {
  const SelectOption(this.value, this.label, {this.enabled = true});

  final T value;
  final String label;
  final bool enabled;
}

/// Picks one value from a list that opens under it. It opens on a tap, Enter, Space or
/// the down arrow, with the chosen option focused.
///
/// ```dart
/// Select<String>(
///   value: county,
///   placeholder: 'Choose a county',
///   options: [SelectOption('nbo', 'Nairobi'), SelectOption('msa', 'Mombasa')],
///   onChanged: (v) => setState(() => county = v),
/// )
/// ```
class Select<T> extends StatefulWidget {
  const Select({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.placeholder,
    this.error = false,
    this.focusNode,
    this.semanticLabel,
  });

  final T? value;
  final List<SelectOption<T>> options;

  /// Null disables it.
  final ValueChanged<T>? onChanged;
  final String? placeholder;

  /// Draws it as invalid.
  final bool error;
  final FocusNode? focusNode;

  /// What it chooses, for screen readers: 'County'. The chosen option is read after it.
  final String? semanticLabel;

  @override
  State<Select<T>> createState() => _SelectState<T>();
}

class _SelectState<T> extends State<Select<T>> {
  final _menu = MenuController();
  FocusNode? _ownFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void dispose() {
    _ownFocus?.dispose();
    super.dispose();
  }

  void _toggle() => _menu.isOpen ? _menu.close() : _menu.open();

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final chosen = widget.options
        .where((o) => o.value == widget.value)
        .firstOrNull;
    final enabled = widget.onChanged != null;
    return RawMenuAnchor(
      controller: _menu,
      childFocusNode: _focus,
      // Focus goes back to the trigger when the list closes.
      onClose: () => _focus.requestFocus(),
      overlayBuilder: (context, info) => PopoverPanel(
        info: info,
        matchWidth: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: MenuList(
            children: [
              for (final o in widget.options)
                MenuItem(
                  autofocus: o.value == widget.value,
                  selected: o.value == widget.value,
                  trailing: o.value == widget.value
                      ? const AshlarIcon(AshlarIconsRoundedStroke.check)
                      : const SizedBox(width: 16),
                  onPressed: o.enabled
                      ? () => widget.onChanged?.call(o.value)
                      : null,
                  child: Text(o.label),
                ),
            ],
          ),
        ),
      ),
      child: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.arrowDown): ActivateIntent(),
        },
        child: Pressable(
          onPressed: enabled ? _toggle : null,
          focusNode: _focus,
          semanticLabel: widget.semanticLabel,
          semanticValue: widget.semanticLabel == null
              ? null
              : (chosen?.label ?? widget.placeholder),
          builder: (context, state) {
            final ring = widget.error ? c.destructive : c.ring;
            return Opacity(
              opacity: state.enabled ? 1 : .5,
              child: AnimatedContainer(
                duration: t.duration,
                height: 36,
                padding: const EdgeInsets.only(left: 12, right: 10),
                decoration: BoxDecoration(
                  color: t.brightness == Brightness.dark
                      ? Color.alphaBlend(
                          c.input.withValues(alpha: state.hovered ? .5 : .3),
                          c.background,
                        )
                      : c.background,
                  borderRadius: BorderRadius.circular(t.radiusMd),
                  border: Border.all(
                    color: widget.error
                        ? c.destructive
                        : (state.focused ? c.ring : c.input),
                  ),
                  boxShadow: [
                    if (state.focused)
                      BoxShadow(
                        color: ring.withValues(alpha: widget.error ? .2 : .5),
                        spreadRadius: 3,
                      ),
                    ...t.shadowXs,
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        chosen?.label ?? widget.placeholder ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.text.sm.copyWith(
                          color: chosen == null
                              ? c.mutedForeground
                              : c.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AshlarIcon(
                      AshlarIconsRoundedStroke.chevronDown,
                      size: 16,
                      color: c.mutedForeground.withValues(alpha: .5),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
