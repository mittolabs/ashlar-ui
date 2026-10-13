// Ashlar UI: Popover. Copied into your app by `ashlar add popover`; it is yours to change.
//
// Built on RawMenuAnchor from Flutter's widgets layer, which opens and closes the panel,
// closes it on Escape, and closes it when the page scrolls. This
// file closes the panel on a tap outside, places it and draws it. Dropdown Menu and Select use the same panel.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Which side of its trigger a panel opens on. It flips when there is no room.
enum PopoverSide { top, bottom }

/// How a panel lines up with its trigger.
enum PopoverAlign { start, center, end }

/// A panel that opens from a trigger and floats over the page: extra settings, a short
/// form, details. [builder] draws the trigger and gets the controller that opens it.
///
/// ```dart
/// Popover(
///   builder: (context, menu) => Button(onPressed: menu.open, child: Text('Dimensions')),
///   content: (context) => Column(children: [...]),
/// )
/// ```
class Popover extends StatefulWidget {
  const Popover({
    super.key,
    required this.builder,
    required this.content,
    this.controller,
    this.side = PopoverSide.bottom,
    this.align = PopoverAlign.center,
    this.width = 288,
  });

  final Widget Function(BuildContext context, MenuController controller)
  builder;
  final WidgetBuilder content;
  final MenuController? controller;
  final PopoverSide side;
  final PopoverAlign align;
  final double width;

  @override
  State<Popover> createState() => _PopoverState();
}

class _PopoverState extends State<Popover> {
  final _own = MenuController();

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return RawMenuAnchor(
      controller: widget.controller ?? _own,
      builder: (context, controller, _) => widget.builder(context, controller),
      overlayBuilder: (context, info) => PopoverPanel(
        info: info,
        side: widget.side,
        align: widget.align,
        width: widget.width,
        child: FocusScope(
          autofocus: true,
          // Scrolls when the room beside the trigger is shorter than the content.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: DefaultTextStyle.merge(
              style: t.text.sm,
              child: Builder(builder: widget.content),
            ),
          ),
        ),
      ),
    );
  }
}

/// The floating panel a Popover, Dropdown Menu or Select opens: placed against the
/// trigger in [info], flipped and kept on screen, and drawn with the popover colours.
class PopoverPanel extends StatelessWidget {
  const PopoverPanel({
    super.key,
    required this.info,
    required this.child,
    this.side = PopoverSide.bottom,
    this.align = PopoverAlign.start,
    this.width,
    this.minWidth = 128,
    this.matchWidth = false,
  });

  final RawMenuOverlayInfo info;
  final Widget child;
  final PopoverSide side;
  final PopoverAlign align;

  /// Null sizes the panel to its content.
  final double? width;
  final double minWidth;

  /// At least as wide as the trigger.
  final bool matchWidth;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final min = matchWidth ? info.anchorRect.width : minWidth;
    return CustomSingleChildLayout(
      // Opened at a point (a right-click), it is placed against that point instead.
      delegate: _Place(
        info.position == null
            ? info.anchorRect
            : Rect.fromLTWH(
                info.anchorRect.left + info.position!.dx,
                info.anchorRect.top + info.position!.dy,
                0,
                0,
              ),
        side,
        align,
      ),
      child: TapRegion(
        groupId: info.tapRegionGroupId,
        // RawMenuAnchor closes only submenus on a tap outside; the panel closes itself.
        onTapOutside: (_) => MenuController.maybeOf(context)?.close(),
        // RawMenuAnchor closes on DismissIntent; Escape inside the panel sends it.
        child: Shortcuts(
          includeSemantics: false,
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
          },
          child: _Entrance(
            fromTop: side == PopoverSide.bottom,
            duration: t.duration,
            child: Container(
              width: width == null ? null : (width! < min ? min : width),
              constraints: BoxConstraints(minWidth: min),
              decoration: BoxDecoration(
                color: c.popover,
                borderRadius: BorderRadius.circular(t.radiusMd),
                border: Border.all(color: c.border),
                boxShadow: t.shadowLg,
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: c.popoverForeground),
                child: IconTheme.merge(
                  data: IconThemeData(color: c.popoverForeground, size: 16),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Place extends SingleChildLayoutDelegate {
  _Place(this.anchor, this.side, this.align);

  final Rect anchor;
  final PopoverSide side;
  final PopoverAlign align;
  static const gap = 4.0, margin = 8.0;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final room = constraints.biggest;
    final below = room.height - anchor.bottom - gap - margin,
        above = anchor.top - gap - margin;
    final height = (side == PopoverSide.bottom
        ? (below >= 200 || below >= above ? below : above)
        : (above >= 200 || above >= below ? above : below));
    return BoxConstraints.loose(
      Size(room.width - margin * 2, height.clamp(0, room.height)),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size child) {
    var x = switch (align) {
      PopoverAlign.start => anchor.left,
      PopoverAlign.center => anchor.center.dx - child.width / 2,
      PopoverAlign.end => anchor.right - child.width,
    };
    x = x.clamp(
      margin,
      (size.width - child.width - margin).clamp(margin, double.infinity),
    );
    final fitsBelow =
        anchor.bottom + gap + child.height <= size.height - margin;
    final fitsAbove = anchor.top - gap - child.height >= margin;
    final down = side == PopoverSide.bottom
        ? (fitsBelow || !fitsAbove)
        : !(fitsAbove || !fitsBelow);
    final y = down ? anchor.bottom + gap : anchor.top - gap - child.height;
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_Place old) =>
      old.anchor != anchor || old.side != side || old.align != align;
}

/// Fades the panel in, grown from 95%, sliding a little from the trigger's side.
class _Entrance extends StatelessWidget {
  const _Entrance({
    required this.child,
    required this.fromTop,
    required this.duration,
  });

  final Widget child;
  final bool fromTop;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      child: child,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * (fromTop ? -8 : 8)),
          child: Transform.scale(
            scale: .95 + .05 * v,
            alignment: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
            child: child,
          ),
        ),
      ),
    );
  }
}
