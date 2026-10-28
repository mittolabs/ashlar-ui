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

## Ashlar UI for Jaspr

Started 2026-10-28 in `registry_jaspr/`, ported as products need it (the owner's call: not
the whole of Ashlar first). Patchlad's console is the first app on it. In a Jaspr project
the `ashlar` command runs `lib/src/jaspr.dart`: `init`, `add`, `view`, `search` and
`list`; the rest is Flutter-only so far, and says so.

- **The same look.** Colours, corners and sizes are the Flutter theme's, as CSS variables
  (`--ash-*`) in `theme.dart`; a component uses only those, never a literal colour.
- **Real HTML.** A button is a `<button>`, a table a `<table>`, the alert dialog the
  browser's modal `<dialog>`: focus, keys and screen readers come from the browser.
- **`package:universal_web`, never `package:web`.** Jaspr runs an app's libraries on the
  Dart VM to collect `@css` styles, and `package:web` does not compile there.
- **`@css` styles on public classes.** On a private `State` class the analyzer calls them
  unused; put them on the component.
- **A modal `<dialog>` renders its `open` attribute from its own state.** Jaspr removes an
  attribute it did not render, and a modal dialog that loses `open` that way stays modal
  with the page behind it dead.
- No tests or site pages yet: each component is checked in the app that needs it.

## What Ashlar UI takes

Ashlar UI is copied into an app, and the app owns what it copies. So the look of one app
belongs in that app, not in Ashlar. Ashlar is not shaped by any one design, however good,
or by the app being built with it this week (decided 2026-10-25, after 0.4.0 to 0.6.0 took
options for single designs; see "Deprecated" below).

Ashlar takes a change only when it is one of these:

1. **A bug**, or behaviour Ashlar owns and gets wrong: where an overlay opens, focus, what
   a screen reader hears, keys, a layout that breaks.
2. **Accessibility**: a control a screen reader cannot reach, a target too small, text that
   is cut off when it grows.
3. **Tooling**: the `ashlar` command, `shot`, `update`, `diff`, the MCP server.
4. **Consistency inside Ashlar**: its components agreeing with each other (a field as tall
   as the button of the same size; one set of sizes, one way to name them).
5. **A layout every app on a phone, a tablet or a desktop runs into** (a calendar that can
   fill its width), not one screen's arrangement.
6. **A component that unrelated apps clearly need**, judged by asking what three apps unlike
   the one in front of you would do with it (an appearance picker, yes; a shape from one
   app's screen, no).

It does not take:

- **A look**: a shape, a skin, a size, a spacing, a colour that makes one app match its
  design. The app draws that in widgets of its own, built on Ashlar's parts (`Pressable`,
  the theme and its tokens), or changes its copy. That is what owning the copy is for, and
  it is not a gap in Ashlar.
- **An option that exists for one design.** A boolean that only one app would turn on is a
  look under another name.
- **Anything asked for "so this app does not have to draw it".**

When unsure, it does not go in. A look that many unrelated apps keep drawing can be shown
first as an example on the site (how to change your copy) or a block, and become an option
on a component last, with the same test applied again.

Releases follow the work: a release can carry one change from one app, if that change
passes this test.

### Deprecated

Taken in 0.4.0 to 0.6.0 for single designs, deprecated in 0.7.0, to go in a later
release: `BottomBar.floating` and `named`, `Input.round` and `raised`,
`ButtonSize.icon2xl` and `ToggleVariant.chip`.

The `ticket` component, from the same time, is kept (the owner's call, 2026-10-25): it
stays as it is, and the rule above applies to everything that comes after it.
