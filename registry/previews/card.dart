// The card picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/badge.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/input.dart';

class CardDemo extends StatelessWidget {
  const CardDemo({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 360,
    child: Card(
      children: [
        const CardHeader(
          title: Text('Send money'),
          description: Text('To a phone number or a bank account.'),
          action: Badge(variant: BadgeVariant.secondary, child: Text('KES')),
        ),
        const CardContent(child: Input(placeholder: 'Phone number')),
        CardFooter(
          alignment: MainAxisAlignment.end,
          children: [
            Button(variant: ButtonVariant.outline, onPressed: () {}, child: const Text('Cancel')),
            Button(onPressed: () {}, child: const Text('Continue')),
          ],
        ),
      ],
    ),
  );
}
