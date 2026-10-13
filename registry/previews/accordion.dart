// The accordion picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/accordion.dart';

class AccordionDemo extends StatelessWidget {
  const AccordionDemo({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 420,
    child: Accordion(
      initiallyOpen: {0},
      items: [
        AccordionItem(
          title: Text('Can I change the components?'),
          content: Text('Yes. Each one is a file in your app, so you can change anything in it.'),
        ),
        AccordionItem(
          title: Text('Does it use Material?'),
          content: Text('No. Only Flutter\'s widgets layer, so nothing of Material comes along.'),
        ),
        AccordionItem(
          title: Text('Does it work with a keyboard?'),
          content: Text('Yes. Tab to a heading, then Enter or Space to open it.'),
        ),
      ],
    ),
  );
}
