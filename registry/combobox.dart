// Ashlar UI: Combobox. Copied into your app by `ashlar add combobox`; it is yours to change.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'command.dart';
import 'popover.dart';
import 'pressable.dart';
import 'theme.dart';

/// One choice in a [Combobox].
@immutable
class ComboboxOption<T> {
  const ComboboxOption(this.value, this.label, {this.keywords = const []});

  final T value;
  final String label;
  final List<String> keywords;
}

/// A Select you can search: it opens a list with a search box, for choosing from more
/// options than fit a plain list.
///
/// ```dart
/// Combobox<String>(
///   value: county,
///   placeholder: 'Choose a county',
///   options: [for (final c in counties) ComboboxOption(c.code, c.name)],
///   onChanged: (v) => setState(() => county = v),
/// )
/// ```
class Combobox<T> extends StatefulWidget {
  const Combobox({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.placeholder = 'Choose…',
    this.searchPlaceholder = 'Search…',
    this.emptyText = 'Nothing found.',
    this.semanticLabel,
  });

  final T? value;
  final List<ComboboxOption<T>> options;

  /// Null disables it.
  final ValueChanged<T>? onChanged;
  final String placeholder, searchPlaceholder, emptyText;
  final String? semanticLabel;

  @override
  State<Combobox<T>> createState() => _ComboboxState<T>();
}

class _ComboboxState<T> extends State<Combobox<T>> {
  final _menu = MenuController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final chosen = widget.options
        .where((o) => o.value == widget.value)
        .firstOrNull;
    return RawMenuAnchor(
      controller: _menu,
      childFocusNode: _focus,
      onClose: _focus.requestFocus,
      overlayBuilder: (context, info) => PopoverPanel(
        info: info,
        // The search field takes all the width it is given, so the width is set: the
        // trigger's, and never narrower than 200.
        width: info.anchorRect.width < 200 ? 200 : info.anchorRect.width,
        child: Command(
          placeholder: widget.searchPlaceholder,
          emptyText: widget.emptyText,
          groups: [
            CommandGroup([
              for (final o in widget.options)
                CommandItem(
                  o.label,
                  keywords: o.keywords,
                  leading: o.value == widget.value
                      ? const AshlarIcon(AshlarIconsRoundedStroke.check)
                      : const SizedBox(width: 16),
                  onSelected: () {
                    _menu.close();
                    widget.onChanged?.call(o.value);
                  },
                ),
            ]),
          ],
        ),
      ),
      child: Pressable(
        focusNode: _focus,
        onPressed: widget.onChanged == null
            ? null
            : () => _menu.isOpen ? _menu.close() : _menu.open(),
        semanticLabel: widget.semanticLabel,
        semanticValue: widget.semanticLabel == null
            ? null
            : (chosen?.label ?? widget.placeholder),
        builder: (context, state) => Opacity(
          opacity: state.enabled ? 1 : .5,
          child: AnimatedContainer(
            duration: t.duration,
            height: 36,
            padding: const EdgeInsets.only(left: 12, right: 10),
            decoration: BoxDecoration(
              color: state.hovered ? c.accent : c.background,
              borderRadius: BorderRadius.circular(t.radiusMd),
              border: Border.all(color: state.focused ? c.ring : c.input),
              boxShadow: [if (state.focused) ...t.focusRing, ...t.shadowXs],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    chosen?.label ?? widget.placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.text.sm.copyWith(
                      color: chosen == null ? c.mutedForeground : c.foreground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AshlarIcon(
                  AshlarIconsRoundedStroke.chevronsUpDown,
                  size: 16,
                  color: c.mutedForeground.withValues(alpha: .5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
