// Ashlar UI: Empty. Copied into your app by `ashlar add empty`; it is yours to change.

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// What a list or a page shows when there is nothing in it yet, and what to do about it.
///
/// ```dart
/// Empty(
///   icon: AshlarIcon(AshlarIconsRoundedStroke.folder),
///   title: Text('No projects yet'),
///   description: Text('Create a project to get started.'),
///   actions: [Button(onPressed: create, child: Text('Create project'))],
/// )
/// ```
class Empty extends StatelessWidget {
  const Empty({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.actions = const [],
  });

  /// Drawn in a small muted square above the title.
  final Widget? icon;
  final Widget title;
  final Widget? description;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.muted,
                borderRadius: BorderRadius.circular(t.radiusLg),
              ),
              child: IconTheme.merge(
                data: IconThemeData(color: c.foreground, size: 24),
                child: icon!,
              ),
            ),
            const SizedBox(height: 16),
          ],
          DefaultTextStyle.merge(
            style: t.text.lg.copyWith(
              color: c.foreground,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            child: Semantics(header: true, child: title),
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            DefaultTextStyle.merge(
              style: t.text.sm.copyWith(
                color: c.mutedForeground,
                height: 22 / 14,
              ),
              textAlign: TextAlign.center,
              child: description!,
            ),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}
