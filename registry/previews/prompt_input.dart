// The prompt input picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/attachment.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/prompt_input.dart';

class PromptInputDemo extends StatelessWidget {
  const PromptInputDemo({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 560,
    child: PromptInput(
      onSubmit: (_) {},
      placeholder: 'Ask about orders and deliveries',
      attachments: const [
        Attachment(
          title: 'westlands-week-43.csv',
          description: '38 rows',
          icon: AshlarIconsRoundedStroke.fileText,
        ),
      ],
      actions: [
        Button(
          variant: ButtonVariant.ghost,
          size: ButtonSize.icon,
          semanticLabel: 'Attach a file',
          onPressed: () {},
          child: const AshlarIcon(AshlarIconsRoundedStroke.paperclip),
        ),
        Button(
          variant: ButtonVariant.ghost,
          size: ButtonSize.sm,
          onPressed: () {},
          leading: const AshlarIcon(AshlarIconsRoundedStroke.globe),
          child: const Text('Search'),
        ),
      ],
    ),
  );
}
