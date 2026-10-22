# ashlar_ui

The `ashlar` command for [Ashlar UI](https://ui.ashlar.ke): components for Flutter built
on the widgets layer alone, copied into your app as source files you own and change.

The command works offline: each version carries its components, so a version of the
command is a version of the components.

## Install

```sh
dart pub global activate ashlar_ui
```

Run it in the root of a Flutter project.

## Commands

| Command | What it does |
|---|---|
| `ashlar init` | Copies the theme and `AshlarApp`, and writes `app_theme.dart` with your choices: `--base` (neutral, stone, zinc, mauve, olive, mist, taupe), `--accent` (one of seventeen colours), `--style` (standard, compact, rounded, sharp, dense, soft), `--path` (where components go, `lib/ui` unless you say), `--blocks` (where blocks go, a `blocks` folder beside the components unless you say) and `--tests` (where their tests go, `test/ashlar` unless you say). `--prefix SL` puts your own prefix on every name: `SLButton`, `SLTheme`. `--preset` takes a theme made on [ui.ashlar.ke/themes](https://ui.ashlar.ke/themes): its base, accent and style, and the colours, corners and spacing changed on them. |
| `ashlar apply` | Chooses the theme again with the same options, `--preset` among them; `--accent none` takes the accent away, `--preset none` a preset's changes. Your components are left as they are. `--prefix` renames everything to a new prefix, your own code included; `--prefix none` takes it away. |
| `ashlar add <item>...` | Copies components, and what they need. `--all` adds every component, `--blocks` every block (whole screens, written to `lib/blocks`). A file you already have is kept unless you pass `--overwrite`. Each comes with its tests, in `test/ashlar`; `--no-tests` leaves them out. |
| `ashlar view <item>...` | Shows what an item is, what it needs and its files, before you add it. |
| `ashlar search [words]` | Finds items by name or description. `ashlar list` lists them all, ticking the ones you have. |
| `ashlar diff [item...]` | For each item you have: whether your copy is as it was written, changed by you, or older than this version. Name items to see the lines. |
| `ashlar update [item...]` | Takes what is newer in this version and keeps your changes: a file you have not changed is replaced; one you have is merged, line by line, from the copy ashlar wrote. Where you and this version changed the same lines, both are kept between `<<<<<<< yours` and `>>>>>>> ashlar` for you to choose. `--dry-run` says what it would do. `--preview` draws each component the update would change, in your theme, as it is and as it would be, side by side on a page in `.ashlar/review`, changing nothing. |
| `ashlar check` | Reports what can be proved about your app's accessibility: your theme's contrast, measured, and in your source icon-only buttons without a label, left and right where start and end belong, and touch targets turned off. Exits 1 when it finds something, for CI. `--no-contrast` skips the measuring. |
| `ashlar book` | Writes a catalog of the components you have, in your theme, to `.ashlar/book`: an app of its own with a page for each, and switches for dark, text at 200% and right to left. `flutter run -t .ashlar/book/main.dart` runs it on any device. |
| `ashlar mcp` | These commands for a coding agent, over the Model Context Protocol on standard input and output. |
| `ashlar build [registry.json]` | Makes the files of a registry of your own, in `public/r` unless `--out` says otherwise. |

## Your own prefix

A design system marks its parts as its own: `SLButton` at one company, `MzButton` at
another. `ashlar init --prefix SL` does that for every name the components declare:
`Button` becomes `SLButton`, `AshlarTheme` becomes `SLTheme`, `showToast` becomes
`showSLToast`. Names then never clash with Material's `Card`, `Checkbox` or `Dialog` in
a file that imports both. Text and prose are left alone; code, `[names]` in doc comments
and their examples are renamed. The blocks, whole screens of your app, keep their own names.

`ashlar apply --prefix Mz` renames everything to a new prefix: the components, ashlar's
copies of them, and every use in your own code under `lib` and `test`, so the app still
builds. `ashlar update` and `ashlar diff` work as before.

## Tests that come with each component

A component comes with the tests that check what it promises: that a screen reader can
reach Swipe Actions without swiping, that a dialog rises above the keyboard, that a select
list is as wide as its trigger. They are written to `test/ashlar`, importing the
component from your package, and `flutter test` runs them with your own.

The files are yours, so change a component and its tests tell you which promise your
change broke; change the tests when you meant to break it. Tests that use another
component (most use a Button as a trigger) are written once you have that one too.
A test you delete stays deleted. `ashlar update` merges tests as it merges components.
`tests: false` in `ashlar.yaml` leaves them out, and `ashlar init --tests test/ui`
(or `tests: test/ui`) puts them elsewhere. Components outside `lib` get no tests, since a test cannot import them.

## Checking your app

`ashlar check` reports only what it can prove, each with where it is and what to do:

- **Contrast**, measured: it builds `appTheme` and `appDarkTheme` from your
  `app_theme.dart` in a flutter test and measures each pair the components draw, text
  against WCAG 1.4.3 (4.5:1), the focus ring and field borders against 1.4.11 (3:1).
- **Labels**: a Button or Toggle holding only an icon, with no `semanticLabel`.
- **Right to left**: `EdgeInsets.only(left:)`, `Alignment.centerRight`, `TextAlign.left`
  and the like, where the directional form follows the reading direction. Values that
  follow a physical side or the text direction are not reported.
- **Touch targets**: `tapTarget: 0`, which turns off the room for a finger.

It says what it did not check, as source cannot show it: the size of your own tap areas
and labels on your own controls. A widget test with `meetsGuideline` checks a screen for
those. A line that means it can say `// ashlar: ignore`; a file, `// ashlar: ignore-file`
with its reason.

The field borders Ashlar and shadcn draw are 1.2 to 1.5:1, a choice of look that
`ashlar check` reports.

## For coding agents

`ashlar mcp` serves the commands to a coding agent over MCP: `search_components`,
`view_component` (the source, whose doc comments are the API), `add_components`,
`update_components` and `check_app`. Each runs the command a person would, in the folder
the agent starts it in. In Claude Code:

```sh
claude mcp add ashlar -- ashlar mcp
```

Other agents take the same command in their MCP settings:

```json
{ "mcpServers": { "ashlar": { "command": "ashlar", "args": ["mcp"] } } }
```

## Your choices, and what ashlar wrote

`ashlar.yaml` holds your choices: where components go, the theme, your registries, whether
tests come along. `ashlar init` and `ashlar apply` change it and keep your comments; you can
edit it too.

```yaml
path: lib/ui
base: stone
accent: teal
style: standard
```

## Keeping your changes through updates

Each file ashlar writes is also copied to `.ashlar/base/`, with its fingerprint in
`.ashlar/files.json`, so `ashlar update` knows what you started from. Commit that folder
with your code, so your whole team can update. Both are compared as your own formatter lays
out code, so a different line length is never taken for a change of yours.

## Registries of your own

Describe your items in a `registry.json`, the way Ashlar's own is written:

```json
{
  "brand-card": {
    "description": "A card with our mark.",
    "files": ["brand_card.dart"],
    "requires": ["card", "brand"]
  }
}
```

`ashlar build` writes `registry.json` (the list) and `brand-card.json` (the item and its
files) to host anywhere, or to keep in a folder. Name the registry in a project's
`ashlar.yaml`:

```yaml
registries:
  "@acme": https://acme.dev/r
```

Then `ashlar add @acme/brand-card`, `ashlar view @acme/brand-card` and
`ashlar search @acme` work as they do for Ashlar's items. An item can need Ashlar's
components by name and its own registry's items by name. A file that would land outside
the components or blocks folder is refused.

## Licence

MIT.
