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

- **Foundation:** theme, app, pressable, group.
- **Actions:** button, button-group, toggle, toggle-group, dropdown-menu, context-menu, menubar, command.
- **Forms:** label, field, input, textarea, select, combobox, input-group, input-otp, checkbox, radio, switch, slider.
- **Overlays:** dialog, alert-dialog, sheet, drawer, popover, hover-card, tooltip, toast.
- **Layout:** card, tabs, accordion, collapsible, item, separator, scroll-area, resizable, carousel.
- **Data and navigation:** data-table, navigation-menu, pagination, breadcrumb.
- **Feedback:** alert, progress, spinner, skeleton, empty.
- **Display:** typography, badge, avatar, kbd.

Radio works inside Flutter's own `RadioGroup`, and Popover, Dropdown Menu, Select and
Tooltip are built on Flutter's `RawMenuAnchor` and `RawTooltip`. The keyboard handling
and screen reader support come from Flutter itself.
`ashlar list` shows them with what each does.

## This repository

| Folder | What |
|---|---|
| `registry/` | The components' sources: what `ashlar add` copies. Edit them here. |
| `packages/ashlar_ui` | The `ashlar` command. `dart run tool/bundle.dart` embeds `registry/` into it. |
| `gallery/` | Every component in every state, installed with `ashlar add --all`, and their tests. |

## Licence

MIT. See `LICENSE`.
