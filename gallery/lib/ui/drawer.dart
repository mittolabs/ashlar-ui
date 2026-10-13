// Ashlar UI: Drawer. Copied into your app by `ashlar add drawer`; it is yours to change.

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// The edge a drawer comes from.
enum DrawerSide { bottom, top, left, right }

/// Brings a panel in from an edge of the screen, the bottom by default, the way phones
/// show choices and short forms. Drag it back to its edge, tap outside or press Escape to
/// close it.
///
/// ```dart
/// showDrawer(
///   context: context,
///   builder: (context) => Drawer(
///     title: Text('Move goal'),
///     description: Text('Set your daily steps.'),
///     content: StepsPicker(),
///     footer: [Button(onPressed: () => Navigator.pop(context), child: Text('Done'))],
///   ),
/// );
/// ```
Future<T?> showDrawer<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  DrawerSide side = DrawerSide.bottom,
}) {
  final theme = AshlarTheme.of(context);
  return Navigator.of(context).push<T>(
    RawDialogRoute<T>(
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: const Color(0x80000000),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondary) => AshlarTheme(
        data: theme,
        child: _DrawerSide(
          side: side,
          child: Builder(builder: builder),
        ),
      ),
      transitionBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final from = switch (side) {
          DrawerSide.bottom => const Offset(0, 1),
          DrawerSide.top => const Offset(0, -1),
          DrawerSide.left => const Offset(-1, 0),
          DrawerSide.right => const Offset(1, 0),
        };
        return SlideTransition(
          position: Tween(begin: from, end: Offset.zero).animate(curved),
          child: child,
        );
      },
    ),
  );
}

class _DrawerSide extends InheritedWidget {
  const _DrawerSide({required this.side, required super.child});

  final DrawerSide side;

  @override
  bool updateShouldNotify(_DrawerSide old) => old.side != side;
}

/// The panel [showDrawer] brings in: a handle to drag (at the top and bottom), a header,
/// [content] and a [footer].
class Drawer extends StatefulWidget {
  const Drawer({
    super.key,
    this.title,
    this.description,
    this.content,
    this.footer = const [],
    this.maxWidth = 512,
  });

  final Widget? title;
  final Widget? description;
  final Widget? content;
  final List<Widget> footer;

  /// From the top or the bottom of a wide screen, the content is kept to this width,
  /// centred; from a side, the panel is this wide at most.
  final double maxWidth;

  @override
  State<Drawer> createState() => _DrawerState();
}

class _DrawerState extends State<Drawer> {
  /// How far it has been dragged back towards its edge.
  double _drag = 0;

  DrawerSide get _side =>
      context.dependOnInheritedWidgetOfExactType<_DrawerSide>()?.side ??
      DrawerSide.bottom;
  bool get _vertical => _side == DrawerSide.bottom || _side == DrawerSide.top;

  /// Positive is towards the drawer's own edge.
  double _towardsEdge(Offset delta) => switch (_side) {
    DrawerSide.bottom => delta.dy,
    DrawerSide.top => -delta.dy,
    DrawerSide.left => -delta.dx,
    DrawerSide.right => delta.dx,
  };

  void _end(double velocity, double extent) {
    // Back far enough, or flicked towards its edge: close. Otherwise it springs back.
    if (_drag > extent * .3 || velocity > 700) {
      Navigator.maybePop(context);
    } else {
      setState(() => _drag = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final side = _side, vertical = _vertical;
    final radius = Radius.circular(t.radiusLg);
    final screen = MediaQuery.sizeOf(context);
    final shift = switch (side) {
      DrawerSide.bottom => Offset(0, _drag),
      DrawerSide.top => Offset(0, -_drag),
      DrawerSide.left => Offset(-_drag, 0),
      DrawerSide.right => Offset(_drag, 0),
    };
    final handle = Container(
      margin: EdgeInsets.only(
        top: side == DrawerSide.bottom ? 16 : 0,
        bottom: side == DrawerSide.top ? 16 : 0,
      ),
      width: 100,
      height: 8,
      decoration: BoxDecoration(
        color: c.muted,
        borderRadius: BorderRadius.circular(4),
      ),
    );
    final body = Column(
      mainAxisSize: vertical ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: vertical
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (widget.title != null)
                Semantics(
                  header: true,
                  child: DefaultTextStyle.merge(
                    style: t.text.base.copyWith(fontWeight: FontWeight.w600),
                    textAlign: vertical ? TextAlign.center : null,
                    child: widget.title!,
                  ),
                ),
              if (widget.description != null) ...[
                const SizedBox(height: 6),
                DefaultTextStyle.merge(
                  style: TextStyle(color: c.mutedForeground),
                  textAlign: vertical ? TextAlign.center : null,
                  child: widget.description!,
                ),
              ],
            ],
          ),
        ),
        if (widget.content != null)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: widget.content,
            ),
          ),
        if (!vertical) const Spacer(),
        if (widget.footer.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, f) in widget.footer.indexed) ...[
                  if (i > 0) const SizedBox(height: 8),
                  f,
                ],
              ],
            ),
          ),
      ],
    );
    return Align(
      alignment: switch (side) {
        DrawerSide.bottom => Alignment.bottomCenter,
        DrawerSide.top => Alignment.topCenter,
        DrawerSide.left => Alignment.centerLeft,
        DrawerSide.right => Alignment.centerRight,
      },
      child: LayoutBuilder(
        builder: (context, box) {
          final extent = vertical
              ? screen.height * .8
              : (widget.maxWidth < screen.width * .8
                    ? widget.maxWidth
                    : screen.width * .8);
          void update(Offset delta) => setState(
            () =>
                _drag = (_drag + _towardsEdge(delta)).clamp(0, double.infinity),
          );
          return GestureDetector(
            onVerticalDragUpdate: vertical ? (d) => update(d.delta) : null,
            onVerticalDragEnd: vertical
                ? (d) => _end(
                    side == DrawerSide.bottom
                        ? d.primaryVelocity ?? 0
                        : -(d.primaryVelocity ?? 0),
                    extent,
                  )
                : null,
            onHorizontalDragUpdate: vertical ? null : (d) => update(d.delta),
            onHorizontalDragEnd: vertical
                ? null
                : (d) => _end(
                    side == DrawerSide.right
                        ? d.primaryVelocity ?? 0
                        : -(d.primaryVelocity ?? 0),
                    extent,
                  ),
            child: AnimatedContainer(
              duration: _drag == 0 ? t.duration : Duration.zero,
              transform: Matrix4.translationValues(shift.dx, shift.dy, 0),
              width: vertical ? null : extent,
              height: vertical ? null : double.infinity,
              constraints: vertical ? BoxConstraints(maxHeight: extent) : null,
              decoration: BoxDecoration(
                color: c.background,
                borderRadius: switch (side) {
                  DrawerSide.bottom => BorderRadius.vertical(top: radius),
                  DrawerSide.top => BorderRadius.vertical(bottom: radius),
                  DrawerSide.left => BorderRadius.horizontal(right: radius),
                  DrawerSide.right => BorderRadius.horizontal(left: radius),
                },
                border: Border.all(color: c.border),
                boxShadow: t.shadowLg,
              ),
              child: SafeArea(
                top: side != DrawerSide.bottom,
                bottom: side != DrawerSide.top,
                child: Semantics(
                  scopesRoute: true,
                  namesRoute: true,
                  explicitChildNodes: true,
                  child: DefaultTextStyle(
                    style: t.text.sm.copyWith(color: c.foreground),
                    child: vertical
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // The handle: a reminder it can be dragged, not a control.
                              if (side == DrawerSide.bottom) handle,
                              Flexible(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: widget.maxWidth,
                                  ),
                                  child: body,
                                ),
                              ),
                              if (side == DrawerSide.top) handle,
                            ],
                          )
                        : body,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
