// Ashlar UI block: sidebar-01. Copied into your app by `ashlar add sidebar-01`; it is yours
// to change. Documentation navigation grouped by section, with a version switcher and a
// search field at the top.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/breadcrumb.dart';
import '../ui/button.dart';
import '../ui/dropdown_menu.dart';
import '../ui/input.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/theme.dart';

/// Sample navigation: sections of pages, one of them open.
const _sections = [
  ('Getting Started', ['Installation', 'Project Structure']),
  (
    'Build Your App',
    [
      'Routing',
      'Data Fetching',
      'Rendering',
      'State',
      'Styling',
      'Testing',
      'Accessibility',
      'Deploying',
    ],
  ),
  ('API Reference', ['Components', 'Widgets', 'Functions', 'CLI']),
  (
    'Architecture',
    ['Layers', 'Hot Reload', 'Platform Channels', 'Supported Platforms'],
  ),
  ('Community', ['Contribution Guide']),
];

/// A sidebar of documentation, grouped by section.
class Sidebar01 extends StatefulWidget {
  const Sidebar01({super.key});

  @override
  State<Sidebar01> createState() => _Sidebar01State();
}

class _Sidebar01State extends State<Sidebar01> {
  var _page = 'Data Fetching';
  var _version = '1.0.1';

  @override
  Widget build(BuildContext context) => SidebarLayout(
    collapse: SidebarCollapse.offcanvas,
    header: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _VersionSwitcher(
          version: _version,
          versions: const ['1.0.1', '1.1.0-alpha', '2.0.0-beta1'],
          onChanged: (v) => setState(() => _version = v),
        ),
        const SizedBox(height: 8),
        const Input(
          placeholder: 'Search the docs…',
          semanticLabel: 'Search the docs',
          leading: AshlarIcon(AshlarIconsRoundedStroke.search),
        ),
      ],
    ),
    groups: [
      for (final (section, pages) in _sections)
        SidebarGroup(label: section, [
          for (final page in pages)
            SidebarItem(
              page,
              icon: null,
              active: page == _page,
              onPressed: () => setState(() => _page = page),
            ),
        ]),
    ],
    child: _Page(
      trail: [_sections.firstWhere((s) => s.$2.contains(_page)).$1, _page],
    ),
  );
}

/// The product's mark and name, and a menu of its versions.
class _VersionSwitcher extends StatelessWidget {
  const _VersionSwitcher({
    required this.version,
    required this.versions,
    required this.onChanged,
  });

  final String version;
  final List<String> versions;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return DropdownMenu(
      builder: (context, menu) => Button(
        variant: ButtonVariant.ghost,
        expand: true,
        semanticLabel: 'Documentation, version $version',
        onPressed: menu.open,
        trailing: const AshlarIcon(AshlarIconsRoundedStroke.chevronsUpDown),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: c.sidebarPrimary,
                borderRadius: BorderRadius.circular(t.radiusLg),
              ),
              child: AshlarIcon(
                AshlarIconsRoundedStroke.galleryVerticalEnd,
                color: c.sidebarPrimaryForeground,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Documentation',
                    style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text('v$version', style: t.text.xs),
                ],
              ),
            ),
          ],
        ),
      ),
      items: [
        for (final v in versions)
          MenuItem(
            selected: v == version,
            onPressed: () => onChanged(v),
            child: Text(v),
          ),
      ],
    );
  }
}

/// The page beside the sidebar: the trigger and where you are along the top, and room
/// for your content under it.
class _Page extends StatelessWidget {
  const _Page({required this.trail});

  /// Where you are, from the top down; the last is this page.
  final List<String> trail;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const SidebarTrigger(),
              const SizedBox(width: 8),
              const SizedBox(height: 16, child: Separator(axis: Axis.vertical)),
              const SizedBox(width: 8),
              Expanded(
                child: Breadcrumb(
                  items: [
                    for (final (i, label) in trail.indexed)
                      BreadcrumbItem(
                        label,
                        onPressed: i == trail.length - 1 ? null : () {},
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const Separator(),
      const Expanded(child: _Placeholder()),
    ],
  );
}

/// Grey shapes where the page's content goes.
class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final box = BoxDecoration(
      color: t.colors.muted.withValues(alpha: .5),
      borderRadius: BorderRadius.circular(t.radiusXl),
    );
    return LayoutBuilder(
      builder: (context, size) => size.maxWidth >= 768
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: 16),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: DecoratedBox(decoration: box),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SizedBox.expand(
                      child: DecoratedBox(decoration: box),
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (var i = 0; i < 3; i++) ...[
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: DecoratedBox(decoration: box),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(height: 480, child: DecoratedBox(decoration: box)),
              ],
            ),
    );
  }
}
