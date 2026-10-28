// Ashlar UI for Jaspr: Field. Copied into your app by `ashlar add field`; it is yours to change.

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A control with its label above it, and a line of help or an error below.
///
/// [id] is the control's, so the label names it and a screen reader reads the help
/// with it.
class Field extends StatelessComponent {
  const Field({
    super.key,
    required this.label,
    required this.id,
    required this.child,
    this.description,
    this.error,
  });

  final String label;
  final String id;
  final Component child;

  /// Help under the control.
  final String? description;

  /// What is wrong, under the control in red. It replaces [description].
  final String? error;

  @override
  Component build(BuildContext context) {
    final note = error ?? description;
    return div(classes: 'ash-field', [
      Component.element(
        tag: 'label',
        classes: 'ash-field-label',
        attributes: {'for': id},
        children: [Component.text(label)],
      ),
      child,
      if (note != null)
        p(
          id: '$id-note',
          classes: error != null ? 'ash-field-error' : 'ash-field-description',
          attributes: {if (error != null) 'role': 'alert'},
          [Component.text(note)],
        ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.ash-field').styles(raw: {'display': 'grid', 'gap': '8px'}),
    css('.ash-field-label').styles(raw: {'font-size': '14px', 'line-height': '20px', 'font-weight': '500'}),
    css('.ash-field-description, .ash-field-error').styles(
      raw: {'margin': '0', 'font-size': '14px', 'line-height': '20px'},
    ),
    css('.ash-field-description').styles(raw: {'color': 'var(--ash-muted-foreground)'}),
    css('.ash-field-error').styles(raw: {'color': 'var(--ash-destructive)'}),
  ];
}
