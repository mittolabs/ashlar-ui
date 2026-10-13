// Ashlar UI block: sidebar-09. Copied into your app by `ashlar add sidebar-09`; it is yours
// to change. Two sidebars side by side, as a mail app has them: a strip of folders that
// stays, and the folder's messages beside it, which fold away.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/avatar.dart';
import '../ui/breadcrumb.dart';
import '../ui/button.dart';
import '../ui/input.dart';
import '../ui/label.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/switch.dart';
import '../ui/theme.dart';
import '../ui/tooltip.dart';

/// Sample folders.
const _folders = [
  ('Inbox', AshlarIconsRoundedStroke.inbox),
  ('Drafts', AshlarIconsRoundedStroke.file),
  ('Sent', AshlarIconsRoundedStroke.send),
  ('Junk', AshlarIconsRoundedStroke.archive),
  ('Trash', AshlarIconsRoundedStroke.trash),
];

/// Sample messages: who from, when, the subject, the start of the text, and whether read.
const _mail = [
  (
    'Achieng Otieno',
    '09:34 AM',
    'Meeting tomorrow',
    'Can we move the review to ten? The figures from the field team came in late.',
    false,
  ),
  (
    'Kofi Mensah',
    'Yesterday',
    'Re: Project update',
    'Thanks for the update. The new screens look clean and the team is happy with them.',
    false,
  ),
  (
    'Amina Diallo',
    '2 days ago',
    'Weekend plans',
    'Hiking on Saturday if the weather holds. Bring water and a jacket.',
    true,
  ),
  (
    'Tendai Moyo',
    '2 days ago',
    'Question about the budget',
    'I went through the numbers again and think we can save on hosting.',
    true,
  ),
  (
    'Lerato Dlamini',
    '1 week ago',
    'Re: Conference talk',
    'The talk is accepted. Slides are due two weeks before the day.',
    true,
  ),
  (
    'Juma Mwangi',
    '1 week ago',
    'Invoice 2041',
    'Please find the invoice for September attached. Payment within 30 days.',
    true,
  ),
  (
    'Nia Okafor',
    '2 weeks ago',
    'Design review notes',
    'Notes from the session are in the shared folder. Most points are small.',
    true,
  ),
];

/// A strip of folders beside a list of the open folder's messages.
class Sidebar09 extends StatefulWidget {
  const Sidebar09({super.key});

  @override
  State<Sidebar09> createState() => _Sidebar09State();
}

class _Sidebar09State extends State<Sidebar09> {
  var _folder = 'Inbox';
  var _unread = false;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final mail = [
      for (final m in _mail)
        if (!_unread || !m.$5) m,
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The folders: always there, on a phone too.
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.sidebar,
            border: BorderDirectional(end: BorderSide(color: c.sidebarBorder)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c.sidebarPrimary,
                      borderRadius: BorderRadius.circular(t.radiusLg),
                    ),
                    child: AshlarIcon(
                      AshlarIconsRoundedStroke.command,
                      color: c.sidebarPrimaryForeground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final (name, icon) in _folders)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Tooltip(
                        message: name,
                        side: TooltipSide.right,
                        child: Button(
                          variant: name == _folder
                              ? ButtonVariant.secondary
                              : ButtonVariant.ghost,
                          size: ButtonSize.icon,
                          semanticLabel: name,
                          onPressed: () => setState(() => _folder = name),
                          child: AshlarIcon(icon),
                        ),
                      ),
                    ),
                  const Spacer(),
                  const Avatar(fallback: 'WK', semanticLabel: 'Wanjiru Kamau'),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: SidebarLayout(
            collapse: SidebarCollapse.offcanvas,
            width: 320,
            header: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _folder,
                        style: t.text.base.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Label(child: Text('Unreads')),
                    const SizedBox(width: 8),
                    Switch(
                      size: SwitchSize.sm,
                      value: _unread,
                      semanticLabel: 'Unread only',
                      onChanged: (v) => setState(() => _unread = v),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Input(
                  placeholder: 'Type to search…',
                  semanticLabel: 'Search mail',
                  leading: AshlarIcon(AshlarIconsRoundedStroke.search),
                ),
              ],
            ),
            groups: [
              SidebarGroup.custom(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, (from, sent, subject, text, _))
                        in mail.indexed) ...[
                      if (i > 0) const Separator(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    from,
                                    overflow: TextOverflow.ellipsis,
                                    style: t.text.sm.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(sent, style: t.text.xs),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subject,
                              style: t.text.sm.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: t.text.xs.copyWith(
                                color: c.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            child: _Page(trail: ['All Inboxes', _folder]),
          ),
        ),
      ],
    );
  }
}

/// The page beside the sidebar: the trigger and where you are along the top, and room
/// for your content under it.
class _Page extends StatelessWidget {
  const _Page({required this.trail});

  /// Where you are, from the top down; the last is this page.
  final List<String> trail;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const SidebarTrigger(),
              const SizedBox(width: 8),
              const SizedBox(height: 16, child: Separator(axis: Axis.vertical)),
              const SizedBox(width: 8),
              Expanded(
                child: Breadcrumb(
                  items: [
                    for (final (i, label) in trail.indexed)
                      BreadcrumbItem(
                        label,
                        onPressed: i == trail.length - 1 ? null : () {},
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const Separator(),
      const Expanded(child: _Placeholder()),
    ],
  );
}

/// Grey shapes where the page's content goes.
class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final box = BoxDecoration(
      color: t.colors.muted.withValues(alpha: .5),
      borderRadius: BorderRadius.circular(t.radiusXl),
    );
    return LayoutBuilder(
      builder: (context, size) => size.maxWidth >= 768
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) const SizedBox(width: 16),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: DecoratedBox(decoration: box),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SizedBox.expand(
                      child: DecoratedBox(decoration: box),
                    ),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (var i = 0; i < 3; i++) ...[
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: DecoratedBox(decoration: box),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(height: 480, child: DecoratedBox(decoration: box)),
              ],
            ),
    );
  }
}
