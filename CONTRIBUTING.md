# Contributing

Pull requests are welcome. Ashlar UI takes bug fixes, accessibility, tooling, consistency
between components, and components that unrelated apps clearly need. It doesn't take a
look or an option that exists for one app's design: that belongs in your copy.

| Folder | What's in it |
|---|---|
| `registry/` | The components' sources: what `ashlar add` copies. Edit them here. |
| `packages/ashlar` | The `ashlar` command: copying, updating, diffing, `check`, `shot`, the MCP server. |
| `packages/ashlar_ui` | Ashlar UI's registry, as data the command is built with. `dart run tool/bundle.dart` writes it from `registry/`. |
| `gallery/` | Every component in every state, installed with `ashlar add --all`, and their tests. |

Flutter runs through [fvm](https://fvm.app) on the stable channel. Commits follow
[Conventional Commits](https://www.conventionalcommits.org); turn on the hook with
`git config core.hooksPath .githooks`.

```sh
dart run tool/bundle.dart                # after changing registry/
cd packages/ashlar && fvm dart test      # the command
cd gallery && fvm flutter test           # the components
```

## Releasing

Nobody publishes from a laptop. The repository has one version, in semver: `ashlar` and
`ashlar_ui` are released together at it, tagged `v0.11.0`. Commits to `main`
([Conventional Commits](https://www.conventionalcommits.org)) collect in a release pull
request that release-please keeps open: `feat` raises the minor version, `fix` and `perf`
the patch, a breaking change the minor while we are on 0.x, and the changelog is written
from them. Merging that pull request sets the version in both pubspecs, `ashlar`'s
dependency on `ashlar_ui` and `version.txt`, tags the release, writes its GitHub Release,
and publishes both packages to pub.dev from GitHub Actions (`.github/workflows/publish.yml`).
