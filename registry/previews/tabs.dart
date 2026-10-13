// The tabs picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/card.dart';
import 'package:ashlar_ui_gallery/ui/field.dart';
import 'package:ashlar_ui_gallery/ui/input.dart';
import 'package:ashlar_ui_gallery/ui/tabs.dart';

class TabsDemo extends StatelessWidget {
  const TabsDemo({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 380,
    child: Tabs(
      expand: true,
      tabs: [
        TabItem(
          label: const Text('Account'),
          content: _form(
            'Account',
            'Change your name here.',
            const Field(
              label: Text('Name'),
              child: Input(placeholder: 'Wanjiru Mwangi'),
            ),
          ),
        ),
        TabItem(
          label: const Text('Password'),
          content: _form(
            'Password',
            'Change your password here.',
            const Field(label: Text('New password'), child: Input(obscureText: true)),
          ),
        ),
      ],
    ),
  );

  Widget _form(String title, String description, Widget field) => Card(
    children: [
      CardHeader(title: Text(title), description: Text(description)),
      CardContent(child: field),
      CardFooter(
        children: [Button(onPressed: () {}, child: const Text('Save'))],
      ),
    ],
  );
}
