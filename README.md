# Ashlar UI

Components for Flutter built on the widgets layer alone, with no Material or
Cupertino, copied into your app by the `ashlar` command. The code is yours to
change, the way shadcn/ui works on the web. Icons come from
[ashlaricons](https://icons.ashlar.ke).

```sh
dart pub global activate ashlar_ui
cd your_app
ashlar init                  # the theme and AshlarApp, in lib/ui
ashlar add button dialog     # components, with what they need
ashlar list
```

```dart
import 'ui/app.dart';
import 'ui/button.dart';

void main() => runApp(AshlarApp(home: Home()));

Button(onPressed: save, child: Text('Save'))
```

`ashlar` never replaces a file you already have unless you pass `--overwrite`.

## Components

theme, app, button, badge, card, separator, input, checkbox, switch, dialog.
`ashlar list` shows them with what each does.

## This repository

| Folder | What |
|---|---|
| `registry/` | The components' sources: what `ashlar add` copies. Edit them here. |
| `packages/ashlar_ui` | The `ashlar` command. `dart run tool/bundle.dart` embeds `registry/` into it. |
| `gallery/` | Every component in every state, installed with `ashlar add --all`, and their tests. |

## Licence

ISC. See `LICENSE`.
