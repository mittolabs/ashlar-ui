// The navigation-menu picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/navigation_menu.dart';

class NavigationMenuDemo extends StatelessWidget {
  const NavigationMenuDemo({super.key});

  @override
  Widget build(BuildContext context) => NavigationMenu(
    items: [
      NavigationMenuItem(
        'Getting started',
        content: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NavigationMenuLink(
              title: 'Introduction',
              description: 'What Ashlar UI is and how it works.',
              onPressed: () {},
            ),
            NavigationMenuLink(
              title: 'Installation',
              description: 'Set up an app and add components.',
              onPressed: () {},
            ),
            NavigationMenuLink(
              title: 'Theming',
              description: 'Colours, corners and type, light and dark.',
              onPressed: () {},
            ),
          ],
        ),
      ),
      NavigationMenuItem(
        'Components',
        content: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NavigationMenuLink(title: 'Button', description: 'Six variants and four sizes.', onPressed: () {}),
            NavigationMenuLink(title: 'Dialog', description: 'A panel over a dimmed page.', onPressed: () {}),
          ],
        ),
      ),
      NavigationMenuItem.link('Docs', onPressed: () {}),
    ],
  );
}
