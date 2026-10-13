// The drawer picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/drawer.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class DrawerDemo extends StatelessWidget {
  const DrawerDemo({super.key});

  @override
  Widget build(BuildContext context) => Button(
    variant: ButtonVariant.outline,
    onPressed: () => showDrawer(
      context: context,
      builder: (context) {
        final t = AshlarTheme.of(context);
        return Drawer(
          title: const Text('Daily steps'),
          description: const Text('Set your goal for each day.'),
          content: Center(
            child: Text('8,000', style: t.text.xxl.copyWith(fontSize: 56, height: 1.1)),
          ),
          footer: [
            Button(onPressed: () => Navigator.pop(context), child: const Text('Save goal')),
            Button(
              variant: ButtonVariant.outline,
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    ),
    child: const Text('Set a goal'),
  );
}
