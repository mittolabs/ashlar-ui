// The scroll-area picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/scroll_area.dart';
import 'package:ashlar_ui_gallery/ui/separator.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class ScrollAreaDemo extends StatelessWidget {
  const ScrollAreaDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    BoxDecoration frame() => BoxDecoration(
      border: Border.all(color: t.colors.border),
      borderRadius: BorderRadius.circular(t.radiusMd),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Short content: a child, built at once.
        Container(
          width: 200,
          height: 280,
          decoration: frame(),
          child: ScrollArea(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Sellers arrive with bales from the port before sunrise, sorting by what will '
              'sell first. By noon the best pieces are gone, and the afternoon is for '
              'bargains. Regulars know which stalls open early, which take mobile money, and '
              'which will hold a piece until evening. Newcomers learn by losing a good coat '
              'to someone who came an hour sooner.',
              style: t.text.sm.copyWith(height: 22 / 14),
            ),
          ),
        ),
        const SizedBox(width: 24),
        // A long list: built a row at a time as it scrolls into view.
        Container(
          width: 200,
          height: 280,
          decoration: frame(),
          child: ScrollArea.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: 1000,
            itemExtent: 37,
            itemBuilder: (context, i) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text('Order #${4000 + i}'),
                const Spacer(),
                const Separator(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
