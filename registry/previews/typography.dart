// The typography picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/typography.dart';

class TypographyDemo extends StatelessWidget {
  const TypographyDemo({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 520,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        H2('The market at Gikomba'),
        SizedBox(height: 12),
        Lead('Before sunrise the stalls are already up, and the first buyers are haggling.'),
        SizedBox(height: 16),
        P(
          'Sellers arrive with bales from the port, sorting by what will sell first. By noon the best pieces are gone.',
        ),
        SizedBox(height: 16),
        Blockquote('"Come early, or come back tomorrow."'),
      ],
    ),
  );
}
