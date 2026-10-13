// Ashlar UI block: sidebar-11. Copied into your app by `ashlar add sidebar-11`; it is yours
// to change. A project's files as a tree whose folders open and close, with the changed
// files listed above it.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/breadcrumb.dart';
import '../ui/pressable.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/theme.dart';

/// A file, or a folder of more.
class _Node {
  const _Node(this.name, [this.children]);

  final String name;
  final List<_Node>? children;
}

/// A sample project.
const _tree = [
  _Node('lib', [
    _Node('main.dart'),
    _Node('ui', [_Node('button.dart'), _Node('card.dart')]),
    _Node('screens', [_Node('home.dart'), _Node('settings.dart')]),
  ]),
  _Node('test', [_Node('widget_test.dart')]),
  _Node('web', [_Node('index.html'), _Node('favicon.png')]),
  _Node('analysis_options.yaml'),
  _Node('pubspec.yaml'),
  _Node('README.md'),
];

/// Files changed since the last commit: modified or untracked.
const _changes = [
  ('lib/ui/button.dart', 'M'),
  ('lib/screens/settings.dart', 'U'),
  ('pubspec.yaml', 'M'),
];

/// A sidebar with a file tree.
class Sidebar11 extends StatefulWidget {
  const Sidebar11({super.key});

  @override
  State<Sidebar11> createState() => _Sidebar11State();
}

class _Sidebar11State extends State<Sidebar11> {
  var _file = 'lib/ui/button.dart';

  @override
  Widget build(BuildContext context) => SidebarLayout(
    collapse: SidebarCollapse.offcanvas,
    groups: [
      SidebarGroup(label: 'Changes', [
        for (final (path, state) in _changes)
          SidebarItem(
            path.split('/').last,
            icon: AshlarIconsRoundedStroke.file,
            badge: state,
            active: path == _file,
            onPressed: () => setState(() => _file = path),
          ),
      ]),
      SidebarGroup.custom(
        label: 'Files',
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final node in _tree)
              _Branch(
                node: node,
                path: node.name,
                picked: _file,
                onPicked: (p) => setState(() => _file = p),
              ),
          ],
        ),
      ),
    ],
    child: _Page(trail: _file.split('/')),
  );
}

/// One row of the tree: a file to pick, or a folder that opens onto its own rows.
class _Branch extends StatefulWidget {
  const _Branch({
    required this.node,
    required this.path,
    required this.picked,
    required this.onPicked,
  });

  final _Node node;
  final String path, picked;
  final ValueChanged<String> onPicked;

  @override
  State<_Branch> createState() => _BranchState();
}

class _BranchState extends State<_Branch> {
  // Folders on the way to the picked file start open.
  late var _open = widget.picked.startsWith('${widget.path}/');

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final children = widget.node.children;
    final folder = children != null;
    final picked = widget.path == widget.picked;
    final row = Pressable(
      onPressed: folder
          ? () => setState(() => _open = !_open)
          : () => widget.onPicked(widget.path),
      expanded: folder ? _open : null,
      selected: folder ? null : picked,
      semanticLabel: widget.node.name,
      builder: (context, states) => Container(
        height: 32,
        padding: const EdgeInsetsDirectional.only(start: 8, end: 8),
        decoration: BoxDecoration(
          color: picked || states.hovered
              ? c.sidebarAccent
              : const Color(0x00000000),
          borderRadius: BorderRadius.circular(t.radiusMd),
          border: states.focused ? Border.all(color: c.sidebarRing) : null,
        ),
        child: Row(
          children: [
            if (folder) ...[
              AnimatedRotation(
                turns: _open ? .25 : 0,
                duration: t.duration,
                child: AshlarIcon(
                  isRtl(context)
                      ? AshlarIconsRoundedStroke.chevronLeft
                      : AshlarIconsRoundedStroke.chevronRight,
                ),
              ),
              const SizedBox(width: 6),
            ],
            AshlarIcon(
              folder
                  ? (_open
                        ? AshlarIconsRoundedStroke.folderOpen
                        : AshlarIconsRoundedStroke.folder)
                  : AshlarIconsRoundedStroke.file,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(widget.node.name, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
    if (!folder) return row;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        if (_open)
          Container(
            margin: const EdgeInsetsDirectional.only(start: 15),
            padding: const EdgeInsetsDirectional.only(start: 6),
            decoration: BoxDecoration(
              border: BorderDirectional(
                start: BorderSide(color: c.sidebarBorder),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final child in children)
                  _Branch(
                    node: child,
                    path: '${widget.path}/${child.name}',
                    picked: widget.picked,
                    onPicked: widget.onPicked,
                  ),
              ],
            ),
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
