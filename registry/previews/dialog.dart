// The dialog picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/dialog.dart';

class DialogDemo extends StatelessWidget {
  const DialogDemo({super.key});

  @override
  Widget build(BuildContext context) => Button(
    variant: ButtonVariant.outline,
    onPressed: () => showAshlarDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        title: const Text('Delete the file?'),
        description: const Text('This cannot be undone. The file and its history will be removed.'),
        actions: [
          Button(
            variant: ButtonVariant.outline,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          Button(
            variant: ButtonVariant.destructive,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ),
    child: const Text('Delete file'),
  );
}
