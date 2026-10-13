// Ashlar UI: Swipe Actions. Copied into your app by `ashlar add swipe-actions`; it is
// yours to change.

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'pressable.dart';
import 'theme.dart';

/// One action behind a row: archive, delete, pin.
@immutable
class SwipeAction {
  const SwipeAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.destructive = false,
  });

  /// What it does, under its icon and to a screen reader.
  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  /// Drawn in the destructive colour, for what cannot be undone.
  final bool destructive;
}

/// A row with actions behind it, as phone lists have: swipe it aside to show them, then
/// press one. Swiped all the way across, it does the first action on that side.
///
/// A screen reader is offered the actions directly, without swiping. Where there is a
/// pointer and a keyboard, put the same actions in a menu on the row as well.
///
/// ```dart
/// SwipeActions(
///   end: [SwipeAction(label: 'Delete', icon: AshlarIcon(AshlarIconsRoundedStroke.trash), destructive: true, onPressed: delete)],
///   child: Item(title: Text('Invoice 2041')),
/// )
/// ```
class SwipeActions extends StatefulWidget {
  const SwipeActions({
    super.key,
    required this.child,
    this.start = const [],
    this.end = const [],
    this.fullSwipe = true,
    this.actionWidth = 72,
  });

  /// The row.
  final Widget child;

  /// Behind the row's start, shown by swiping towards the end.
  final List<SwipeAction> start;

  /// Behind the row's end, shown by swiping towards the start.
  final List<SwipeAction> end;

  /// Swiped all the way across, it does the first action on that side.
  final bool fullSwipe;

  /// Each action's width.
  final double actionWidth;

  @override
  State<SwipeActions> createState() => _SwipeActionsState();
}

class _SwipeActionsState extends State<SwipeActions>
    with SingleTickerProviderStateMixin {
  // How far the row has moved, in logical pixels: towards the end is positive.
  late final AnimationController _offset =
      AnimationController.unbounded(vsync: this)..addListener(() {
        final open = _offset.value != 0;
        if (open != _open) setState(() => _open = open);
      });
  double _width = 0;

  /// Moved aside: a tap then closes it, rather than reaching the row.
  var _open = false;

  double get _startRoom => widget.start.length * widget.actionWidth;
  double get _endRoom => widget.end.length * widget.actionWidth;

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  void _settle(double to) => _offset.animateTo(
    to,
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOutCubic,
  );

  void close() => _settle(0);

  void _drag(DragUpdateDetails d) {
    final rtl = isRtl(context);
    final by = rtl ? -d.primaryDelta! : d.primaryDelta!;
    var next = _offset.value + by;
    // Only as far as there are actions that way; past the actions only on a full swipe.
    final most = widget.fullSwipe && widget.start.isNotEmpty
        ? _width
        : _startRoom;
    final least = widget.fullSwipe && widget.end.isNotEmpty
        ? -_width
        : -_endRoom;
    next = next.clamp(least, most);
    _offset.value = next;
  }

  void _release(DragEndDetails d) {
    final v = _offset.value;
    final speed = (isRtl(context) ? -1 : 1) * (d.primaryVelocity ?? 0);
    // Across most of the row: the first action on that side.
    if (widget.fullSwipe && _width > 0 && v.abs() > _width * .6) {
      final action = v > 0 ? widget.start.first : widget.end.first;
      _settle(0);
      action.onPressed();
      return;
    }
    if (v > 0) {
      _settle(v > _startRoom / 2 || speed > 400 ? _startRoom : 0);
    } else if (v < 0) {
      _settle(-v > _endRoom / 2 || speed < -400 ? -_endRoom : 0);
    }
  }

  Widget _actions(List<SwipeAction> actions, bool atStart) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final a in actions)
          Pressable(
            semanticLabel: a.label,
            onPressed: () {
              close();
              a.onPressed();
            },
            builder: (context, state) => Container(
              width: widget.actionWidth,
              color: a.destructive ? c.destructive : c.muted,
              alignment: Alignment.center,
              child: IconTheme.merge(
                data: IconThemeData(
                  color: a.destructive ? c.destructiveForeground : c.foreground,
                  size: 18,
                ),
                child: DefaultTextStyle.merge(
                  style: t.text.xs.copyWith(
                    color: a.destructive
                        ? c.destructiveForeground
                        : c.foreground,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      a.icon,
                      const SizedBox(height: 4),
                      Text(a.label),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AshlarTheme.of(context).colors;
    final rtl = isRtl(context);
    return Semantics(
      // Without swiping: each action as an action on the row.
      customSemanticsActions: {
        for (final a in [...widget.start, ...widget.end])
          CustomSemanticsAction(label: a.label): a.onPressed,
      },
      child: LayoutBuilder(
        builder: (context, box) {
          _width = box.maxWidth;
          return ClipRect(
            child: AnimatedBuilder(
              animation: _offset,
              builder: (context, child) {
                final v = _offset.value;
                return Stack(
                  children: [
                    // Behind the row: only the side being shown, so nothing peeks out.
                    if (v > 0)
                      Positioned.fill(
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: ExcludeSemantics(
                            excluding: v < _startRoom,
                            child: _actions(widget.start, true),
                          ),
                        ),
                      ),
                    if (v < 0)
                      Positioned.fill(
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: ExcludeSemantics(
                            excluding: -v < _endRoom,
                            child: _actions(widget.end, false),
                          ),
                        ),
                      ),
                    Transform.translate(
                      offset: Offset(rtl ? -v : v, 0),
                      child: child,
                    ),
                  ],
                );
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: _drag,
                onHorizontalDragEnd: _release,
                // A tap on an open row closes it rather than reaching the row.
                onTap: _open ? close : null,
                child: IgnorePointer(
                  ignoring: _open,
                  child: ColoredBox(color: c.background, child: widget.child),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
