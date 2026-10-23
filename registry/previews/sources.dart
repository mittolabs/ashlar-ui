// The sources picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/sources.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class SourcesDemo extends StatelessWidget {
  const SourcesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return SizedBox(
      width: 520,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              style: t.text.sm.copyWith(color: t.colors.foreground),
              children: [
                const TextSpan(text: 'Returns are taken within 14 days of delivery'),
                WidgetSpan(alignment: PlaceholderAlignment.middle, child: Citation(1, title: 'Returns policy', onPressed: () {})),
                const TextSpan(text: ', and order 1042 was delivered on 12 October'),
                WidgetSpan(alignment: PlaceholderAlignment.middle, child: Citation(2, title: 'Order 1042', onPressed: () {})),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Sources(
            initiallyOpen: true,
            onOpen: (_) {},
            sources: const [
              Source(title: 'Returns policy', url: 'https://www.shop.example.com/returns'),
              Source(title: 'Order 1042', detail: 'Orders, 12 October'),
            ],
          ),
        ],
      ),
    );
  }
}
