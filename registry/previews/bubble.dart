// The bubble picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/bubble.dart';
import 'package:ashlar_ui_gallery/ui/message.dart';

class BubbleDemo extends StatelessWidget {
  const BubbleDemo({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 440,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Message(
          child: Bubble(
            variant: BubbleVariant.muted,
            reactions: Text('👍 2'),
            child: Text('The new release is out.'),
          ),
        ),
        const SizedBox(height: 12),
        const Message(
          align: MessageAlign.end,
          child: BubbleGroup(
            children: [
              Bubble(child: Text('Already on my phone.')),
              Bubble(variant: BubbleVariant.tinted, child: Text('Looks sharp.')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Message(
          child: Bubble(
            variant: BubbleVariant.outline,
            onPressed: () {},
            child: const Text('Show me what changed'),
          ),
        ),
        const SizedBox(height: 12),
        const Message(
          align: MessageAlign.end,
          child: Bubble(
            variant: BubbleVariant.destructive,
            child: Text('Not sent. Tap to try again.'),
          ),
        ),
      ],
    ),
  );
}
