// Ashlar UI: Command. Copied into your app by `ashlar add command`; it is yours to change.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'dialog.dart';
import 'input.dart';
import 'theme.dart';

/// Something a [Command] can do or pick.
@immutable
class CommandItem {
  const CommandItem(
    this.label, {
    required this.onSelected,
    this.keywords = const [],
    this.leading,
    this.shortcut,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onSelected;

  /// Other words it is found by: "invoice" for "Billing".
  final List<String> keywords;
  final Widget? leading;
  final String? shortcut;
  final bool enabled;
}

/// A titled run of items in a [Command].
@immutable
class CommandGroup {
  const CommandGroup(this.items, {this.heading});

  final String? heading;
  final List<CommandItem> items;
}

/// A search box over a list of things to do: typing narrows the list, the arrow keys
/// move the highlight while the typing stays in the box, and Enter picks. For a menu of
/// many commands, or a picker over a long list; [showCommandDialog] opens one over the
/// page, the way ⌘K does.
///
/// ```dart
/// Command(groups: [
///   CommandGroup(heading: 'Suggestions', [
///     CommandItem('Calendar', leading: AshlarIcon(AshlarIconsRoundedStroke.calendar), onSelected: openCalendar),
///     CommandItem('Search emoji', onSelected: openEmoji),
///   ]),
///   CommandGroup(heading: 'Settings', [CommandItem('Profile', shortcut: '⌘P', onSelected: openProfile)]),
/// ])
/// ```
class Command extends StatefulWidget {
  const Command({
    super.key,
    required this.groups,
    this.placeholder = 'Type a command or search…',
    this.emptyText = 'No results found.',
    this.autofocus = true,
    this.maxHeight = 300,
  });

  final List<CommandGroup> groups;
  final String placeholder;
  final String emptyText;
  final bool autofocus;
  final double maxHeight;

  @override
  State<Command> createState() => _CommandState();
}

class _CommandState extends State<Command> {
  final _query = TextEditingController();
  int _at = 0;
  final _keys = <CommandItem, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() => _at = 0));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  /// Every word typed is somewhere in the item's label or keywords.
  bool _matches(CommandItem item) {
    final words = _query.text
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty);
    final hay = [item.label, ...item.keywords].join(' ').toLowerCase();
    return words.every(hay.contains);
  }

  List<CommandGroup> get _shown => [
    for (final g in widget.groups)
      if (g.items.any(_matches))
        CommandGroup(g.items.where(_matches).toList(), heading: g.heading),
  ];

  List<CommandItem> get _pickable => [
    for (final g in _shown) ...g.items.where((i) => i.enabled),
  ];

  void _move(int by) {
    final n = _pickable.length;
    if (n == 0) return;
    setState(() => _at = (_at + by).clamp(0, n - 1));
    final key = _keys[_pickable[_at]];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        alignmentPolicy: by > 0
            ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
            : ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    }
  }

  void _pick() {
    final items = _pickable;
    if (_at < items.length) items[_at].onSelected();
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final shown = _shown, pickable = _pickable;
    final lit = pickable.isEmpty
        ? null
        : pickable[_at.clamp(0, pickable.length - 1)];
    return DefaultTextStyle.merge(
      style: t.text.sm.copyWith(color: c.popoverForeground),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                  _move(1),
              const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                  _move(-1),
              const SingleActivator(
                LogicalKeyboardKey.home,
                control: true,
              ): () =>
                  _move(-pickable.length),
              const SingleActivator(
                LogicalKeyboardKey.end,
                control: true,
              ): () =>
                  _move(pickable.length),
              const SingleActivator(LogicalKeyboardKey.enter): _pick,
            },
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: c.border)),
              ),
              child: Row(
                children: [
                  AshlarIcon(
                    AshlarIconsRoundedStroke.search,
                    size: 16,
                    color: c.mutedForeground.withValues(alpha: .5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Input(
                      decorated: false,
                      controller: _query,
                      autofocus: widget.autofocus,
                      placeholder: widget.placeholder,
                      textInputAction: TextInputAction.go,
                      onSubmitted: (_) => _pick(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // The highlighted item, read out as it changes: the typing stays in the box.
          Semantics(
            liveRegion: true,
            label: lit?.label ?? (shown.isEmpty ? widget.emptyText : ''),
            child: const SizedBox(),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.maxHeight),
            child: shown.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      widget.emptyText,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.mutedForeground),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (gi, g) in shown.indexed) ...[
                          if (gi > 0)
                            Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: c.border,
                            ),
                          if (g.heading != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                              child: Semantics(
                                header: true,
                                child: Text(
                                  g.heading!,
                                  style: t.text.xs.copyWith(
                                    color: c.mutedForeground,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          for (final item in g.items)
                            _Row(
                              key: _keys.putIfAbsent(item, GlobalKey.new),
                              item: item,
                              lit: identical(item, lit),
                              onHover: () {
                                final i = pickable.indexOf(item);
                                if (i >= 0 && i != _at) setState(() => _at = i);
                              },
                            ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    super.key,
    required this.item,
    required this.lit,
    required this.onHover,
  });

  final CommandItem item;
  final bool lit;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final fg = lit ? c.accentForeground : c.popoverForeground;
    return MouseRegion(
      cursor: item.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: item.enabled ? (_) => onHover() : null,
      child: Semantics(
        button: true,
        selected: lit,
        enabled: item.enabled,
        onTap: item.enabled ? item.onSelected : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: item.enabled ? item.onSelected : null,
          child: Opacity(
            opacity: item.enabled ? 1 : .5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: lit ? c.accent : const Color(0x00000000),
                borderRadius: BorderRadius.circular(t.radiusSm),
              ),
              child: IconTheme.merge(
                data: IconThemeData(color: c.mutedForeground, size: 16),
                child: Row(
                  children: [
                    if (item.leading != null) ...[
                      item.leading!,
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(color: fg),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.shortcut != null)
                      Text(
                        item.shortcut!,
                        style: t.text.xs.copyWith(
                          color: c.mutedForeground,
                          letterSpacing: 1.2,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens a [Command] over the page, the way ⌘K does. Picking an item closes it first.
Future<void> showCommandDialog({
  required BuildContext context,
  required List<CommandGroup> groups,
  String placeholder = 'Type a command or search…',
}) => showAshlarDialog<void>(
  context: context,
  builder: (context) {
    final t = AshlarTheme.of(context);
    void close() => Navigator.pop(context);
    return SafeArea(
      child: Align(
        alignment: const Alignment(0, -.4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 512),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: t.colors.popover,
                borderRadius: BorderRadius.circular(t.radiusLg),
                border: Border.all(color: t.colors.border),
                boxShadow: t.shadowLg,
              ),
              child: Command(
                placeholder: placeholder,
                groups: [
                  for (final g in groups)
                    CommandGroup(heading: g.heading, [
                      for (final i in g.items)
                        CommandItem(
                          i.label,
                          keywords: i.keywords,
                          leading: i.leading,
                          shortcut: i.shortcut,
                          enabled: i.enabled,
                          onSelected: () {
                            close();
                            i.onSelected();
                          },
                        ),
                    ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  },
);
