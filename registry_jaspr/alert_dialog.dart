// Ashlar UI for Jaspr: AlertDialog. Copied into your app by `ashlar add alert_dialog`; it is yours to change.

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import 'button.dart';

/// Asks before something that cannot be taken back. The browser's own modal dialog:
/// focus stays inside it, the page behind cannot be used, and Escape cancels.
///
/// Focus starts on Cancel, so Enter alone never confirms.
///
/// ```dart
/// AlertDialog(
///   open: confirming,
///   title: 'Roll back patch 2?',
///   description: 'Devices stop being offered it.',
///   confirmLabel: 'Roll back',
///   destructive: true,
///   onConfirm: rollBack,
///   onCancel: () => setState(() => confirming = false),
/// )
/// ```
class AlertDialog extends StatefulComponent {
  const AlertDialog({
    super.key,
    required this.open,
    required this.title,
    this.description,
    this.confirmLabel = 'Continue',
    this.cancelLabel = 'Cancel',
    this.destructive = false,
    this.busy = false,
    required this.onConfirm,
    required this.onCancel,
  });

  final bool open;
  final String title;
  final String? description;
  final String confirmLabel;
  final String cancelLabel;

  /// The confirm button is destructive: it deletes or cannot be undone.
  final bool destructive;

  /// While the action runs: both buttons are disabled.
  final bool busy;
  final VoidCallback onConfirm;

  /// Cancel, Escape, or a click outside it.
  final VoidCallback onCancel;

  @override
  State<AlertDialog> createState() => _AlertDialogState();

  @css
  static List<StyleRule> get styles => [
    css('.ash-dialog', [
      css('&').styles(
        raw: {
          'width': 'calc(100% - 32px)',
          'max-width': '512px',
          'padding': '0',
          'border': '1px solid var(--ash-border)',
          'border-radius': 'var(--ash-radius-lg)',
          'background': 'var(--ash-background)',
          'color': 'var(--ash-foreground)',
          'box-shadow': 'var(--ash-shadow-lg)',
        },
      ),
      css('&::backdrop').styles(raw: {'background': 'var(--ash-overlay)'}),
    ]),
    css('.ash-dialog-body').styles(raw: {'display': 'grid', 'gap': '8px', 'padding': '24px'}),
    css('.ash-dialog-title').styles(raw: {'margin': '0', 'font-size': '18px', 'line-height': '28px', 'font-weight': '600'}),
    css('.ash-dialog-description').styles(
      raw: {'margin': '0', 'font-size': '14px', 'line-height': '20px', 'color': 'var(--ash-muted-foreground)'},
    ),
    css('.ash-dialog-actions').styles(
      raw: {'display': 'flex', 'flex-wrap': 'wrap-reverse', 'justify-content': 'flex-end', 'gap': '8px', 'margin-top': '8px'},
    ),
  ];
}

class _AlertDialogState extends State<AlertDialog> {
  final _dialog = GlobalNodeKey<web.HTMLDialogElement>();
  static var _ids = 0;
  final _id = 'ash-dialog-${_ids++}';

  /// Whether the browser has it open as a modal. The `open` attribute is rendered
  /// from this, so a rebuild never takes away what showModal set: a modal dialog
  /// that loses its attribute that way stays modal, and the page behind stays dead.
  var _shown = false;

  @override
  void initState() {
    super.initState();
    // Open from the start: shown once it is on the page.
    if (component.open && kIsWeb) {
      context.binding.addPostFrameCallback(() {
        if (component.open && !_shown) setState(_show);
      });
    }
  }

  @override
  void didUpdateComponent(AlertDialog oldComponent) {
    super.didUpdateComponent(oldComponent);
    // Before the rebuild, so the attribute it renders already agrees.
    if (component.open && !_shown) {
      _show();
    } else if (!component.open && _shown) {
      _dialog.currentNode?.close();
      _shown = false;
    }
  }

  void _show() {
    final node = _dialog.currentNode;
    if (node == null) return;
    // showModal moves focus to the autofocus button: Cancel.
    node.showModal();
    _shown = true;
  }

  @override
  Component build(BuildContext context) => dialog(
    key: _dialog,
    open: _shown,
    classes: 'ash-dialog',
    attributes: {
      'role': 'alertdialog',
      'aria-labelledby': '$_id-title',
      if (component.description != null) 'aria-describedby': '$_id-description',
    },
    events: {
      // Escape: the parent decides whether it closes.
      'cancel': (event) {
        event.preventDefault();
        if (!component.busy) component.onCancel();
      },
      // A click on the backdrop lands on the dialog itself, not its content.
      'click': (event) {
        if (event.target == _dialog.currentNode && !component.busy) component.onCancel();
      },
    },
    [
      div(classes: 'ash-dialog-body', [
        h2(id: '$_id-title', classes: 'ash-dialog-title', [Component.text(component.title)]),
        if (component.description != null)
          p(id: '$_id-description', classes: 'ash-dialog-description', [Component.text(component.description!)]),
        div(classes: 'ash-dialog-actions', [
          Button(
            label: component.cancelLabel,
            variant: ButtonVariant.outline,
            disabled: component.busy,
            autofocus: true,
            onPressed: component.onCancel,
          ),
          Button(
            label: component.confirmLabel,
            variant: component.destructive ? ButtonVariant.destructive : ButtonVariant.primary,
            disabled: component.busy,
            onPressed: component.onConfirm,
          ),
        ]),
      ]),
    ],
  );
}
