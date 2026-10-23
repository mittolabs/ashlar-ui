# CLAUDE.md

Ashlar UI for Flutter (`decisions/0011` in the Mittolabs workspace docs).

## Rules that are decided

- **The widgets layer only.** Nothing imports Material or Cupertino, in the registry
  or the gallery, and the gallery's pubspec has no `uses-material-design`.
- **Copied, not depended on.** `registry/` holds the sources `ashlar add` writes into
  an app. Components import each other relatively (`import 'theme.dart';`), so they
  work wherever the app keeps them.
- **Edit `registry/`, never `gallery/lib/ui`.** The gallery's copies are written by
  `ashlar add --all --overwrite` after `dart run tool/bundle.dart`, the path a user takes.
- **Every colour, radius and text style comes from the theme.** No literal colours in
  a component except fully transparent.
- **Every control is a `Pressable`:** hover, press, keyboard focus (a ring only for
  keyboard focus), Enter and Space, and a screen reader label.
- **ashlaricons for every icon**, at the version in `packageVersions` (the CLI).
- **The default look is shadcn's neutral theme**, light and dark, checked against
  ui.shadcn.com when it changes.
- **Name no other library in what users read**: the site, the components' descriptions,
  the comments in files `ashlar add` copies, and the changelog. Say what Ashlar UI does on
  its own terms. Internal docs (`docs/`) may compare, and say so. Crediting where data
  came from (the palette) is not a comparison.
- **A global product, built in Kenya.** Sample content in blocks and demos mixes places,
  and names from around the world; Kenya is one place among many, not the default.
  Money is in US dollars unless a block is about currencies. Nothing country-specific in behaviour: phone numbers take a country, IDs and
  tax numbers are checked generically, payments are not tied to one provider.
- Flutter through fvm on stable. Conventional Commits; `git config core.hooksPath .githooks`.
