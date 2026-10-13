// Ashlar UI: Card. Copied into your app by `ashlar add card`; it is yours to change.

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// A panel on the page, usually [CardHeader], [CardContent] and [CardFooter] in order.
///
/// ```dart
/// Card(children: [
///   CardHeader(title: Text('Payment'), description: Text('Pay by card or mobile money.')),
///   CardContent(child: ...),
///   CardFooter(children: [Button(onPressed: pay, child: Text('Pay'))]),
/// ])
/// ```
class Card extends StatelessWidget {
  const Card({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: t.colors.card,
        borderRadius: BorderRadius.circular(t.radiusXl),
        border: Border.all(color: t.colors.border),
        boxShadow: t.shadowSm,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: t.colors.cardForeground),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, child) in children.indexed) ...[
              if (i > 0) const SizedBox(height: 24),
              child,
            ],
          ],
        ),
      ),
    );
  }
}

/// A card's title and description, with an optional [action] at the top right.
class CardHeader extends StatelessWidget {
  const CardHeader({super.key, this.title, this.description, this.action});

  final Widget? title;
  final Widget? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  DefaultTextStyle.merge(
                    style: t.text.base.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                    child: title!,
                  ),
                if (title != null && description != null)
                  const SizedBox(height: 6),
                if (description != null)
                  DefaultTextStyle.merge(
                    style: t.text.sm.copyWith(color: t.colors.mutedForeground),
                    child: description!,
                  ),
              ],
            ),
          ),
          if (action != null) ...[const SizedBox(width: 16), action!],
        ],
      ),
    );
  }
}

/// A card's body.
class CardContent extends StatelessWidget {
  const CardContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: child,
  );
}

/// A card's actions, in a row at its foot.
class CardFooter extends StatelessWidget {
  const CardFooter({
    super.key,
    required this.children,
    this.alignment = MainAxisAlignment.start,
  });

  final List<Widget> children;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Row(
      mainAxisAlignment: alignment,
      children: [
        for (final (i, child) in children.indexed) ...[
          if (i > 0) const SizedBox(width: 8),
          child,
        ],
      ],
    ),
  );
}
