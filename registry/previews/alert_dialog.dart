// The alert-dialog picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/alert_dialog.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';

class AlertDialogDemo extends StatelessWidget {
  const AlertDialogDemo({super.key});

  @override
  Widget build(BuildContext context) => Button(
    variant: ButtonVariant.outline,
    onPressed: () async {
      final delete = await showAlertDialog(
        context,
        title: 'Delete the project?',
        description: 'This cannot be undone. The project and its files will be removed.',
        action: 'Delete',
        destructive: true,
      );
      if (delete) {
        // Delete it.
      }
    },
    child: const Text('Delete project'),
  );
}
