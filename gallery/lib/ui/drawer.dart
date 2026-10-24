// Ashlar UI: Drawer. Copied into your app by `ashlar add drawer`; it is yours to change.

import 'package:flutter/widgets.dart';

import 'pressable.dart';
import 'theme.dart';

/// The edge a drawer comes from.
enum DrawerSide { bottom, top, left, right }

/// Brings a panel in from an edge of the screen, the bottom by default, the way phones
/// show choices and short forms. Drag it back to its edge, tap outside or press Escape to
/// close it.
///
/// Over the whole app, a tab bar included, unless [useRootNavigator] is false: then on
/// the nearest navigator, inside a tab of its own.
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
  bool useRootNavigator = true,
}) {
  final theme = AshlarTheme.of(context);
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    RawDialogRoute<T>(
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: const Color(0x80000000),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondary) => AshlarTheme(
        data: theme,
        child: _DrawerSide(
          side: side,
          child: AboveKeyboard(child: Builder(builder: builder)),
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

  /// The drawer's title.
  final Widget? title;

  /// A line under the title.
  final Widget? description;

  /// Its body, which scrolls when it is too tall.
  final Widget? content;

  /// Along the bottom: usually buttons.
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

/// Moves a [DrawerSheet] between its snaps, and says which one it rests at.
class DrawerSheetController extends ChangeNotifier {
  _DrawerSheetState? _sheet;
  int _snap = 0;

  /// The snap the sheet rests at, an index into [DrawerSheet.snaps].
  int get snap => _snap;

  /// Moves the sheet to the snap at [index], animated.
  Future<void> snapTo(int index) async => _sheet?._snapTo(index);

  void _rest(int index) {
    _snap = index;
    notifyListeners();
  }
}

/// A drawer that stays on the page: it rests at one of its [snaps] over what is behind it,
/// and is dragged or flicked between them, the way maps and music players show a panel
/// that is part of the screen rather than in front of it. Once it is at its highest snap,
/// its content scrolls; dragged down from the top of that content, it comes down with it.
///
/// Put it in a [Stack] over the page, and give [builder]'s scroll controller to the
/// content's scroll view:
///
/// ```dart
/// Stack(
///   children: [
///     const MapView(),
///     DrawerSheet(
///       snaps: const [.4, .9],
///       builder: (context, scroll) => ListView(controller: scroll, children: rides),
///     ),
///   ],
/// )
/// ```
///
/// The handle at the top is a control too: a tap, Enter or a screen reader's increase and
/// decrease move the sheet to the next snap.
class DrawerSheet extends StatefulWidget {
  const DrawerSheet({
    super.key,
    required this.builder,
    this.snaps = const [.4, .9],
    this.initialSnap = 0,
    this.controller,
    this.onSnap,
    this.maxWidth = 512,
    this.label = 'Sheet',
  }) : assert(snaps.length > 0);

  /// Its content, given the scroll controller its scroll view should use, so scrolling and
  /// dragging the sheet hand over to each other.
  final Widget Function(BuildContext context, ScrollController scroll) builder;

  /// The heights it rests at, as parts of the height it has (0 to 1), lowest first.
  final List<double> snaps;

  /// Where it starts, an index into [snaps].
  final int initialSnap;

  /// Moves it from outside, and says which snap it rests at.
  final DrawerSheetController? controller;

  /// When it comes to rest at a snap: its index in [snaps].
  final ValueChanged<int>? onSnap;

  /// On a wide screen, its width at most, centred.
  final double maxWidth;

  /// What a screen reader calls it.
  final String label;

  @override
  State<DrawerSheet> createState() => _DrawerSheetState();
}

class _DrawerSheetState extends State<DrawerSheet> {
  final _sheet = DraggableScrollableController();
  late int _snap = widget.initialSnap;

  @override
  void initState() {
    super.initState();
    widget.controller
      ?.._sheet = this
      .._snap = _snap;
    _sheet.addListener(_settle);
  }

  @override
  void didUpdateWidget(DrawerSheet old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?._sheet = null;
      widget.controller
        ?.._sheet = this
        .._snap = _snap;
    }
  }

  @override
  void dispose() {
    widget.controller?._sheet = null;
    _sheet
      ..removeListener(_settle)
      ..dispose();
    super.dispose();
  }

  /// The snap nearest to where the sheet is.
  int _nearest(double size) {
    var best = 0;
    for (final (i, s) in widget.snaps.indexed) {
      if ((s - size).abs() < (widget.snaps[best] - size).abs()) best = i;
    }
    return best;
  }

  /// When it is at a snap, that snap is the one it rests at.
  void _settle() {
    if (!_sheet.isAttached) return;
    final i = _nearest(_sheet.size);
    if ((widget.snaps[i] - _sheet.size).abs() > .005 || i == _snap) return;
    setState(() => _snap = i);
    widget.controller?._rest(i);
    widget.onSnap?.call(i);
  }

  Future<void> _snapTo(int index) async {
    if (!_sheet.isAttached) return;
    final t = AshlarTheme.of(context);
    await _sheet.animateTo(
      widget.snaps[index.clamp(0, widget.snaps.length - 1)],
      duration: t.duration * 2,
      curve: Curves.easeOutCubic,
    );
  }

  /// The handle's tap: up a snap, or from the top back to the bottom.
  void _step() => _snapTo(_snap < widget.snaps.length - 1 ? _snap + 1 : 0);

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final radius = Radius.circular(t.radiusLg);
    final top = _snap == widget.snaps.length - 1;
    return LayoutBuilder(
      builder: (context, box) => DraggableScrollableSheet(
        controller: _sheet,
        initialChildSize: widget.snaps[widget.initialSnap],
        minChildSize: widget.snaps.first,
        maxChildSize: widget.snaps.last,
        snap: true,
        snapSizes: widget.snaps,
        builder: (context, scroll) => Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.maxWidth),
            child: Container(
              decoration: BoxDecoration(
                color: c.background,
                borderRadius: BorderRadius.vertical(top: radius),
                border: Border.all(color: c.border),
                boxShadow: t.shadowLg,
              ),
              child: Semantics(
                container: true,
                label: widget.label,
                explicitChildNodes: true,
                child: DefaultTextStyle(
                  style: t.text.sm.copyWith(color: c.foreground),
                  child: Column(
                    children: [
                      // The handle: dragged, it moves the sheet; pressed, it moves it a snap.
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragUpdate: (d) => _sheet.jumpTo(
                          (_sheet.size - d.delta.dy / box.maxHeight).clamp(
                            widget.snaps.first,
                            widget.snaps.last,
                          ),
                        ),
                        onVerticalDragEnd: (d) {
                          final v = d.primaryVelocity ?? 0;
                          // A flick goes a snap that way; otherwise the nearest snap.
                          final i = v < -500
                              ? (_nearest(_sheet.size) + 1)
                              : v > 500
                              ? _nearest(_sheet.size) - 1
                              : _nearest(_sheet.size);
                          _snapTo(i.clamp(0, widget.snaps.length - 1));
                        },
                        child: Semantics(
                          onIncrease: top ? null : () => _snapTo(_snap + 1),
                          onDecrease: _snap == 0
                              ? null
                              : () => _snapTo(_snap - 1),
                          child: Pressable(
                            onPressed: _step,
                            semanticLabel: top
                                ? 'Lower ${widget.label}'
                                : 'Raise ${widget.label}',
                            builder: (context, state) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Container(
                                  width: 100,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: state.pressed || state.focused
                                        ? c.mutedForeground
                                        : c.muted,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SafeArea(
                          top: false,
                          child: widget.builder(context, scroll),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
