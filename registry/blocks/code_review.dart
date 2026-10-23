// Ashlar UI block: code-review. Copied into your app by `ashlar add code-review`; it is
// yours to change. A change to review: the files it touches above the project's tree,
// whose folders open and close, and the picked file's changes on the page, line by line.
//
// The project and its change are sample content, there to be replaced.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/avatar.dart';
import '../ui/badge.dart';
import '../ui/button.dart';
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

/// The project under review.
const _tree = [
  _Node('lib', [
    _Node('main.dart'),
    _Node('checkout', [
      _Node('checkout_screen.dart'),
      _Node('bank_transfer.dart'),
      _Node('order_total.dart'),
    ]),
    _Node('data', [_Node('payments.dart'), _Node('orders.dart')]),
  ]),
  _Node('test', [_Node('checkout_test.dart')]),
  _Node('pubspec.yaml'),
];

/// The files the change touches, with the lines added and taken out.
const _changes = [
  ('lib/checkout/bank_transfer.dart', '+48', '-0'),
  ('lib/checkout/checkout_screen.dart', '+12', '-4'),
  ('lib/data/payments.dart', '+9', '-2'),
  ('test/checkout_test.dart', '+31', '-0'),
];

/// A change under review, its files down the side.
class CodeReview extends StatefulWidget {
  const CodeReview({super.key});

  @override
  State<CodeReview> createState() => _CodeReviewState();
}

class _CodeReviewState extends State<CodeReview> {
  var _file = 'lib/checkout/checkout_screen.dart';

  @override
  Widget build(BuildContext context) => SidebarLayout(
    collapse: SidebarCollapse.offcanvas,
    groups: [
      SidebarGroup(label: 'Changed', [
        for (final (path, added, _) in _changes)
          SidebarItem(
            path.split('/').last,
            icon: AshlarIconsRoundedStroke.fileDiff,
            badge: added,
            active: path == _file,
            onPressed: () => setState(() => _file = path),
          ),
      ]),
      SidebarGroup.custom(
        label: 'Project',
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
    child: _Diff(file: _file),
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

/// The change itself: what it is and who made it along the top, then the picked file's
/// lines, those taken out and those added marked.
class _Diff extends StatelessWidget {
  const _Diff({required this.file});

  final String file;

  /// The lines shown: ' ' kept, '-' taken out, '+' added.
  static const _lines = [
    (' ', 'class CheckoutScreen extends StatelessWidget {'),
    (' ', '  const CheckoutScreen({super.key, required this.order});'),
    (' ', ''),
    (' ', '  @override'),
    (' ', '  Widget build(BuildContext context) => Column('),
    (' ', '    children: ['),
    (' ', '      OrderTotal(order: order),'),
    ('-', "      Button(onPressed: pay, child: Text('Pay')),"),
    ('+', '      Button('),
    ('+', '        onPressed: () => BankTransfer.show(context, order),'),
    ('+', "        child: Text('Pay by bank transfer'),"),
    ('+', '      ),'),
    (
      '+',
      "      Button.link(onPressed: payByCard, child: Text('Pay by card')),",
    ),
    (' ', '    ],'),
    (' ', '  );'),
    (' ', '}'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final mono = t.text.sm.copyWith(fontFamily: 'monospace', height: 1.7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              const SidebarTrigger(),
              const SizedBox(width: 8),
              const SizedBox(height: 16, child: Separator(axis: Axis.vertical)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pay by bank transfer at checkout',
                      overflow: TextOverflow.ellipsis,
                      style: t.text.base.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Avatar(size: 18, fallback: 'WO'),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Wangari Ochieng wants to merge bank-transfer into main',
                            overflow: TextOverflow.ellipsis,
                            style: t.text.xs.copyWith(color: c.mutedForeground),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Button(
                size: ButtonSize.sm,
                leading: const AshlarIcon(AshlarIconsRoundedStroke.check),
                onPressed: () {},
                child: const Text('Approve'),
              ),
            ],
          ),
        ),
        const Separator(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  file,
                  overflow: TextOverflow.ellipsis,
                  style: t.text.sm.copyWith(fontFamily: 'monospace'),
                ),
              ),
              const Badge(variant: BadgeVariant.outline, child: Text('+12 -4')),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(t.radiusLg),
                border: Border.all(color: c.border),
              ),
              // Every row as wide as the widest line or the box, whichever is
              // wider, so a changed line is marked right across.
              child: LayoutBuilder(
                builder: (context, box) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: box.maxWidth),
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (i, (mark, line)) in _lines.indexed)
                            Container(
                              color: switch (mark) {
                                '+' => c.primary.withValues(alpha: .08),
                                '-' => c.destructive.withValues(alpha: .08),
                                _ => null,
                              },
                              padding: const EdgeInsetsDirectional.only(
                                end: 16,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 44,
                                    child: Text(
                                      '${41 + i}',
                                      textAlign: TextAlign.end,
                                      style: mono.copyWith(
                                        color: c.mutedForeground,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 28,
                                    child: Text(
                                      mark,
                                      textAlign: TextAlign.center,
                                      style: mono.copyWith(
                                        color: mark == '-'
                                            ? c.destructive
                                            : c.foreground,
                                      ),
                                    ),
                                  ),
                                  Text(line, style: mono),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
