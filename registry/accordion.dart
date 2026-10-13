// Ashlar UI: Accordion. Copied into your app by `ashlar add accordion`; it is yours to change.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'collapsible.dart';
import 'pressable.dart';
import 'theme.dart';

/// One section of an [Accordion]: its heading and what opens under it.
@immutable
class AccordionItem {
  const AccordionItem({required this.title, required this.content});

  final Widget title;
  final Widget content;
}

/// Sections stacked one above the other, each opening under its heading. One open at a
/// time, or any number with [multiple]. A screen reader hears each heading as a button
/// that is expanded or collapsed.
///
/// ```dart
/// Accordion(items: [
///   AccordionItem(title: Text('Can I change the components?'), content: Text('Yes. They are files in your app.')),
///   AccordionItem(title: Text('Does it use Material?'), content: Text('No. Only Flutter\'s widgets layer.')),
/// ])
/// ```
class Accordion extends StatefulWidget {
  const Accordion({
    super.key,
    required this.items,
    this.multiple = false,
    this.initiallyOpen = const {},
  });

  final List<AccordionItem> items;
  final bool multiple;

  /// The sections open at first, by index.
  final Set<int> initiallyOpen;

  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  late final Set<int> _open = {...widget.initiallyOpen};

  void _toggle(int i) => setState(() {
    if (_open.contains(i)) {
      _open.remove(i);
    } else {
      if (!widget.multiple) _open.clear();
      _open.add(i);
    }
  });

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, item) in widget.items.indexed)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: i == widget.items.length - 1
                      ? const Color(0x00000000)
                      : c.border,
                ),
              ),
            ),
            child: Collapsible(
              open: _open.contains(i),
              builder: (context, open, _) => Pressable(
                onPressed: () => _toggle(i),
                expanded: open,
                builder: (context, state) => AnimatedContainer(
                  duration: t.duration,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(t.radiusMd),
                    boxShadow: [if (state.focused) ...t.focusRing],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DefaultTextStyle.merge(
                          style: t.text.sm.copyWith(
                            color: c.foreground,
                            fontWeight: FontWeight.w500,
                            decoration: state.hovered
                                ? TextDecoration.underline
                                : null,
                            decorationColor: c.foreground,
                          ),
                          child: item.title,
                        ),
                      ),
                      const SizedBox(width: 16),
                      AnimatedRotation(
                        turns: open ? .5 : 0,
                        duration: t.duration,
                        child: AshlarIcon(
                          AshlarIconsRoundedStroke.chevronDown,
                          size: 16,
                          color: c.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: c.foreground),
                  child: item.content,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
