// The textarea picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/textarea.dart';

class TextareaDemo extends StatelessWidget {
  const TextareaDemo({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 360,
    child: Textarea(placeholder: 'Tell us what happened'),
  );
}
