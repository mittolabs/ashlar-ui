// The popover picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/field.dart';
import 'package:ashlar_ui_gallery/ui/input.dart';
import 'package:ashlar_ui_gallery/ui/popover.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class PopoverDemo extends StatelessWidget {
  const PopoverDemo({super.key});

  @override
  Widget build(BuildContext context) => Popover(
    builder: (context, menu) => Button(
      variant: ButtonVariant.outline,
      onPressed: () => menu.isOpen ? menu.close() : menu.open(),
      child: const Text('Dimensions'),
    ),
    content: (context) {
      final t = AshlarTheme.of(context);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Dimensions', style: t.text.sm.copyWith(fontWeight: FontWeight.w500)),
          Text('Set the size of the layer.', style: TextStyle(color: t.colors.mutedForeground)),
          const SizedBox(height: 16),
          const Field(
            label: Text('Width'),
            child: Input(placeholder: '100%'),
          ),
          const SizedBox(height: 12),
          const Field(
            label: Text('Height'),
            child: Input(placeholder: '25px'),
          ),
        ],
      );
    },
  );
}
