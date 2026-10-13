// Ashlar UI block: sidebar-14. Copied into your app by `ashlar add sidebar-14`; it is yours
// to change. A table of contents on the right of the page.

import 'package:flutter/widgets.dart';

import '../ui/breadcrumb.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/theme.dart';

/// Sample contents: sections of pages.
const _sections = [
  ('Getting Started', ['Installation', 'Project Structure']),
  (
    'Build Your App',
    ['Routing', 'Data Fetching', 'Rendering', 'State', 'Styling'],
  ),
  ('API Reference', ['Components', 'Widgets', 'Functions', 'CLI']),
  ('Architecture', ['Layers', 'Hot Reload', 'Platform Channels']),
];

/// A sidebar on the right.
class Sidebar14 extends StatefulWidget {
  const Sidebar14({super.key});

  @override
  State<Sidebar14> createState() => _Sidebar14State();
}

class _Sidebar14State extends State<Sidebar14> {
  var _page = 'Data Fetching';

  @override
  Widget build(BuildContext context) => SidebarLayout(
    side: SidebarSide.end,
    collapse: SidebarCollapse.offcanvas,
    groups: [
      SidebarGroup(label: 'Table of Contents', [
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Breadcrumb(
                    items: [
                      BreadcrumbItem(
                        _sections.firstWhere((s) => s.$2.contains(_page)).$1,
                        onPressed: () {},
                      ),
                      BreadcrumbItem(_page),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                  child: Separator(axis: Axis.vertical),
                ),
                const SizedBox(width: 8),
                const SidebarTrigger(),
              ],
            ),
          ),
        ),
        const Separator(),
        const Expanded(child: _Placeholder()),
      ],
    ),
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
