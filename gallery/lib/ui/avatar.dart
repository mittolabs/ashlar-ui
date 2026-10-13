// Ashlar UI: Avatar. Copied into your app by `ashlar add avatar`; it is yours to change.

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// A person's picture in a circle, or their initials while it loads or when it fails.
///
/// ```dart
/// Avatar(image: NetworkImage(user.photoUrl), fallback: 'WM', semanticLabel: 'Wanjiru Mwangi')
/// Avatar(fallback: 'WM', size: 40)
/// ```
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.image,
    required this.fallback,
    this.size = 32,
    this.semanticLabel,
  });

  final ImageProvider? image;

  /// Usually initials: one or two letters.
  final String fallback;
  final double size;

  /// Who it is, for screen readers. Without it the avatar is left out of what they read.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final initials = Container(
      color: t.colors.muted,
      alignment: Alignment.center,
      child: Text(
        fallback,
        style: t.text.sm.copyWith(
          color: t.colors.mutedForeground,
          fontSize: size * .4,
          height: 1,
          // The font's spare leading split above and below, so the text sits centred.
          leadingDistribution: TextLeadingDistribution.even,
        ),
        maxLines: 1,
      ),
    );
    final body = SizedBox.square(
      dimension: size,
      child: ClipOval(
        child: image == null
            ? initials
            : Image(
                image: image!,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, sync) =>
                    frame == null && !sync ? initials : child,
                errorBuilder: (context, error, stack) => initials,
              ),
      ),
    );
    return semanticLabel == null
        ? ExcludeSemantics(child: body)
        : Semantics(
            label: semanticLabel,
            image: true,
            child: ExcludeSemantics(child: body),
          );
  }
}
