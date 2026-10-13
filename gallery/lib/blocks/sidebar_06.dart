// Ashlar UI block: sidebar-06. Copied into your app by `ashlar add sidebar-06`; it is yours
// to change. Each section opens its pages as a menu beside the sidebar, and a newsletter
// sign-up sits at the bottom.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/breadcrumb.dart';
import '../ui/button.dart';
import '../ui/card.dart';
import '../ui/dropdown_menu.dart';
import '../ui/input.dart';
import '../ui/popover.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/theme.dart';

/// Sample navigation: sections of pages.
const _sections = [
  ('Getting Started', ['Installation', 'Project Structure']),
  (
    'Build Your App',
    ['Routing', 'Data Fetching', 'Rendering', 'State', 'Styling', 'Testing'],
  ),
  ('API Reference', ['Components', 'Widgets', 'Functions', 'CLI']),
  ('Architecture', ['Layers', 'Hot Reload', 'Platform Channels']),
  ('Community', ['Contribution Guide']),
];

/// A sidebar whose sections open as menus.
class Sidebar06 extends StatefulWidget {
  const Sidebar06({super.key});

  @override
  State<Sidebar06> createState() => _Sidebar06State();
}

class _Sidebar06State extends State<Sidebar06> {
  var _page = 'Data Fetching';

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return SidebarLayout(
      collapse: SidebarCollapse.offcanvas,
      header: const _Brand(),
      groups: [
        SidebarGroup.custom(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (section, pages) in _sections)
                DropdownMenu(
                  side: PopoverSide.right,
                  width: 192,
                  builder: (context, menu) => Button(
                    variant: ButtonVariant.ghost,
                    expand: true,
                    onPressed: menu.open,
                    trailing: const AshlarIcon(
                      AshlarIconsRoundedStroke.ellipsis,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        section,
                        style: t.text.sm.copyWith(
                          fontWeight: pages.contains(_page)
                              ? FontWeight.w600
                              : null,
                        ),
                      ),
                    ),
                  ),
                  items: [
                    for (final page in pages)
                      MenuItem(
                        selected: page == _page,
                        onPressed: () => setState(() => _page = page),
                        child: Text(page),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
      footer: const _OptIn(),
      child: _Page(
        trail: [_sections.firstWhere((s) => s.$2.contains(_page)).$1, _page],
      ),
    );
  }
}

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

/// A small card asking for an email address for the newsletter.
class _OptIn extends StatelessWidget {
  const _OptIn();

  @override
  Widget build(BuildContext context) => Card(
    size: CardSize.sm,
    children: [
      const CardHeader(
        title: Text('Subscribe to our newsletter'),
        description: Text(
          'Opt-in to receive updates and news about the sidebar.',
        ),
      ),
      CardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Input(
              placeholder: 'Email',
              semanticLabel: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            Button(
              size: ButtonSize.sm,
              variant: ButtonVariant.secondary,
              expand: true,
              onPressed: () {},
              child: const Text('Subscribe'),
            ),
          ],
        ),
      ),
    ],
  );
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
