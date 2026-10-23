// The reasoning picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/reasoning.dart';

class ReasoningDemo extends StatelessWidget {
  const ReasoningDemo({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 520,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Reasoning(
          thinking: true,
          child: Text(
            'Late means past its promised time and not yet delivered. I need this week\'s Downtown orders first.',
          ),
        ),
        SizedBox(height: 16),
        Reasoning(took: Duration(seconds: 12), child: Text('Folded away once it is done.')),
      ],
    ),
  );
}
