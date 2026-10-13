// Ashlar UI: Toggle Group. Copied into your app by `ashlar add toggle-group`; it is yours to
// change.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'group.dart';
import 'toggle.dart';

/// One choice in a [ToggleGroup].
@immutable
class ToggleGroupItem<T> {
  const ToggleGroupItem(
    this.value,
    this.child, {
    this.semanticLabel,
    this.enabled = true,
  });

  final T value;
  final Widget child;
  final String? semanticLabel;
  final bool enabled;
}

/// Toggles joined into one piece. Without [multiple], pressing one releases the rest, and
/// pressing the pressed one releases it. The arrow keys move between them.
///
/// ```dart
/// ToggleGroup<TextAlign>(
///   values: {align},
///   onChanged: (v) => setState(() => align = v.firstOrNull ?? TextAlign.left),
///   items: [
///     ToggleGroupItem(TextAlign.left, AshlarIcon(AshlarIconsRoundedStroke.alignLeft), semanticLabel: 'Align left'),
///     ToggleGroupItem(TextAlign.center, AshlarIcon(AshlarIconsRoundedStroke.alignCenter), semanticLabel: 'Centre'),
///   ],
/// )
/// ```
class ToggleGroup<T> extends StatelessWidget {
  const ToggleGroup({
    super.key,
    required this.values,
    required this.onChanged,
    required this.items,
    this.multiple = false,
    this.variant = ToggleVariant.outline,
    this.size = ToggleSize.md,
    this.semanticLabel,
  });

  /// The pressed ones.
  final Set<T> values;

  /// Null disables the group.
  final ValueChanged<Set<T>>? onChanged;
  final List<ToggleGroupItem<T>> items;
  final bool multiple;
  final ToggleVariant variant;
  final ToggleSize size;

  /// What the group sets, read before it: 'Text alignment'.
  final String? semanticLabel;

  void _press(T value, bool on) {
    final next = multiple ? {...values} : <T>{};
    if (on) {
      next.add(value);
    } else {
      next.remove(value);
    }
    onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: semanticLabel,
    child: Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowRight): NextFocusIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown): NextFocusIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft): PreviousFocusIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): PreviousFocusIntent(),
      },
      child: FocusTraversalGroup(
        child: IntrinsicHeight(
          child: JoinedGroup(
            children: [
              for (final item in items)
                Toggle(
                  pressed: values.contains(item.value),
                  onChanged: onChanged == null || !item.enabled
                      ? null
                      : (on) => _press(item.value, on),
                  variant: variant,
                  size: size,
                  semanticLabel: item.semanticLabel,
                  child: item.child,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
