// Ashlar UI: Drawer. Copied into your app by `ashlar add drawer`; it is yours to change.

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Brings a panel up from the bottom of the screen, the way phones show choices and
/// short forms. Drag it down, tap outside or press Escape to close it.
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
        child: Builder(builder: builder),
      ),
      transitionBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    ),
  );
}

/// The panel [showDrawer] brings up: a handle to drag, a header, [content] and a [footer].
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

  /// On a wide screen the content is kept to this width, centred.
  final double maxWidth;

  @override
  State<Drawer> createState() => _DrawerState();
}

class _DrawerState extends State<Drawer> {
  /// How far it has been dragged down.
  double _drag = 0;
  double _height = 1;

  void _end(DragEndDetails d) {
    // Down far enough, or flicked down: close. Otherwise it springs back.
    if (_drag > _height * .3 || (d.primaryVelocity ?? 0) > 700) {
      Navigator.maybePop(context);
    } else {
      setState(() => _drag = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final radius = Radius.circular(t.radiusLg);
    return Align(
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onVerticalDragUpdate: (d) => setState(
          () => _drag = (_drag + d.delta.dy).clamp(0, double.infinity),
        ),
        onVerticalDragEnd: _end,
        child: AnimatedContainer(
          duration: _drag == 0 ? t.duration : Duration.zero,
          transform: Matrix4.translationValues(0, _drag, 0),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .8,
          ),
          decoration: BoxDecoration(
            color: c.background,
            borderRadius: BorderRadius.vertical(top: radius),
            border: Border(top: BorderSide(color: c.border)),
            boxShadow: t.shadowLg,
          ),
          child: LayoutBuilder(
            builder: (context, box) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final size = context.size;
                if (size != null) _height = size.height;
              });
              return SafeArea(
                top: false,
                child: Semantics(
                  scopesRoute: true,
                  namesRoute: true,
                  explicitChildNodes: true,
                  child: DefaultTextStyle(
                    style: t.text.sm.copyWith(color: c.foreground),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // The handle: a reminder it can be dragged, not a control.
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          width: 100,
                          height: 8,
                          decoration: BoxDecoration(
                            color: c.muted,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Flexible(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: widget.maxWidth,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      if (widget.title != null)
                                        Semantics(
                                          header: true,
                                          child: DefaultTextStyle.merge(
                                            style: t.text.base.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                            child: widget.title!,
                                          ),
                                        ),
                                      if (widget.description != null) ...[
                                        const SizedBox(height: 6),
                                        DefaultTextStyle.merge(
                                          style: TextStyle(
                                            color: c.mutedForeground,
                                          ),
                                          textAlign: TextAlign.center,
                                          child: widget.description!,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (widget.content != null)
                                  Flexible(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: widget.content,
                                    ),
                                  ),
                                if (widget.footer.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        for (final (i, f)
                                            in widget.footer.indexed) ...[
                                          if (i > 0) const SizedBox(height: 8),
                                          f,
                                        ],
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
