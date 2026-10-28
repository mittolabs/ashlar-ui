// Ashlar UI for Jaspr: Button. Copied into your app by `ashlar add button`; it is yours to change.

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

enum ButtonVariant {
  /// The main action on a screen.
  primary,

  /// A quieter action beside the main one.
  secondary,

  /// An action with a border and no fill.
  outline,

  /// An action with no border or fill until it is hovered: toolbars, menus.
  ghost,

  /// An action that deletes or cannot be undone.
  destructive,

  /// Text that acts like a link, with no padding at its sides so it sits among words.
  link,
}

enum ButtonSize { xs, sm, md, lg }

/// A button: a native <button>, so it takes focus, Enter and Space, and is read as one.
///
/// ```dart
/// Button(label: 'Save', onPressed: save)
/// Button(label: 'Roll back', variant: ButtonVariant.destructive, onPressed: confirm)
/// ```
class Button extends StatelessComponent {
  const Button({
    super.key,
    this.label,
    this.children = const [],
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.onPressed,
    this.submit = false,
    this.disabled = false,
    this.expand = false,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// Its text. [children] come after it: an icon, a count.
  final String? label;
  final List<Component> children;
  final ButtonVariant variant;
  final ButtonSize size;

  /// Called when it is pressed. Null and not [submit] leaves it disabled.
  final VoidCallback? onPressed;

  /// Submits the form it is in.
  final bool submit;
  final bool disabled;

  /// As wide as its container.
  final bool expand;
  final bool autofocus;

  /// What a screen reader says, when the text alone does not say it.
  final String? semanticLabel;

  @override
  Component build(BuildContext context) => button(
    classes: [
      'ash-button',
      'ash-button-${variant.name}',
      'ash-button-${size.name}',
      if (expand) 'ash-button-expand',
    ].join(' '),
    type: submit ? ButtonType.submit : ButtonType.button,
    disabled: disabled || (onPressed == null && !submit),
    autofocus: autofocus,
    attributes: {'aria-label': ?semanticLabel},
    onClick: onPressed,
    [if (label != null) Component.text(label!), ...children],
  );

  @css
  static List<StyleRule> get styles => [
    css('.ash-button', [
      css('&').styles(
        raw: {
          'display': 'inline-flex',
          'align-items': 'center',
          'justify-content': 'center',
          'gap': '8px',
          'white-space': 'nowrap',
          'border': '1px solid transparent',
          'border-radius': 'var(--ash-radius-md)',
          'font': 'inherit',
          'font-size': '14px',
          'line-height': '20px',
          'font-weight': '500',
          'cursor': 'pointer',
          'outline': 'none',
          'transition': 'background-color 120ms, color 120ms, box-shadow 120ms',
        },
      ),
      css('&:focus-visible').styles(raw: {'box-shadow': 'var(--ash-focus)'}),
      css('&:disabled').styles(raw: {'opacity': '0.5', 'cursor': 'not-allowed'}),
    ]),
    css('.ash-button-expand').styles(raw: {'width': '100%'}),
    css('.ash-button-xs').styles(raw: {'min-height': '24px', 'padding': '0 8px', 'gap': '4px', 'font-size': '12px'}),
    css('.ash-button-sm').styles(raw: {'min-height': '32px', 'padding': '0 12px', 'gap': '6px'}),
    css('.ash-button-md').styles(raw: {'min-height': '36px', 'padding': '0 16px'}),
    css('.ash-button-lg').styles(raw: {'min-height': '40px', 'padding': '0 24px'}),
    css('.ash-button-primary', [
      css('&').styles(raw: {'background': 'var(--ash-primary)', 'color': 'var(--ash-primary-foreground)'}),
      css('&:hover:not(:disabled)').styles(
        raw: {'background': 'color-mix(in srgb, var(--ash-primary) 90%, transparent)'},
      ),
    ]),
    css('.ash-button-secondary', [
      css('&').styles(raw: {'background': 'var(--ash-secondary)', 'color': 'var(--ash-secondary-foreground)'}),
      css('&:hover:not(:disabled)').styles(
        raw: {'background': 'color-mix(in srgb, var(--ash-secondary) 80%, transparent)'},
      ),
    ]),
    css('.ash-button-destructive', [
      css('&').styles(
        raw: {'background': 'var(--ash-destructive)', 'color': 'var(--ash-destructive-foreground)'},
      ),
      css('&:hover:not(:disabled)').styles(
        raw: {'background': 'color-mix(in srgb, var(--ash-destructive) 90%, transparent)'},
      ),
    ]),
    css('.ash-button-outline', [
      css('&').styles(
        raw: {
          'background': 'var(--ash-background)',
          'color': 'var(--ash-foreground)',
          'border-color': 'var(--ash-input)',
        },
      ),
      css('&:hover:not(:disabled)').styles(
        raw: {'background': 'var(--ash-accent)', 'color': 'var(--ash-accent-foreground)'},
      ),
    ]),
    css('.ash-button-ghost', [
      css('&').styles(raw: {'background': 'transparent', 'color': 'var(--ash-foreground)'}),
      css('&:hover:not(:disabled)').styles(
        raw: {'background': 'var(--ash-accent)', 'color': 'var(--ash-accent-foreground)'},
      ),
    ]),
    css('.ash-button-link', [
      css('&').styles(
        raw: {
          'background': 'transparent',
          'color': 'var(--ash-primary)',
          'padding-left': '0',
          'padding-right': '0',
          'text-underline-offset': '4px',
        },
      ),
      css('&:hover:not(:disabled)').styles(raw: {'text-decoration': 'underline'}),
    ]),
  ];
}
