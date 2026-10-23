// The input-group picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/input.dart';
import 'package:ashlar_ui_gallery/ui/input_group.dart';
import 'package:ashlar_ui_gallery/ui/textarea.dart';

class InputGroupDemo extends StatelessWidget {
  const InputGroupDemo({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 380,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const InputGroup(
          start: Text('https://'),
          end: Text('.com'),
          child: Input(decorated: false, placeholder: 'yourshop'),
        ),
        const SizedBox(height: 16),
        InputGroup(
          start: const AshlarIcon(AshlarIconsRoundedStroke.search),
          end: Button(variant: ButtonVariant.ghost, size: ButtonSize.sm, onPressed: () {}, child: const Text('Search')),
          child: const Input(decorated: false, placeholder: 'Search orders'),
        ),
        const SizedBox(height: 16),
        InputGroup(
          bottom: Row(
            children: [
              const Text('280 characters left'),
              const Spacer(),
              Button(size: ButtonSize.sm, onPressed: () {}, child: const Text('Send')),
            ],
          ),
          child: const Textarea(decorated: false, placeholder: 'Write a reply', minLines: 2),
        ),
      ],
    ),
  );
}
