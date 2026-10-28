<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/mark-dark.svg" />
    <img src="assets/mark.svg" alt="Ashlar UI" width="96" />
  </picture>
</p>

<h2 align="center">The building blocks of your design system.</h2>

<p align="center">
  Flutter components that land in your app as plain source you own.<br/>
  Change anything. When a component gets better, the update keeps your changes.
</p>

<br/>

<p align="center">
  <a href="https://pub.dev/packages/ashlar_ui">
    <img src="https://img.shields.io/pub/v/ashlar_ui?color=0a0a0a&label=ashlar_ui" alt="ashlar_ui on pub.dev" />
  </a>
  <a href="https://pub.dev/packages/ashlar_ui/score">
    <img src="https://img.shields.io/pub/points/ashlar_ui?color=0a0a0a" alt="pub points" />
  </a>
  <a href="https://github.com/mittolabs/ashlar-ui/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-0a0a0a" alt="MIT licence" />
  </a>
  <img src="https://img.shields.io/badge/Flutter-widgets_layer-0a0a0a?logo=flutter&logoColor=white" alt="Flutter, widgets layer" />
  <a href="https://ui.ashlar.ke">
    <img src="https://img.shields.io/badge/docs-ui.ashlar.ke-0a0a0a" alt="Docs" />
  </a>
  <a href="https://github.com/mittolabs/ashlar-ui/stargazers">
    <img src="https://img.shields.io/github/stars/mittolabs/ashlar-ui?style=flat&color=0a0a0a" alt="Stars" />
  </a>
</p>

<br/>

<p align="center">
  <a href="https://ui.ashlar.ke">
    <img src="assets/hero.png" alt="ui.ashlar.ke: the building blocks of your design system, beside three apps built with Ashlar UI" width="100%" />
  </a>
</p>

---

## Get started

Install the `ashlar` command once:

```sh
dart pub global activate ashlar
```

Then, in your Flutter app:

```sh
ashlar init                  # your theme and AshlarApp, in lib/ui
ashlar add button dialog     # components, and whatever they need
ashlar list                  # everything there is, and what you have
```

Use them like any widget, because that's all they are:

```dart
import 'ui/app.dart';
import 'ui/button.dart';

void main() => runApp(AshlarApp(home: Home()));

Button(onPressed: save, child: Text('Save'))
```

The files are yours from the moment they land. `ashlar` never overwrites one you
already have unless you pass `--overwrite`, and `ashlar update` brings in what got
better while keeping what you changed.

---

## Why it feels different

| | |
|---|---|
| **It's your code** | Components are copied into `lib/ui` as plain Dart. Read them, change them, rename them with your own prefix (`ashlar init --prefix SL`). |
| **Updates keep your changes** | `ashlar diff` shows what changed on both sides; `ashlar update` merges, and `--preview` draws the before and after first. |
| **Tests come along** | Each component arrives with its tests in `test/ashlar`, so you can change it and check it still keeps its promises. |
| **The widgets layer only** | No Material, no Cupertino. One look on every platform, with keyboard focus and screen reader support from Flutter itself. |
| **One theme** | Seven bases, seventeen accents and six styles, or a theme made on [ui.ashlar.ke/themes](https://ui.ashlar.ke/themes). Every colour, corner and size comes from it. |
| **Built for agents too** | `ashlar init` tells your coding agent how to build with Ashlar UI, `ashlar mcp` hands it the commands, and `ashlar shot` lets it see your screens without running the app. |

---

## What's included

90 components and 23 blocks (whole screens), with [ashlaricons](https://icons.ashlar.ke)
for every icon.

| | |
|---|---|
| **Foundation** | theme, app, pressable, group, selection |
| **Actions** | button, button group, toggle, toggle group, dropdown menu, context menu, menubar, command |
| **Forms** | label, field, input, textarea, select, combobox, input group, input OTP, checkbox, radio, switch, slider, calendar, date picker |
| **Overlays** | dialog, alert dialog, sheet, drawer, popover, hover card, tooltip, toast |
| **Layout** | card, tabs, accordion, collapsible, item, separator, scroll area, resizable, carousel |
| **Data and navigation** | data table, charts, navigation menu, sidebar, pagination, breadcrumb |
| **Feedback** | alert, progress, spinner, skeleton, empty |
| **Display** | typography, badge, avatar, kbd |

See them all, live, at [ui.ashlar.ke](https://ui.ashlar.ke), and the apps people have built
with them in the [showcase](https://ui.ashlar.ke/showcase).

---

## Contributing

Pull requests are welcome. Ashlar UI takes bug fixes, accessibility, tooling, consistency
between components, and components that unrelated apps clearly need. It doesn't take a
look or an option that exists for one app's design: that belongs in your copy.

| Folder | What's in it |
|---|---|
| `registry/` | The components' sources: what `ashlar add` copies. Edit them here. |
| `packages/ashlar_ui` | The `ashlar` command. `dart run tool/bundle.dart` embeds `registry/` into it. |
| `packages/ashlar` | The same command, published as `ashlar`. |
| `gallery/` | Every component in every state, installed with `ashlar add --all`, and their tests. |

Flutter runs through [fvm](https://fvm.app) on the stable channel. Commits follow
[Conventional Commits](https://www.conventionalcommits.org); turn on the hook with
`git config core.hooksPath .githooks`.

```sh
dart run tool/bundle.dart                                # after changing registry/
cd packages/ashlar_ui && fvm dart test                   # the command
cd gallery && fvm flutter test                           # the components
```

---

## Licence

MIT. See [LICENSE](LICENSE). Made by [Mittolabs](https://mittolabs.com).
