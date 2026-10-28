# Contributing

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
dart run tool/bundle.dart                # after changing registry/
cd packages/ashlar_ui && fvm dart test   # the command
cd gallery && fvm flutter test           # the components
```
