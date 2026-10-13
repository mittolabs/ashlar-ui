// Ashlar UI: the app shell. Copied into your app by `ashlar init`; it is yours to change.
// Use it in place of MaterialApp or CupertinoApp: it builds on WidgetsApp alone.

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Which theme an [AshlarApp] shows.
enum AshlarThemeMode { system, light, dark }

/// The root of an Ashlar UI app: navigation from [WidgetsApp], and the theme, text and
/// icon defaults every component reads.
class AshlarApp extends StatelessWidget {
  const AshlarApp({
    super.key,
    this.home,
    this.routes = const {},
    this.initialRoute,
    this.onGenerateRoute,
    this.navigatorKey,
    this.title = '',
    this.theme = const AshlarThemeData.light(),
    this.darkTheme = const AshlarThemeData.dark(),
    this.themeMode = AshlarThemeMode.system,
    this.locale,
    this.supportedLocales = const [Locale('en', 'US')],
    this.localizationsDelegates,
    this.builder,
  });

  final Widget? home;
  final Map<String, WidgetBuilder> routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
  final String title;
  final AshlarThemeData theme;
  final AshlarThemeData darkTheme;
  final AshlarThemeMode themeMode;
  final Locale? locale;
  final Iterable<Locale> supportedLocales;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final TransitionBuilder? builder;

  AshlarThemeData _themeFor(BuildContext context) => switch (themeMode) {
    AshlarThemeMode.light => theme,
    AshlarThemeMode.dark => darkTheme,
    AshlarThemeMode.system => MediaQuery.platformBrightnessOf(context) == Brightness.dark ? darkTheme : theme,
  };

  @override
  Widget build(BuildContext context) {
    final data = _themeFor(context);
    return WidgetsApp(
      navigatorKey: navigatorKey,
      home: home,
      routes: routes,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      title: title,
      color: data.colors.primary,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: localizationsDelegates,
      debugShowCheckedModeBanner: false,
      textStyle: data.text.sm.copyWith(color: data.colors.foreground),
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) => AshlarPageRoute<T>(settings: settings, builder: builder),
      builder: (context, child) {
        final data = _themeFor(context);
        Widget page = AshlarTheme(
          data: data,
          child: DefaultTextStyle(
            style: data.text.sm.copyWith(color: data.colors.foreground),
            child: IconTheme(
              data: IconThemeData(color: data.colors.foreground, size: 16),
              child: ScrollConfiguration(
                behavior: const _AshlarScrollBehavior(),
                child: ColoredBox(color: data.colors.background, child: child ?? const SizedBox.shrink()),
              ),
            ),
          ),
        );
        if (builder != null) page = builder!(context, page);
        return page;
      },
    );
  }
}

/// A page that fades and rises a little as it opens.
class AshlarPageRoute<T> extends PageRouteBuilder<T> {
  AshlarPageRoute({required WidgetBuilder builder, super.settings})
    : super(
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, animation, secondary) => builder(context),
        transitionsBuilder: (context, animation, secondary, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, .02), end: Offset.zero).animate(curved),
              child: child,
            ),
          );
        },
      );
}

/// Scrolling without Material's stretch or glow.
class _AshlarScrollBehavior extends ScrollBehavior {
  const _AshlarScrollBehavior();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}
