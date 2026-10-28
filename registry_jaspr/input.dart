// Ashlar UI for Jaspr: Input. Copied into your app by `ashlar add input`; it is yours to change.

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A one-line text field. Give it an [id] and put it in a [Field] for its label.
///
/// ```dart
/// Field(label: 'Name', id: 'name', child: Input(id: 'name', value: name, onInput: (v) => name = v))
/// ```
class Input extends StatelessComponent {
  const Input({
    super.key,
    this.id,
    this.value,
    this.onInput,
    this.placeholder,
    this.type = InputType.text,
    this.name,
    this.disabled = false,
    this.invalid = false,
    this.monospace = false,
    this.autocomplete,
    this.semanticLabel,
  });

  final String? id;
  final String? value;

  /// Called with the text on every change.
  final ValueChanged<String>? onInput;
  final String? placeholder;
  final InputType type;
  final String? name;
  final bool disabled;

  /// Marks it as wrong: a red border, and read as invalid.
  final bool invalid;

  /// For codes and keys, where each character matters.
  final bool monospace;

  /// The browser's autocomplete hint: 'off', 'email', 'current-password'.
  final String? autocomplete;

  /// What a screen reader says, when there is no [Field] label.
  final String? semanticLabel;

  @override
  Component build(BuildContext context) => input<String>(
    id: id,
    name: name,
    type: type,
    value: value,
    disabled: disabled,
    classes: ['ash-input', if (monospace) 'ash-mono'].join(' '),
    attributes: {
      'placeholder': ?placeholder,
      'autocomplete': ?autocomplete,
      'aria-label': ?semanticLabel,
      if (invalid) 'aria-invalid': 'true',
    },
    onInput: onInput,
  );

  @css
  static List<StyleRule> get styles => [
    css('.ash-input', [
      css('&').styles(
        raw: {
          'display': 'block',
          'width': '100%',
          'min-height': '36px',
          'padding': '4px 12px',
          'border': '1px solid var(--ash-input)',
          'border-radius': 'var(--ash-radius-md)',
          'background': 'transparent',
          'color': 'var(--ash-foreground)',
          'font': 'inherit',
          'font-size': '14px',
          'line-height': '20px',
          'outline': 'none',
          'box-shadow': '0 1px 2px 0 rgb(0 0 0 / 0.05)',
          'transition': 'border-color 120ms, box-shadow 120ms',
        },
      ),
      css('&::placeholder').styles(raw: {'color': 'var(--ash-muted-foreground)'}),
      css('&:focus-visible').styles(raw: {'border-color': 'var(--ash-ring)', 'box-shadow': 'var(--ash-focus)'}),
      css('&[aria-invalid="true"]').styles(raw: {'border-color': 'var(--ash-destructive)'}),
      css('&:disabled').styles(raw: {'opacity': '0.5', 'cursor': 'not-allowed'}),
    ]),
  ];
}
