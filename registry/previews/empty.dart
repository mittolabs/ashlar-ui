// The empty picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/empty.dart';

class EmptyDemo extends StatelessWidget {
  const EmptyDemo({super.key});

  @override
  Widget build(BuildContext context) => Empty(
    icon: const AshlarIcon(AshlarIconsRoundedStroke.folder),
    title: const Text('No projects yet'),
    description: const Text('You have not made a project. Make your first one to get started.'),
    actions: [
      Button(onPressed: () {}, child: const Text('Create project')),
      Button(variant: ButtonVariant.outline, onPressed: () {}, child: const Text('Import')),
    ],
  );
}
