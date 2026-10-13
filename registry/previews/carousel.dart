// The carousel picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/carousel.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class CarouselDemo extends StatelessWidget {
  const CarouselDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return SizedBox(
      width: 520,
      height: 180,
      child: Carousel(
        viewportFraction: 1 / 3,
        spacing: 12,
        children: [
          for (var i = 1; i <= 6; i++)
            Card(
              children: [
                SizedBox(
                  height: 128,
                  child: Center(child: Text('$i', style: t.text.xxl.copyWith(fontSize: 36))),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
