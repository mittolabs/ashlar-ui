# ashlar_ui

[Ashlar UI](https://ui.ashlar.ke)'s registry: every component and block, on Flutter's
widgets layer alone, with the tests each one brings and the packages it needs. It is
data, read by the `ashlar` command, which copies them into your app as code you own.

You do not add this package to your app. Install the command:

```sh
dart pub global activate ashlar
ashlar init && ashlar add button
```

Until 0.10.0 the command came with this package. Since 0.11.0 it is
[`ashlar`](https://pub.dev/packages/ashlar), and `ashlar_ui`'s own executable says so.

## Licence

MIT.
