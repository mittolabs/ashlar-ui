// Ashlar UI: Tabs. Copied into your app by `ashlar add tabs`; it is yours to change.

import 'dart:ui' show SemanticsRole;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'pressable.dart';
import 'theme.dart';

/// One tab: its [label] in the list and the [content] shown when it is chosen.
@immutable
class TabItem {
  const TabItem({
    required this.label,
    required this.content,
    this.icon,
    this.enabled = true,
  });

  final Widget label;
  final Widget content;

  /// A 16px icon before the label.
  final Widget? icon;
  final bool enabled;
}

/// Views of one thing, one at a time, chosen from a row of tabs. Tab moves into the row
/// and out again; the arrow keys move along it, choosing as they go.
///
/// Give [index] and [onChanged] to hold the choice yourself; leave them out and the tabs
/// hold it, starting at [initialIndex].
///
/// ```dart
/// Tabs(tabs: [
///   TabItem(label: Text('Account'), content: AccountForm()),
///   TabItem(label: Text('Password'), content: PasswordForm()),
/// ])
/// ```
class Tabs extends StatefulWidget {
  const Tabs({
    super.key,
    required this.tabs,
    this.index,
    this.onChanged,
    this.initialIndex = 0,
    this.expand = false,
  });

  final List<TabItem> tabs;
  final int? index;
  final ValueChanged<int>? onChanged;
  final int initialIndex;

  /// Stretches the row of tabs across the width it is given.
  final bool expand;

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  late int _own = widget.initialIndex;
  final List<FocusNode> _nodes = [];

  int get _index => widget.index ?? _own;

  void _choose(int i, {bool focus = false}) {
    if (!widget.tabs[i].enabled) return;
    if (widget.index == null) setState(() => _own = i);
    widget.onChanged?.call(i);
    if (focus) _nodes[i].requestFocus();
  }

  /// The next enabled tab from the chosen one, [step] along, wrapping round.
  void _move(int step) {
    final n = widget.tabs.length;
    for (var k = 1; k <= n; k++) {
      final i = ((_index + step * k) % n + n) % n;
      if (widget.tabs[i].enabled) return _choose(i, focus: true);
    }
  }

  @override
  void dispose() {
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final dark = t.brightness == Brightness.dark;
    while (_nodes.length < widget.tabs.length) {
      _nodes.add(FocusNode());
    }
    // Only the chosen tab is in the Tab order; the arrow keys reach the rest.
    for (final (i, n) in _nodes.indexed) {
      n.skipTraversal = i != _index;
    }
    final triggers = [
      for (final (i, tab) in widget.tabs.indexed)
        Pressable(
          onPressed: tab.enabled ? () => _choose(i) : null,
          focusNode: _nodes[i],
          role: SemanticsRole.tab,
          selected: i == _index,
          builder: (context, state) {
            final active = i == _index;
            final fg = active || !dark ? c.foreground : c.mutedForeground;
            return Opacity(
              opacity: state.enabled ? 1 : .5,
              child: AnimatedContainer(
                duration: t.duration,
                height: 29,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active
                      ? (dark ? c.input.withValues(alpha: .3) : c.background)
                      : const Color(0x00000000),
                  borderRadius: BorderRadius.circular(t.radiusMd),
                  border: Border.all(
                    color: active && dark ? c.input : const Color(0x00000000),
                  ),
                  boxShadow: [
                    if (state.focused) ...t.focusRing,
                    if (active) ...t.shadowSm,
                  ],
                ),
                child: DefaultTextStyle.merge(
                  style: t.text.sm.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  child: IconTheme.merge(
                    data: IconThemeData(color: fg, size: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (tab.icon != null) ...[
                          tab.icon!,
                          const SizedBox(width: 6),
                        ],
                        Flexible(child: tab.label),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
    ];
    final list = Shortcuts(
      includeSemantics: false,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowRight): _MoveIntent(1),
        SingleActivator(LogicalKeyboardKey.arrowLeft): _MoveIntent(-1),
      },
      child: Actions(
        actions: {
          _MoveIntent: CallbackAction<_MoveIntent>(
            onInvoke: (i) => _move(i.step),
          ),
        },
        child: Container(
          height: 36,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: c.muted,
            borderRadius: BorderRadius.circular(t.radiusLg),
          ),
          child: Semantics(
            role: SemanticsRole.tabBar,
            container: true,
            explicitChildNodes: true,
            child: Row(
              mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                for (final trigger in triggers)
                  widget.expand ? Expanded(child: trigger) : trigger,
              ],
            ),
          ),
        ),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.expand
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.start,
      children: [
        list,
        const SizedBox(height: 8),
        Semantics(
          role: SemanticsRole.tabPanel,
          container: true,
          child: KeyedSubtree(
            key: ValueKey(_index),
            child: widget.tabs[_index].content,
          ),
        ),
      ],
    );
  }
}

class _MoveIntent extends Intent {
  const _MoveIntent(this.step);

  final int step;
}
