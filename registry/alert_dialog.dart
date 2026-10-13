// Ashlar UI: Alert Dialog. Copied into your app by `ashlar add alert-dialog`; it is yours to
// change.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'button.dart';
import 'dialog.dart';

/// Asks a question that needs an answer before going on: deleting, leaving with unsaved
/// work. Unlike a Dialog it has no close button and a tap outside does nothing; Escape
/// counts as [cancel]. Returns true for [action], false for anything else.
///
/// ```dart
/// if (await showAlertDialog(context, title: 'Delete the project?', description: 'This cannot be undone.', action: 'Delete', destructive: true)) {
///   delete();
/// }
/// ```
Future<bool> showAlertDialog(
  BuildContext context, {
  required String title,
  String? description,
  String cancel = 'Cancel',
  String action = 'Continue',
  bool destructive = false,
}) async =>
    await showAshlarDialog<bool>(
      context: context,
      dismissible: false,
      builder: (context) => AlertDialog(
        title: title,
        description: description,
        cancel: cancel,
        action: action,
        destructive: destructive,
      ),
    ) ??
    false;

/// The panel [showAlertDialog] shows.
class AlertDialog extends StatelessWidget {
  const AlertDialog({
    super.key,
    required this.title,
    this.description,
    this.cancel = 'Cancel',
    this.action = 'Continue',
    this.destructive = false,
  });

  final String title;
  final String? description;
  final String cancel, action;
  final bool destructive;

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.escape): () =>
          Navigator.pop(context, false),
    },
    child: Focus(
      autofocus: true,
      child: Dialog(
        showClose: false,
        title: Text(title),
        description: description == null ? null : Text(description!),
        actions: [
          Button(
            variant: ButtonVariant.outline,
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancel),
          ),
          Button(
            variant: destructive
                ? ButtonVariant.destructive
                : ButtonVariant.primary,
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ),
  );
}
