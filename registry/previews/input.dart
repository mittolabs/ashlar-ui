// The input picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/input.dart';

class InputDemo extends StatelessWidget {
  const InputDemo({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 320,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Input(
          placeholder: 'Email',
          keyboardType: TextInputType.emailAddress,
          leading: AshlarIcon(AshlarIconsRoundedStroke.mail),
        ),
        SizedBox(height: 12),
        Input(placeholder: 'Password', obscureText: true, error: true),
        SizedBox(height: 12),
        Input(placeholder: 'Disabled', enabled: false),
      ],
    ),
  );
}
