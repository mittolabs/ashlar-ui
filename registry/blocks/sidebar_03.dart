// Ashlar UI block: sidebar-03. Copied into your app by `ashlar add sidebar-03`; it is yours
// to change. Documentation navigation with each section's pages listed under it.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/breadcrumb.dart';
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

/// A sidebar of documentation, each section's pages under it.
class Sidebar03 extends StatefulWidget {
  const Sidebar03({super.key});

  @override
  State<Sidebar03> createState() => _Sidebar03State();
}

class _Sidebar03State extends State<Sidebar03> {
  var _page = 'Data Fetching';

  @override
  Widget build(BuildContext context) => SidebarLayout(
    collapse: SidebarCollapse.offcanvas,
    header: const _Brand(),
    groups: [
      SidebarGroup([
        for (final (section, pages) in _sections)
          SidebarItem(
            section,
            icon: null,
            initiallyOpen: true,
            children: [
              for (final page in pages)
                SidebarItem(
                  page,
                  icon: null,
                  active: page == _page,
                  onPressed: () => setState(() => _page = page),
                ),
            ],
          ),
      ]),
    ],
    child: _Page(
      trail: [_sections.firstWhere((s) => s.$2.contains(_page)).$1, _page],
    ),
  );
}

/// The product's mark, name and version.
class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return Padding(
      padding: const EdgeInsets.all(8),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Documentation',
                  overflow: TextOverflow.ellipsis,
                  style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                ),
                Text('v1.0.0', style: t.text.xs),
              ],
            ),
          ),
        ],
      ),
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
