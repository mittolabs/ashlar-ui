// Ashlar UI: Slider. Copied into your app by `ashlar add slider`; it is yours to change.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'theme.dart';

/// A value between [min] and [max], picked by dragging or tapping along a track, or with
/// the arrow keys (Page Up and Page Down move ten steps, Home and End to the ends).
///
/// ```dart
/// Slider(value: volume, onChanged: (v) => setState(() => volume = v), semanticLabel: 'Volume')
/// Slider(value: price, min: 0, max: 10000, step: 500, onChanged: setPrice, semanticLabel: 'Price')
/// ```
class Slider extends StatefulWidget {
  const Slider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.step,
    this.onChangeEnd,
    this.semanticLabel,
    this.semanticFormat,
    this.focusNode,
  });

  final double value;

  /// Null disables it.
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double min, max;

  /// What the value snaps to. Null moves freely; the keys then move a hundredth.
  final double? step;
  final String? semanticLabel;

  /// How a screen reader reads a value. Defaults to a percentage of the way along.
  final String Function(double value)? semanticFormat;
  final FocusNode? focusNode;

  @override
  State<Slider> createState() => _SliderState();
}

class _SliderState extends State<Slider> {
  bool _hovered = false, _focused = false, _dragging = false;

  bool get _enabled => widget.onChanged != null;
  double get _keyStep => widget.step ?? (widget.max - widget.min) / 100;
  double get _fraction =>
      ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

  double _snap(double v) {
    v = v.clamp(widget.min, widget.max);
    final s = widget.step;
    return s == null
        ? v
        : (widget.min + ((v - widget.min) / s).round() * s).clamp(
            widget.min,
            widget.max,
          );
  }

  void _set(double v) {
    v = _snap(v);
    if (v != widget.value) widget.onChanged?.call(v);
  }

  void _setFromX(double x, double width) => _set(
    widget.min + (x / width).clamp(0.0, 1.0) * (widget.max - widget.min),
  );

  String _read(double v) =>
      widget.semanticFormat?.call(v) ??
      '${((v - widget.min) / (widget.max - widget.min) * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    const thumb = 16.0;
    return Semantics(
      slider: true,
      label: widget.semanticLabel,
      enabled: _enabled,
      value: _read(widget.value),
      increasedValue: _read(_snap(widget.value + _keyStep)),
      decreasedValue: _read(_snap(widget.value - _keyStep)),
      onIncrease: _enabled ? () => _set(widget.value + _keyStep) : null,
      onDecrease: _enabled ? () => _set(widget.value - _keyStep) : null,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        enabled: _enabled,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.arrowRight): _StepIntent(1),
          SingleActivator(LogicalKeyboardKey.arrowUp): _StepIntent(1),
          SingleActivator(LogicalKeyboardKey.arrowLeft): _StepIntent(-1),
          SingleActivator(LogicalKeyboardKey.arrowDown): _StepIntent(-1),
          SingleActivator(LogicalKeyboardKey.pageUp): _StepIntent(10),
          SingleActivator(LogicalKeyboardKey.pageDown): _StepIntent(-10),
          SingleActivator(LogicalKeyboardKey.home): _StepIntent.toMin(),
          SingleActivator(LogicalKeyboardKey.end): _StepIntent.toMax(),
        },
        actions: {
          _StepIntent: CallbackAction<_StepIntent>(
            onInvoke: (i) {
              final v = i.toEnd == null
                  ? widget.value + i.steps * _keyStep
                  : (i.toEnd! ? widget.max : widget.min);
              _set(v);
              widget.onChangeEnd?.call(_snap(v));
              return null;
            },
          ),
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: LayoutBuilder(
            builder: (context, box) {
              final width = box.maxWidth.isFinite ? box.maxWidth : 200.0;
              // The thumb's centre runs from one end of the track to the other.
              final usable = width - thumb;
              void at(Offset p) => _setFromX(p.dx - thumb / 2, usable);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: _enabled ? (d) => at(d.localPosition) : null,
                onTapUp: _enabled
                    ? (_) => widget.onChangeEnd?.call(widget.value)
                    : null,
                onHorizontalDragStart: _enabled
                    ? (d) => setState(() => _dragging = true)
                    : null,
                onHorizontalDragUpdate: _enabled
                    ? (d) => at(d.localPosition)
                    : null,
                onHorizontalDragEnd: _enabled
                    ? (_) {
                        setState(() => _dragging = false);
                        widget.onChangeEnd?.call(widget.value);
                      }
                    : null,
                child: Opacity(
                  opacity: _enabled ? 1 : .5,
                  child: SizedBox(
                    width: width,
                    height: 20,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Positioned(
                          left: thumb / 2,
                          right: thumb / 2,
                          child: Container(
                            height: 6,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: c.muted,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: _fraction,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: c.primary,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: _fraction * usable,
                          child: AnimatedContainer(
                            duration: t.duration,
                            width: thumb,
                            height: thumb,
                            decoration: BoxDecoration(
                              color: c.background,
                              shape: BoxShape.circle,
                              border: Border.all(color: c.primary),
                              boxShadow: [
                                if (_focused ||
                                    ((_hovered || _dragging) && _enabled))
                                  BoxShadow(
                                    color: c.ring.withValues(alpha: .5),
                                    spreadRadius: 4,
                                  ),
                                ...t.shadowSm,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StepIntent extends Intent {
  const _StepIntent(this.steps) : toEnd = null;
  const _StepIntent.toMin() : steps = 0, toEnd = false;
  const _StepIntent.toMax() : steps = 0, toEnd = true;

  final int steps;

  /// True to the maximum, false to the minimum, null to move by [steps].
  final bool? toEnd;
}
