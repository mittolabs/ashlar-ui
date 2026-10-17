## 0.1.4

- `AshlarApp.router` takes a `RouterConfig`, for go_router and other routers, with the same
  theme, text and icon defaults around every page as `AshlarApp`.
- `ashlar init` now copies the app shell's test with it; `--no-tests` leaves it out.

## 0.1.3

- `ashlar init --blocks` and `--tests` set where blocks and tests go, as `--path` does for
  components. A folder outside the project is refused.

## 0.1.2

- Toggle keeps its height: given room, it stretched to fill it since 0.1.0. A framed Empty
  and a MessageGroup are as tall as what they hold.

## 0.1.1

- An example of using the command, and doc comments on what the package exports.

## 0.1.0

The first release of the `ashlar` command for Ashlar UI: Flutter components built on the
widgets layer alone, copied into your app as source you own.

- 65 components and 27 blocks (whole screens), each with the tests that check what it
  promises, written to `test/ashlar` with it.
- `ashlar init` and `ashlar apply`: seven bases, seventeen accents and six styles, and your
  own prefix on every name (`--prefix SL` for `SLButton`, `SLTheme`, `showSLToast`).
- `ashlar add`, `view`, `search`, `list`: the components and what they need.
- `ashlar diff` and `ashlar update`: newer versions merged with your changes, compared as
  your own formatter lays out code; `--preview` draws what an update would change, in your
  theme, before and after.
- `ashlar check`: your theme's contrast measured, and in your code icon-only buttons
  without a label, left and right where start and end belong, and touch targets turned off.
- `ashlar book`: a catalog of your components, in your theme, to run as an app.
- `ashlar mcp`: the commands for coding agents, over the Model Context Protocol.
- `ashlar build`: a registry of your own.
- Settings in `ashlar.yaml`; what ashlar wrote, in `.ashlar`.
