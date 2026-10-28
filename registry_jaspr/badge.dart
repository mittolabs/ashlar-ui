// Ashlar UI for Jaspr: Badge. Copied into your app by `ashlar add badge`; it is yours to change.

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

enum BadgeVariant { primary, secondary, destructive, outline }

/// A small label: a status, a count, a tag.
///
/// ```dart
/// Badge('Active')
/// Badge('Rolled back', variant: BadgeVariant.destructive)
/// ```
class Badge extends StatelessComponent {
  const Badge(this.label, {super.key, this.variant = BadgeVariant.primary});

  final String label;
  final BadgeVariant variant;

  @override
  Component build(BuildContext context) =>
      span(classes: 'ash-badge ash-badge-${variant.name}', [Component.text(label)]);

  @css
  static List<StyleRule> get styles => [
    css('.ash-badge').styles(
      raw: {
        'display': 'inline-flex',
        'align-items': 'center',
        'gap': '4px',
        'width': 'fit-content',
        'white-space': 'nowrap',
        'padding': '2px 8px',
        'border': '1px solid transparent',
        'border-radius': 'var(--ash-radius-md)',
        'font-size': '12px',
        'line-height': '16px',
        'font-weight': '500',
      },
    ),
    css('.ash-badge-primary').styles(raw: {'background': 'var(--ash-primary)', 'color': 'var(--ash-primary-foreground)'}),
    css('.ash-badge-secondary').styles(
      raw: {'background': 'var(--ash-secondary)', 'color': 'var(--ash-secondary-foreground)'},
    ),
    css('.ash-badge-destructive').styles(
      raw: {'background': 'var(--ash-destructive)', 'color': 'var(--ash-destructive-foreground)'},
    ),
    css('.ash-badge-outline').styles(raw: {'border-color': 'var(--ash-border)', 'color': 'var(--ash-foreground)'}),
  ];
}
