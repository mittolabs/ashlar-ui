// The message picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/avatar.dart';
import 'package:ashlar_ui_gallery/ui/bubble.dart';
import 'package:ashlar_ui_gallery/ui/message.dart';

class MessageDemo extends StatelessWidget {
  const MessageDemo({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 440,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Message(
          avatar: Avatar(fallback: 'AO'),
          header: Text('Achieng'),
          child: BubbleGroup(
            children: [
              Bubble(
                variant: BubbleVariant.muted,
                child: Text('The field figures came in this morning.'),
              ),
              Bubble(
                variant: BubbleVariant.muted,
                child: Text('Can we move the review to ten?'),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        Message(
          align: MessageAlign.end,
          footer: Text('Read 09:41'),
          child: Bubble(child: Text('Ten works. I will bring the slides.')),
        ),
      ],
    ),
  );
}
