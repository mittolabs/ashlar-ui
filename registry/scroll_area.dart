// Ashlar UI: Scroll Area. Copied into your app by `ashlar add scroll-area`; it is yours to
// change.

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Scrolls [child] with a thin scrollbar in the theme's colours, shown while the pointer
/// is over it and while it scrolls, in place of the platform's.
///
/// ```dart
/// SizedBox(height: 300, child: ScrollArea(child: Column(children: tags)))
/// ```
class ScrollArea extends StatefulWidget {
  const ScrollArea({
    super.key,
    required this.child,
    this.axis = Axis.vertical,
    this.controller,
    this.padding,
  });

  final Widget child;
  final Axis axis;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;

  @override
  State<ScrollArea> createState() => _ScrollAreaState();
}

class _ScrollAreaState extends State<ScrollArea> {
  ScrollController? _own;
  ScrollController get _controller =>
      widget.controller ?? (_own ??= ScrollController());
  bool _hovered = false;

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AshlarTheme.of(context).colors;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: ScrollConfiguration(
        // The platform's own scrollbar is replaced by the one below.
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: RawScrollbar(
          controller: _controller,
          thumbVisibility: _hovered,
          thumbColor: c.border,
          thickness: 8,
          radius: const Radius.circular(4),
          crossAxisMargin: 1,
          mainAxisMargin: 1,
          interactive: true,
          child: SingleChildScrollView(
            controller: _controller,
            scrollDirection: widget.axis,
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
