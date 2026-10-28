// Ashlar UI for Jaspr: Card. Copied into your app by `ashlar add card`; it is yours to change.

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A panel with an optional title, description and action at its head, its content,
/// and a footer.
///
/// ```dart
/// Card(title: 'Devices', description: 'The last 28 days', children: [p([Component.text('1,204')])])
/// ```
class Card extends StatelessComponent {
  const Card({
    super.key,
    this.title,
    this.description,
    this.action,
    this.children = const [],
    this.footer,
  });

  final String? title;
  final String? description;

  /// At the head's end: a button, a menu.
  final Component? action;
  final List<Component> children;
  final Component? footer;

  @override
  Component build(BuildContext context) {
    final hasHead = title != null || description != null || action != null;
    return section(classes: 'ash-card', [
      if (hasHead)
        div(classes: 'ash-card-head', [
          div([
            if (title != null) h3(classes: 'ash-card-title', [Component.text(title!)]),
            if (description != null) p(classes: 'ash-card-description', [Component.text(description!)]),
          ]),
          ?action,
        ]),
      if (children.isNotEmpty) div(classes: 'ash-card-content', children),
      if (footer != null) div(classes: 'ash-card-footer', [footer!]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.ash-card').styles(
      raw: {
        'display': 'flex',
        'flex-direction': 'column',
        'gap': '24px',
        'padding': '24px 0',
        'border': '1px solid var(--ash-border)',
        'border-radius': 'var(--ash-radius-xl)',
        'background': 'var(--ash-card)',
        'color': 'var(--ash-card-foreground)',
        'box-shadow': 'var(--ash-shadow-sm)',
        'min-width': '0',
      },
    ),
    css('.ash-card-head').styles(
      raw: {
        'display': 'flex',
        'align-items': 'flex-start',
        'justify-content': 'space-between',
        'gap': '16px',
        'padding': '0 24px',
      },
    ),
    css('.ash-card-title').styles(
      raw: {'margin': '0', 'font-size': '16px', 'line-height': '1', 'font-weight': '600'},
    ),
    css('.ash-card-description').styles(
      raw: {
        'margin': '6px 0 0',
        'font-size': '14px',
        'line-height': '20px',
        'color': 'var(--ash-muted-foreground)',
      },
    ),
    css('.ash-card-content').styles(raw: {'padding': '0 24px', 'min-width': '0'}),
    css('.ash-card-footer').styles(raw: {'display': 'flex', 'align-items': 'center', 'padding': '0 24px'}),
  ];
}
