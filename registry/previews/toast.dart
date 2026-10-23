// The toast picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/toast.dart';

class ToastDemo extends StatelessWidget {
  const ToastDemo({super.key});

  @override
  Widget build(BuildContext context) => Button(
    variant: ButtonVariant.outline,
    onPressed: () => showToast(
      context,
      title: 'Payment sent',
      description: '\$240 to Maya Thompson.',
      action: Button(size: ButtonSize.sm, onPressed: () {}, child: const Text('Undo')),
    ),
    child: const Text('Send payment'),
  );
}
