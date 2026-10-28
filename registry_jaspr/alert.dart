// Ashlar UI for Jaspr: Alert. Copied into your app by `ashlar add alert`; it is yours to change.

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A message that stays on the page: something to know, or something that went wrong.
///
/// A [destructive] alert is announced to screen readers as soon as it appears.
class Alert extends StatelessComponent {
  const Alert({
    super.key,
    required this.title,
    this.description,
    this.destructive = false,
    this.children = const [],
  });

  final String title;
  final String? description;
  final bool destructive;

  /// Below the description: a button, a link, a value to copy.
  final List<Component> children;

  @override
  Component build(BuildContext context) => div(
    classes: ['ash-alert', if (destructive) 'ash-alert-destructive'].join(' '),
    attributes: {'role': destructive ? 'alert' : 'status'},
    [
      p(classes: 'ash-alert-title', [Component.text(title)]),
      if (description != null) p(classes: 'ash-alert-description', [Component.text(description!)]),
      ...children,
    ],
  );

  @css
  static List<StyleRule> get styles => [
    css('.ash-alert').styles(
      raw: {
        'display': 'grid',
        'gap': '4px',
        'padding': '12px 16px',
        'border': '1px solid var(--ash-border)',
        'border-radius': 'var(--ash-radius-lg)',
        'background': 'var(--ash-card)',
        'color': 'var(--ash-card-foreground)',
        'font-size': '14px',
        'line-height': '20px',
      },
    ),
    css('.ash-alert-title').styles(raw: {'margin': '0', 'font-weight': '500'}),
    css('.ash-alert-description').styles(raw: {'margin': '0', 'color': 'var(--ash-muted-foreground)'}),
    css('.ash-alert-destructive').styles(raw: {'color': 'var(--ash-destructive)'}),
    css('.ash-alert-destructive .ash-alert-description').styles(
      raw: {'color': 'color-mix(in srgb, var(--ash-destructive) 90%, transparent)'},
    ),
  ];
}
