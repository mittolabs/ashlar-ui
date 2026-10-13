// The progress picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/progress.dart';

class ProgressDemo extends StatelessWidget {
  const ProgressDemo({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 320,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Progress(value: .66, semanticLabel: 'Upload'),
        SizedBox(height: 24),
        Progress(semanticLabel: 'Loading'),
      ],
    ),
  );
}
