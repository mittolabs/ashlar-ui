// Ashlar UI: Bubble. Copied into your app by `ashlar add bubble`; it is yours to change.

import 'package:flutter/widgets.dart';

import 'message.dart';
import 'pressable.dart';
import 'theme.dart';

/// How a [Bubble] is filled.
enum BubbleVariant {
  /// Solid in the primary colour: usually what you sent.
  primary,
  secondary,

  /// Grey: usually what the other side sent.
  muted,

  /// A light wash of the primary colour.
  tinted,
  outline,

  /// No fill and no padding: an assistant's long answer, read as a page.
  ghost,

  /// Something went wrong: it was not sent.
  destructive,
}

/// Where a [Bubble]'s reactions sit.
enum BubbleReactionsSide { top, bottom }

/// What was said, in a rounded fill, no wider than four fifths of the room. Inside a
/// [Message] it sits on the message's side.
///
/// ```dart
/// Bubble(variant: BubbleVariant.muted, child: Text('See you at ten.'))
/// Bubble(reactions: Text('👍 2'), child: Text('Shipped.'))
/// ```
class Bubble extends StatelessWidget {
  const Bubble({
    super.key,
    required this.child,
    this.variant = BubbleVariant.primary,
    this.reactions,
    this.reactionsSide = BubbleReactionsSide.bottom,
    this.onPressed,
    this.semanticLabel,
  });

  final Widget child;
  final BubbleVariant variant;

  /// A small pill over the bubble's edge: emoji counts, or buttons to react with.
  final Widget? reactions;
  final BubbleReactionsSide reactionsSide;

  /// Makes the whole bubble a button: a suggested reply, say.
  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final dark = c.background.computeLuminance() < .5;
    final end = messageAlignOf(context) == MessageAlign.end;
    final (fill, ink, border) = switch (variant) {
      BubbleVariant.primary => (c.primary, c.primaryForeground, null),
      BubbleVariant.secondary => (c.secondary, c.secondaryForeground, null),
      BubbleVariant.muted => (c.muted, c.foreground, null),
      BubbleVariant.tinted => (
        Color.lerp(c.background, c.primary, dark ? .25 : .08)!,
        c.foreground,
        null,
      ),
      BubbleVariant.outline => (c.background, c.foreground, c.border),
      BubbleVariant.ghost => (const Color(0x00000000), c.foreground, null),
      BubbleVariant.destructive => (
        c.destructive.withValues(alpha: dark ? .2 : .1),
        c.destructive,
        null,
      ),
    };
    final ghost = variant == BubbleVariant.ghost;
    Widget content(bool hovered) => AnimatedContainer(
      duration: t.duration,
      padding: ghost
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: hovered && onPressed != null ? Color.lerp(fill, ink, .08) : fill,
        borderRadius: ghost ? null : BorderRadius.circular(t.radiusXl),
        border: border == null ? null : Border.all(color: border),
      ),
      child: DefaultTextStyle.merge(
        style: t.text.sm.copyWith(color: ink, height: 1.6),
        child: IconTheme.merge(
          data: IconThemeData(color: ink),
          child: child,
        ),
      ),
    );
    Widget bubble = onPressed == null
        ? content(false)
        : Pressable(
            onPressed: onPressed,
            semanticLabel: semanticLabel,
            builder: (context, states) => content(states.hovered),
          );
    if (reactions != null) {
      final top = reactionsSide == BubbleReactionsSide.top;
      bubble = Padding(
        padding: EdgeInsets.only(top: top ? 14 : 0, bottom: top ? 0 : 14),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            bubble,
            PositionedDirectional(
              top: top ? -14 : null,
              bottom: top ? null : -14,
              end: end ? null : 12,
              start: end ? 12 : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: c.muted,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: c.background, width: 3),
                ),
                child: DefaultTextStyle.merge(
                  style: t.text.sm.copyWith(color: c.foreground),
                  child: reactions!,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (ghost) return bubble;
    return LayoutBuilder(
      builder: (context, box) => ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: box.maxWidth.isFinite ? box.maxWidth * .8 : double.infinity,
        ),
        child: bubble,
      ),
    );
  }
}

/// Bubbles sent one after another, close together on the same side.
class BubbleGroup extends StatelessWidget {
  const BubbleGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final end = messageAlignOf(context) == MessageAlign.end;
    return Column(
      crossAxisAlignment: end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        for (final (i, c) in children.indexed) ...[
          if (i > 0) const SizedBox(height: 4),
          c,
        ],
      ],
    );
  }
}
