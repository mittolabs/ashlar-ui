import 'package:flutter/widgets.dart';

import 'theme.dart';

/// A ticket: [top] and [bottom] on one card, with a bite out of each side where they meet
/// and a dashed line between them, the way a ticket tears. The bites follow the join, so
/// they stay level with it whatever the two hold and however large the text.
///
/// ```dart
/// Ticket(
///   top: Text('SFO to NRT, 11h 05m'),
///   bottom: Text('Seat 14A, gate B22'),
/// )
/// ```
@Deprecated("Ticket: a shape from one design, not Ashlar UI's. Draw it in your app with a ShapeBorder of your own, or keep this copy. Goes in a later release.")
class Ticket extends StatelessWidget {
  const Ticket({
    super.key,
    required this.top,
    required this.bottom,
    this.padding = const EdgeInsets.all(20),
    this.bite = 10,
    this.tear = true,
  });

  /// Above the tear: usually what the ticket is for.
  final Widget top;

  /// Below it: usually the details, the seat or the code.
  final Widget bottom;

  /// Round each half's content.
  final EdgeInsetsGeometry padding;

  /// How far each bite reaches into the card.
  final double bite;

  /// The dashed line across the join; false leaves only the bites.
  final bool tear;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    TicketHalf half(bool upper) => TicketHalf(
      upper: upper,
      radius: t.radiusXl,
      bite: bite,
      tear: tear && !upper ? c.border : null,
      side: BorderSide(color: c.border),
    );
    return DefaultTextStyle.merge(
      style: TextStyle(color: c.cardForeground),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: ShapeDecoration(color: c.card, shape: half(true)),
            child: Padding(padding: padding, child: top),
          ),
          DecoratedBox(
            decoration: ShapeDecoration(color: c.card, shape: half(false)),
            child: Padding(padding: padding, child: bottom),
          ),
        ],
      ),
    );
  }
}

/// One half of a [Ticket]: rounded on its outer side, bitten at its two corners on the
/// join. The join itself has no border; the lower half draws [tear] across it, dashed.
@Deprecated("TicketHalf: part of Ticket, which is deprecated. Goes in a later release.")
class TicketHalf extends ShapeBorder {
  const TicketHalf({
    required this.upper,
    this.radius = 16,
    this.bite = 10,
    this.tear,
    this.side = BorderSide.none,
  });

  /// The half above the join, or the one below it.
  final bool upper;
  final double radius;
  final double bite;

  /// The dashed line's colour, or null for none.
  final Color? tear;
  final BorderSide side;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  /// The outline with the join left open, for the border to follow.
  Path _edge(Rect r) {
    final b = bite, rad = Radius.circular(radius), cut = Radius.circular(b);
    if (upper) {
      return Path()
        ..moveTo(r.left + b, r.bottom)
        ..arcToPoint(Offset(r.left, r.bottom - b), radius: cut, clockwise: false)
        ..lineTo(r.left, r.top + radius)
        ..arcToPoint(Offset(r.left + radius, r.top), radius: rad)
        ..lineTo(r.right - radius, r.top)
        ..arcToPoint(Offset(r.right, r.top + radius), radius: rad)
        ..lineTo(r.right, r.bottom - b)
        ..arcToPoint(Offset(r.right - b, r.bottom), radius: cut, clockwise: false);
    }
    return Path()
      ..moveTo(r.right - b, r.top)
      ..arcToPoint(Offset(r.right, r.top + b), radius: cut, clockwise: false)
      ..lineTo(r.right, r.bottom - radius)
      ..arcToPoint(Offset(r.right - radius, r.bottom), radius: rad)
      ..lineTo(r.left + radius, r.bottom)
      ..arcToPoint(Offset(r.left, r.bottom - radius), radius: rad)
      ..lineTo(r.left, r.top + b)
      ..arcToPoint(Offset(r.left + b, r.top), radius: cut, clockwise: false);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _edge(rect)..close();

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _edge(rect.deflate(side.width))..close();

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style != BorderStyle.none) {
      canvas.drawPath(_edge(rect.deflate(side.width / 2)), side.toPaint());
    }
    if (tear case final color?) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = side.width == 0 ? 1 : side.width;
      for (var x = rect.left + bite + 6; x < rect.right - bite - 6; x += 10) {
        canvas.drawLine(
          Offset(x, rect.top),
          Offset((x + 5).clamp(x, rect.right - bite - 6), rect.top),
          paint,
        );
      }
    }
  }

  @override
  ShapeBorder scale(double t) => TicketHalf(
    upper: upper,
    radius: radius * t,
    bite: bite * t,
    tear: tear,
    side: side.scale(t),
  );
}
