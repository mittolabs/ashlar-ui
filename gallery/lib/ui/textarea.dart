// Ashlar UI: Textarea. Copied into your app by `ashlar add textarea`; it is yours to change.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'input.dart';

/// A text field for more than one line. It starts [minLines] tall and grows to [maxLines]
/// as the text does, then scrolls.
///
/// ```dart
/// Textarea(placeholder: 'Tell us what happened', onChanged: (v) => note = v)
/// ```
class Textarea extends StatelessWidget {
  const Textarea({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.enabled = true,
    this.readOnly = false,
    this.error = false,
    this.autofocus = false,
    this.minLines = 3,
    this.maxLines = 8,
    this.inputFormatters,
    this.onChanged,
    this.semanticLabel,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final bool enabled;
  final bool readOnly;
  final bool error;
  final bool autofocus;
  final int minLines;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Input(
    controller: controller,
    focusNode: focusNode,
    placeholder: placeholder,
    enabled: enabled,
    readOnly: readOnly,
    error: error,
    autofocus: autofocus,
    minLines: minLines,
    maxLines: maxLines,
    keyboardType: TextInputType.multiline,
    textInputAction: TextInputAction.newline,
    inputFormatters: inputFormatters,
    onChanged: onChanged,
    semanticLabel: semanticLabel,
  );
}
