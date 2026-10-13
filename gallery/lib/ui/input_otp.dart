// Ashlar UI: Input OTP. Copied into your app by `ashlar add input-otp`; it is yours to change.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'group.dart';
import 'theme.dart';

/// A one-time code, one character to a box: typed, pasted whole, or filled in by the
/// phone from a text message. [onCompleted] runs when every box is full.
///
/// ```dart
/// InputOtp(length: 6, groups: [3, 3], onCompleted: (code) => verify(code))
/// ```
class InputOtp extends StatefulWidget {
  const InputOtp({
    super.key,
    this.length = 6,
    this.groups,
    this.onChanged,
    this.onCompleted,
    this.digitsOnly = true,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.error = false,
    this.semanticLabel = 'One-time code',
  });

  /// How many characters the code has.
  final int length;

  /// How the boxes are split, with a dash between groups: [3, 3]. Null keeps them together.
  final List<int>? groups;

  /// Told each new value as it changes.
  final ValueChanged<String>? onChanged;

  /// Told the code once every box is filled.
  final ValueChanged<String>? onCompleted;

  /// Takes digits alone.
  final bool digitsOnly;

  /// Holds its state, to read and change from outside; one is made when not given.
  final TextEditingController? controller;

  /// Its focus node, to move focus to it or follow it from outside; one is made when not
  /// given.
  final FocusNode? focusNode;

  /// Takes the keyboard's focus when it first appears.
  final bool autofocus;

  /// False fades it and stops it taking presses and focus.
  final bool enabled;

  /// Marks it as wrong, in the destructive colour. Inside a FormItem, a screen reader
  /// also hears that it is invalid.
  final bool error;

  /// What a screen reader calls it when its visible text does not say, as for an icon
  /// alone.
  final String semanticLabel;

  @override
  State<InputOtp> createState() => _InputOtpState();
}

class _InputOtpState extends State<InputOtp> {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;
  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _focus.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _focus.removeListener(_refresh);
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  void _changed(String v) {
    widget.onChanged?.call(v);
    if (v.length == widget.length) widget.onCompleted?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final text = _controller.text;
    final focused = _focus.hasFocus;
    // The box being typed into: the next empty one, or the last when all are full.
    final active = text.length < widget.length
        ? text.length
        : widget.length - 1;
    Widget slot(int i) {
      final on = focused && i == active;
      final ring = widget.error ? c.destructive : c.ring;
      return Builder(
        builder: (context) => AnimatedContainer(
          duration: t.duration,
          width: t.control(36),
          height: t.control(36),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: t.brightness == Brightness.dark
                ? Color.alphaBlend(
                    c.input.withValues(alpha: c.input.a * .3),
                    c.background,
                  )
                : c.background,
            borderRadius: joinedRadius(context, t.radiusMd),
            border: on
                ? Border.all(color: ring)
                : joinedBorder(context, widget.error ? c.destructive : c.input),
            boxShadow: [
              if (on)
                BoxShadow(
                  color: ring.withValues(alpha: widget.error ? .2 : .5),
                  spreadRadius: 3,
                ),
            ],
          ),
          child: i < text.length
              ? Text(text[i], style: t.text.sm.copyWith(color: c.foreground))
              : (on ? _Caret(color: c.foreground) : null),
        ),
      );
    }

    final groups = widget.groups ?? [widget.length];
    var start = 0;
    final rows = <Widget>[];
    for (final (g, size) in groups.indexed) {
      if (g > 0) {
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(width: 8, height: 2, color: c.mutedForeground),
          ),
        );
      }
      rows.add(
        JoinedGroup(
          children: [for (var i = start; i < start + size; i++) slot(i)],
        ),
      );
      start += size;
    }
    // One real text field over the boxes takes the typing, pasting and the phone's
    // autofill; it draws nothing itself.
    final field = EditableText(
      controller: _controller,
      focusNode: _focus,
      autofocus: widget.autofocus,
      readOnly: !widget.enabled,
      style: const TextStyle(color: Color(0x00000000), fontSize: 1),
      cursorColor: const Color(0x00000000),
      backgroundCursorColor: const Color(0x00000000),
      showCursor: false,
      enableInteractiveSelection: false,
      keyboardType: widget.digitsOnly
          ? TextInputType.number
          : TextInputType.text,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [
        if (widget.digitsOnly) FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(widget.length),
      ],
      onChanged: _changed,
    );
    return Opacity(
      opacity: widget.enabled ? 1 : .5,
      child: MergeSemantics(
        child: Semantics(
          label: widget.semanticLabel,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled ? _focus.requestFocus : null,
            child: Stack(
              children: [
                Positioned.fill(child: field),
                ExcludeSemantics(
                  child: IgnorePointer(
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: rows,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A blinking caret in the empty box being typed into.
class _Caret extends StatefulWidget {
  const _Caret({required this.color});

  final Color color;

  @override
  State<_Caret> createState() => _CaretState();
}

class _CaretState extends State<_Caret> with SingleTickerProviderStateMixin {
  late final _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _blink,
    builder: (context, _) => Opacity(
      opacity: _blink.value < .5 ? 1 : 0,
      child: Container(width: 1, height: 16, color: widget.color),
    ),
  );
}
