// Ashlar UI: the app shell. Copied into your app by `ashlar init`; it is yours to change.
// Use it in place of MaterialApp or CupertinoApp: it builds on WidgetsApp alone.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'selection.dart';
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
    this.selectable,
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

  /// Whether text on the app's pages can be selected and copied, as on a web page.
  /// Controls are left out: dragging over a button never selects its label. Null means
  /// yes on the web and the desktop, and no on iOS and Android, where apps do not do it.
  final bool? selectable;

  bool get _selectable =>
      selectable ??
      (kIsWeb ||
          switch (defaultTargetPlatform) {
            TargetPlatform.iOS ||
            TargetPlatform.android ||
            TargetPlatform.fuchsia => false,
            _ => true,
          });

  AshlarThemeData _themeFor(BuildContext context) => switch (themeMode) {
    AshlarThemeMode.light => theme,
    AshlarThemeMode.dark => darkTheme,
    AshlarThemeMode.system =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark
          ? darkTheme
          : theme,
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
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
          AshlarPageRoute<T>(settings: settings, builder: builder),
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
                child: ColoredBox(
                  color: data.colors.background,
                  child: _SelectionDefault(
                    selectable: _selectable,
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
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

/// Whether the app's pages are selectable, for [AshlarPageRoute] to read.
class _SelectionDefault extends InheritedWidget {
  const _SelectionDefault({required this.selectable, required super.child});

  final bool selectable;

  @override
  bool updateShouldNotify(_SelectionDefault old) =>
      old.selectable != selectable;
}

/// A page that fades and rises a little as it opens.
class AshlarPageRoute<T> extends PageRouteBuilder<T> {
  /// [selectable] null follows the app: [AshlarApp.selectable].
  AshlarPageRoute({
    required WidgetBuilder builder,
    bool? selectable,
    super.settings,
  }) : super(
         transitionDuration: const Duration(milliseconds: 220),
         reverseTransitionDuration: const Duration(milliseconds: 180),
         pageBuilder: (context, animation, secondary) {
           final on =
               selectable ??
               context
                   .dependOnInheritedWidgetOfExactType<_SelectionDefault>()
                   ?.selectable ??
               false;
           if (!on) return builder(context);
           // Each page is its own region, inside the Navigator's Overlay that its handles
           // and menu float in.
           final colors = AshlarTheme.of(context).colors;
           return SelectableRegion(
             selectionControls: AshlarSelectionControls(colors.foreground),
             contextMenuBuilder: (context, state) => AshlarSelectionMenu(
               anchors: state.contextMenuAnchors,
               items: state.contextMenuButtonItems,
             ),
             child: Builder(builder: builder),
           );
         },
         transitionsBuilder: (context, animation, secondary, child) {
           final curved = CurvedAnimation(
             parent: animation,
             curve: Curves.easeOutCubic,
           );
           return FadeTransition(
             opacity: curved,
             child: SlideTransition(
               position: Tween(
                 begin: const Offset(0, .02),
                 end: Offset.zero,
               ).animate(curved),
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
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
