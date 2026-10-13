// Ashlar UI: Item. Copied into your app by `ashlar add item`; it is yours to change.

import 'package:flutter/widgets.dart';

import 'pressable.dart';
import 'theme.dart';

enum ItemVariant {
  /// No border or fill.
  plain,

  /// A border round it.
  outline,

  /// A muted fill.
  muted,
}

/// A row in a list: something to the left (an icon, an avatar), a title and a
/// description, and actions to the right. With [onPressed] the whole row is a button.
///
/// ```dart
/// Item(
///   variant: ItemVariant.outline,
///   leading: AshlarIcon(AshlarIconsRoundedStroke.shieldCheck),
///   title: Text('Two-step sign in is on'),
///   description: Text('A code from your phone is asked for at each sign in.'),
///   trailing: Button(size: ButtonSize.sm, variant: ButtonVariant.outline, onPressed: manage, child: Text('Manage')),
/// )
/// ```
class Item extends StatelessWidget {
  const Item({
    super.key,
    required this.title,
    this.description,
    this.leading,
    this.trailing,
    this.variant = ItemVariant.plain,
    this.onPressed,
  });

  final Widget title;
  final Widget? description;
  final Widget? leading;
  final Widget? trailing;
  final ItemVariant variant;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    Widget body(bool hovered) => AnimatedContainer(
      duration: t.duration,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hovered
            ? c.accent.withValues(alpha: c.accent.a * .5)
            : (variant == ItemVariant.muted
                  ? c.muted.withValues(alpha: c.muted.a * .5)
                  : const Color(0x00000000)),
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(
          color: variant == ItemVariant.outline
              ? c.border
              : const Color(0x00000000),
        ),
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: c.foreground, size: 20),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 16)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle.merge(
                    style: t.text.sm.copyWith(
                      color: c.foreground,
                      fontWeight: FontWeight.w500,
                    ),
                    child: title,
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    DefaultTextStyle.merge(
                      style: t.text.sm.copyWith(color: c.mutedForeground),
                      child: description!,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 16), trailing!],
          ],
        ),
      ),
    );
    if (onPressed == null) return body(false);
    return Pressable(
      onPressed: onPressed,
      builder: (context, state) => body(state.hovered || state.focused),
    );
  }
}
