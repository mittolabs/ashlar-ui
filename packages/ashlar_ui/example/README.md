# Using the ashlar command

Install it, then run it in the root of a Flutter app:

```sh
dart pub global activate ashlar_ui

ashlar init --base stone --accent teal   # the theme, AshlarApp and ashlar.yaml
ashlar add button dialog                # components, with what they need and their tests
```

Give `AshlarApp` the theme `ashlar init` wrote, then use a component as any widget:

```dart
import 'package:flutter/widgets.dart';

import 'ui/app.dart';
import 'ui/app_theme.dart';
import 'ui/button.dart';

void main() => runApp(
  AshlarApp(
    theme: appTheme,
    darkTheme: appDarkTheme,
    home: Center(child: Button(onPressed: () {}, child: const Text('Save'))),
  ),
);
```

Later:

```sh
ashlar update --preview   # what a newer version would change, drawn before and after
ashlar update             # take it, keeping your changes
ashlar check              # contrast, labels, right to left and touch targets
ashlar book               # a catalog of your components, to run as an app
```

Every component and its options: https://ui.ashlar.ke
