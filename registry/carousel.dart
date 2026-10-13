// Ashlar UI: Carousel. Copied into your app by `ashlar add carousel`; it is yours to change.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'button.dart';

/// Slides in a row, one or several in view, moved by swiping, by the buttons either
/// side, or by the arrow keys while it has focus. A screen reader hears which slide is
/// showing.
///
/// ```dart
/// Carousel(viewportFraction: 1 / 3, children: [for (final p in products) ProductCard(p)])
/// ```
class Carousel extends StatefulWidget {
  const Carousel({
    super.key,
    required this.children,
    this.viewportFraction = 1,
    this.spacing = 16,
    this.controls = true,
    this.onChanged,
    this.semanticLabel = 'Carousel',
  });

  final List<Widget> children;

  /// How much of the width one slide takes: 1 shows one, 1 / 3 shows three.
  final double viewportFraction;

  /// The gap between slides.
  final double spacing;

  /// Previous and Next buttons outside the slides, left and right.
  final bool controls;
  final ValueChanged<int>? onChanged;
  final String semanticLabel;

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late final _pages = PageController(viewportFraction: widget.viewportFraction);
  int _at = 0;

  /// The last slide that can lead: with several in view, the end comes sooner.
  int get _last =>
      (widget.children.length - (1 / widget.viewportFraction).floor()).clamp(
        0,
        widget.children.length - 1,
      );

  void _go(int i) => _pages.animateToPage(
    i.clamp(0, _last),
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
  );

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = Semantics(
      container: true,
      label: widget.semanticLabel,
      value: 'Slide ${_at + 1} of ${widget.children.length}',
      // The keys go to what has focus and up from it, so the bindings sit outside the Focus.
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              _go(_at + 1),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              _go(_at - 1),
        },
        child: Focus(
          child: PageView.builder(
            controller: _pages,
            padEnds: false,
            itemCount: widget.children.length,
            onPageChanged: (i) {
              setState(() => _at = i);
              widget.onChanged?.call(i);
            },
            itemBuilder: (context, i) => Padding(
              padding: EdgeInsets.only(right: widget.spacing),
              child: Semantics(
                label: 'Slide ${i + 1} of ${widget.children.length}',
                container: true,
                child: widget.children[i],
              ),
            ),
          ),
        ),
      ),
    );
    if (!widget.controls) return track;
    Widget arrow(IconData icon, String label, VoidCallback? onPressed) =>
        Button(
          variant: ButtonVariant.outline,
          size: ButtonSize.icon,
          semanticLabel: label,
          onPressed: onPressed,
          child: AshlarIcon(icon),
        );
    return Row(
      children: [
        arrow(
          AshlarIconsRoundedStroke.arrowLeft,
          'Previous slide',
          _at > 0 ? () => _go(_at - 1) : null,
        ),
        const SizedBox(width: 12),
        Expanded(child: track),
        const SizedBox(width: 12),
        arrow(
          AshlarIconsRoundedStroke.arrowRight,
          'Next slide',
          _at < _last ? () => _go(_at + 1) : null,
        ),
      ],
    );
  }
}
