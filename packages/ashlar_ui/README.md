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
| `ashlar init` | Copies the theme and `AshlarApp`, and writes `app_theme.dart` with your choices: `--base` (neutral, stone, zinc, mauve, olive, mist, taupe), `--accent` (one of seventeen colours), `--style` (standard, compact, rounded, sharp, dense, soft), `--path` (where components go, `lib/ui` unless you say). |
| `ashlar apply` | Chooses the theme again with the same options; `--accent none` takes the accent away. Your components are left as they are. |
| `ashlar add <item>...` | Copies components, and what they need. `--all` adds every component, `--blocks` every block (whole screens, written to `lib/blocks`). A file you already have is kept unless you pass `--overwrite`. |
| `ashlar view <item>...` | Shows what an item is, what it needs and its files, before you add it. |
| `ashlar search [words]` | Finds items by name or description. `ashlar list` lists them all, ticking the ones you have. |
| `ashlar diff [item...]` | For each item you have: whether your copy is as it was written, changed by you, or older than this version. Name items to see the lines. |
| `ashlar update [item...]` | Takes what is newer in this version and keeps your changes: a file you have not changed is replaced; one you have is merged, line by line, from the copy ashlar wrote. Where you and this version changed the same lines, both are kept between `<<<<<<< yours` and `>>>>>>> ashlar` for you to choose. `--dry-run` says what it would do. |
| `ashlar build [registry.json]` | Makes the files of a registry of your own, in `public/r` unless `--out` says otherwise. |

## Keeping your changes through updates

Each file ashlar writes is also copied to `.ashlar/base/`, so `ashlar update` knows what you
started from. Commit that folder with your code, so your whole team can update.

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
`ashlar.json`:

```json
{ "registries": { "@acme": "https://acme.dev/r" } }
```

Then `ashlar add @acme/brand-card`, `ashlar view @acme/brand-card` and
`ashlar search @acme` work as they do for Ashlar's items. An item can need Ashlar's
components by name and its own registry's items by name. A file that would land outside
the components or blocks folder is refused.

## Licence

MIT.
