// The sheet picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/field.dart';
import 'package:ashlar_ui_gallery/ui/input.dart';
import 'package:ashlar_ui_gallery/ui/sheet.dart';

class SheetDemo extends StatelessWidget {
  const SheetDemo({super.key});

  @override
  Widget build(BuildContext context) => Button(
    variant: ButtonVariant.outline,
    onPressed: () => showSheet(
      context: context,
      builder: (context) => Sheet(
        title: const Text('Edit profile'),
        description: const Text('Changes are saved when you press Save.'),
        content: const Column(
          children: [
            Field(
              label: Text('Name'),
              child: Input(placeholder: 'Wanjiru Mwangi'),
            ),
            SizedBox(height: 16),
            Field(
              label: Text('Username'),
              child: Input(placeholder: '@wanjiru'),
            ),
          ],
        ),
        footer: [
          Button(onPressed: () => Navigator.pop(context), child: const Text('Save')),
          Button(variant: ButtonVariant.outline, onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
    ),
    child: const Text('Edit profile'),
  );
}
