// Ashlar UI: Input. Copied into your app by `ashlar add input`; it is yours to change.
//
// The widgets layer gives EditableText and no field around it: no selection handles, no
// cut and paste menu, no tap to place the cursor. This file supplies all three.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'theme.dart';

/// A one-line text field (or more, with [maxLines]), with a placeholder, focus ring and
/// error state, and selection, handles and a cut, copy and paste menu on every platform.
///
/// ```dart
/// Input(placeholder: 'Email', keyboardType: TextInputType.emailAddress, onChanged: (v) => email = v)
/// Input(controller: password, placeholder: 'Password', obscureText: true, error: wrong)
/// ```
class Input extends StatefulWidget {
  const Input({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.leading,
    this.trailing,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.error = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.semanticLabel,
    this.decorated = true,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;

  /// An icon or text before the text, inside the field.
  final Widget? leading;

  /// An icon or button after the text, inside the field.
  final Widget? trailing;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;

  /// Draws the field as invalid.
  final bool error;
  final bool autofocus;

  /// More than 1 makes a text area that grows to that many lines.
  final int maxLines;

  /// How tall a text area starts, in lines. Defaults to [maxLines], up to 3.
  final int? minLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Read out by screen readers; defaults to the placeholder.
  final String? semanticLabel;

  /// False draws the bare text, with no border, fill or ring: for an InputGroup, which
  /// draws those round the field and its addons together.
  final bool decorated;

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input>
    implements TextSelectionGestureDetectorBuilderDelegate {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;
  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());
  late final _gestures = TextSelectionGestureDetectorBuilder(delegate: this);
  bool _hovered = false;

  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => widget.enabled;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_refresh);
    _controller.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _focus.removeListener(_refresh);
    _controller.removeListener(_refresh);
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final focused = _focus.hasFocus;
    final style = t.text.sm.copyWith(color: c.foreground);
    final multiline = widget.maxLines > 1;
    final editable = EditableText(
      key: editableTextKey,
      controller: _controller,
      focusNode: _focus,
      readOnly: widget.readOnly || !widget.enabled,
      obscureText: widget.obscureText,
      autofocus: widget.autofocus,
      style: style,
      cursorColor: c.foreground,
      backgroundCursorColor: c.mutedForeground,
      cursorWidth: 1.5,
      cursorRadius: const Radius.circular(1),
      selectionColor: c.ring.withValues(alpha: .35),
      selectionControls: _AshlarSelectionControls(c.foreground),
      contextMenuBuilder: (context, state) => _SelectionMenu(state: state),
      maxLines: widget.maxLines,
      minLines: multiline
          ? (widget.minLines ?? widget.maxLines.clamp(1, 3))
          : null,
      keyboardType:
          widget.keyboardType ??
          (multiline ? TextInputType.multiline : TextInputType.text),
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      rendererIgnoresPointer: true,
      enableInteractiveSelection: widget.enabled,
      mouseCursor: widget.enabled
          ? SystemMouseCursors.text
          : SystemMouseCursors.basic,
    );
    final ringColor = widget.error ? c.destructive : c.ring;
    return Opacity(
      opacity: widget.enabled ? 1 : .5,
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.text
            : SystemMouseCursors.forbidden,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: TextFieldTapRegion(
          child: _gestures.buildGestureDetector(
            behavior: HitTestBehavior.translucent,
            child: AnimatedContainer(
              duration: t.duration,
              constraints: BoxConstraints(minHeight: multiline ? 64 : 36),
              padding: EdgeInsets.symmetric(
                horizontal: widget.decorated ? 12 : 0,
                vertical: multiline ? 8 : 0,
              ),
              decoration: !widget.decorated
                  ? null
                  : BoxDecoration(
                      // Opaque, so the shadow beneath does not show through.
                      color: t.brightness == Brightness.dark
                          ? Color.alphaBlend(
                              c.input.withValues(alpha: c.input.a * .3),
                              c.background,
                            )
                          : c.background,
                      borderRadius: BorderRadius.circular(t.radiusMd),
                      border: Border.all(
                        color: widget.error
                            ? c.destructive
                            : (focused
                                  ? c.ring
                                  : (_hovered
                                        ? c.ring.withValues(alpha: .6)
                                        : c.input)),
                      ),
                      boxShadow: [
                        if (focused)
                          BoxShadow(
                            color: ringColor.withValues(
                              alpha: widget.error ? .2 : .5,
                            ),
                            spreadRadius: 3,
                          ),
                        ...t.shadowXs,
                      ],
                    ),
              child: IconTheme.merge(
                data: IconThemeData(color: c.mutedForeground, size: 16),
                child: Row(
                  crossAxisAlignment: multiline
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    if (widget.leading != null) ...[
                      widget.leading!,
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Stack(
                        alignment: multiline
                            ? Alignment.topLeft
                            : Alignment.centerLeft,
                        children: [
                          if (_controller.text.isEmpty &&
                              widget.placeholder != null)
                            // The field announces the placeholder as its name, once.
                            ExcludeSemantics(
                              child: IgnorePointer(
                                child: Text(
                                  widget.placeholder!,
                                  style: style.copyWith(
                                    color: c.mutedForeground,
                                  ),
                                  maxLines: widget.maxLines,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          // The name goes on the node a screen reader focuses: the text itself.
                          MergeSemantics(
                            child: Semantics(
                              label: widget.semanticLabel ?? widget.placeholder,
                              enabled: widget.enabled,
                              child: editable,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.trailing != null) ...[
                      const SizedBox(width: 8),
                      widget.trailing!,
                    ],
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

/// Selection handles for touch: a small dot on a stem at each end of the selection.
class _AshlarSelectionControls extends TextSelectionControls {
  _AshlarSelectionControls(this.color);

  final Color color;
  static const _size = 18.0;

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) {
    if (type == TextSelectionHandleType.collapsed) {
      return const SizedBox.shrink();
    }
    final start = type == TextSelectionHandleType.left;
    return SizedBox(
      width: _size,
      height: _size + textLineHeight,
      child: CustomPaint(painter: _HandlePainter(color, start, textLineHeight)),
    );
  }

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) =>
      switch (type) {
        TextSelectionHandleType.left => Offset(_size / 2, textLineHeight),
        TextSelectionHandleType.right => const Offset(_size / 2, 0),
        TextSelectionHandleType.collapsed => Offset.zero,
      };

  @override
  Size getHandleSize(double textLineHeight) =>
      Size(_size, _size + textLineHeight);

  // The menu is built by contextMenuBuilder; this older hook is not used.
  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ValueListenable<ClipboardStatus>? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) => const SizedBox.shrink();
}

class _HandlePainter extends CustomPainter {
  _HandlePainter(this.color, this.start, this.lineHeight);

  final Color color;
  final bool start;
  final double lineHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final x = size.width / 2;
    // The start handle hangs below the text line, the end handle sits above it.
    final dot = start ? Offset(x, size.height - 6) : const Offset(9, 6);
    canvas.drawRect(
      Rect.fromLTWH(
        x - .75,
        start ? lineHeight : 6,
        1.5,
        size.height - lineHeight - 6,
      ),
      paint,
    );
    canvas.drawCircle(dot, 6, paint);
  }

  @override
  bool shouldRepaint(_HandlePainter old) => old.color != color;
}

/// The cut, copy, paste and select-all menu, drawn as a popover above the selection.
class _SelectionMenu extends StatelessWidget {
  const _SelectionMenu({required this.state});

  final EditableTextState state;

  static String _label(ContextMenuButtonItem item) =>
      item.label ??
      switch (item.type) {
        ContextMenuButtonType.cut => 'Cut',
        ContextMenuButtonType.copy => 'Copy',
        ContextMenuButtonType.paste => 'Paste',
        ContextMenuButtonType.selectAll => 'Select all',
        ContextMenuButtonType.delete => 'Delete',
        ContextMenuButtonType.lookUp => 'Look up',
        ContextMenuButtonType.searchWeb => 'Search',
        ContextMenuButtonType.share => 'Share',
        ContextMenuButtonType.liveTextInput => 'Scan text',
        ContextMenuButtonType.custom => '',
      };

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final items = state.contextMenuButtonItems
        .where((i) => _label(i).isNotEmpty)
        .toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final anchors = state.contextMenuAnchors;
    return CustomSingleChildLayout(
      delegate: TextSelectionToolbarLayoutDelegate(
        anchorAbove: anchors.primaryAnchor - const Offset(0, 8),
        anchorBelow:
            (anchors.secondaryAnchor ?? anchors.primaryAnchor) +
            const Offset(0, 24),
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: c.popover,
          borderRadius: BorderRadius.circular(t.radiusMd),
          border: Border.all(color: c.border),
          boxShadow: t.shadowLg,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items)
              GestureDetector(
                onTap: item.onPressed,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    _label(item),
                    style: t.text.sm.copyWith(color: c.popoverForeground),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
