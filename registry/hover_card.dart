// Ashlar UI: Hover Card. Copied into your app by `ashlar add hover-card`; it is yours to
// change.

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'popover.dart';
import 'theme.dart';

/// A card that appears when the pointer rests on [child] or the keyboard focuses it: a
/// preview of a profile or a link. It is extra: anything a person needs should be
/// reachable without it, since touch screens have no hover.
///
/// ```dart
/// HoverCard(
///   content: (context) => Text('Wanjiru Mwangi. Designer at Mittolabs.'),
///   child: Button(variant: ButtonVariant.link, onPressed: openProfile, child: Text('@wanjiru')),
/// )
/// ```
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.child,
    required this.content,
    this.openDelay = const Duration(milliseconds: 700),
    this.closeDelay = const Duration(milliseconds: 300),
    this.side = PopoverSide.bottom,
    this.align = PopoverAlign.center,
    this.width = 256,
  });

  final Widget child;
  final WidgetBuilder content;
  final Duration openDelay, closeDelay;
  final PopoverSide side;
  final PopoverAlign align;
  final double width;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  final _menu = MenuController();
  Timer? _timer;

  void _later(Duration delay, VoidCallback then) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      if (mounted) then();
    });
  }

  void _show() => _later(widget.openDelay, _menu.open);
  void _hide() => _later(widget.closeDelay, _menu.close);
  void _stay() => _timer?.cancel();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return RawMenuAnchor(
      controller: _menu,
      overlayBuilder: (context, info) => PopoverPanel(
        info: info,
        side: widget.side,
        align: widget.align,
        width: widget.width,
        child: MouseRegion(
          onEnter: (_) => _stay(),
          onExit: (_) => _hide(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DefaultTextStyle.merge(
              style: t.text.sm,
              child: Builder(builder: widget.content),
            ),
          ),
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => _show(),
        onExit: (_) => _hide(),
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onFocusChange: (focused) {
            if (!focused) {
              _hide();
            } else if (FocusManager.instance.highlightMode ==
                FocusHighlightMode.traditional) {
              _show();
            }
          },
          child: widget.child,
        ),
      ),
    );
  }
}
