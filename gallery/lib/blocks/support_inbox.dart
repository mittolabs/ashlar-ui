// Ashlar UI block: support-inbox. Copied into your app by `ashlar add support-inbox`; it is
// yours to change. A support desk with two sidebars side by side: a strip of queues that
// stays, the queue's tickets beside it, which fold away, and the open ticket's
// conversation with a reply box on the page.
//
// The company, its customers and their tickets are sample data, there to be replaced.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/avatar.dart';
import '../ui/badge.dart';
import '../ui/button.dart';
import '../ui/input.dart';
import '../ui/label.dart';
import '../ui/pressable.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/switch.dart';
import '../ui/textarea.dart';
import '../ui/theme.dart';
import '../ui/tooltip.dart';

/// The desk's queues.
const _queues = [
  ('Open', AshlarIconsRoundedStroke.inbox),
  ('Mine', AshlarIconsRoundedStroke.user),
  ('Waiting on the customer', AshlarIconsRoundedStroke.hourglass),
  ('Solved', AshlarIconsRoundedStroke.circleCheck),
];

/// Tickets: who from, when, about what, the start of the message, whether answered, and
/// the order it is about.
const _tickets = [
  (
    'Achieng Otieno',
    '9:34',
    'Parcel shows delivered, not here',
    'The app says it was left at the gate at 8:50 but there is nothing here and the guard saw no driver.',
    false,
    'SWP-48213',
  ),
  (
    'Daniel Kim',
    '9:10',
    'Driver asked me to pay again',
    'I paid by card when I ordered and the driver asked for cash at the door.',
    false,
    'SWP-48197',
  ),
  (
    'Fatuma Hassan',
    'Yesterday',
    'Change my delivery address',
    'I have moved across town. Can tomorrow\'s delivery go to the new address?',
    true,
    'SWP-48102',
  ),
  (
    'Tom Becker',
    'Yesterday',
    'Refund not received',
    'You said the refund would be back in three days. It has been five.',
    true,
    'SWP-47988',
  ),
  (
    'Ana Souza',
    'Monday',
    'Thank you',
    'The driver called ahead and waited while I came down. Please pass it on.',
    true,
    'SWP-47901',
  ),
];

/// A strip of queues beside the queue's tickets, and the open ticket on the page.
class SupportInbox extends StatefulWidget {
  const SupportInbox({super.key});

  @override
  State<SupportInbox> createState() => _SupportInboxState();
}

class _SupportInboxState extends State<SupportInbox> {
  var _queue = 'Open';
  var _unanswered = false;
  var _open = 0;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final tickets = [
      for (final (i, ticket) in _tickets.indexed)
        if (!_unanswered || !ticket.$5) (i, ticket),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The queues: always there, on a phone too.
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
                      AshlarIconsRoundedStroke.packageCheck,
                      color: c.sidebarPrimaryForeground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final (name, icon) in _queues)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Tooltip(
                        message: name,
                        side: TooltipSide.right,
                        child: Button(
                          variant: name == _queue
                              ? ButtonVariant.secondary
                              : ButtonVariant.ghost,
                          size: ButtonSize.icon,
                          semanticLabel: name,
                          onPressed: () => setState(() => _queue = name),
                          child: AshlarIcon(icon),
                        ),
                      ),
                    ),
                  const Spacer(),
                  const Avatar(fallback: 'MT', semanticLabel: 'Mei Tanaka'),
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
                        _queue,
                        overflow: TextOverflow.ellipsis,
                        style: t.text.base.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Label(child: Text('Unanswered')),
                    const SizedBox(width: 8),
                    Switch(
                      size: SwitchSize.sm,
                      value: _unanswered,
                      semanticLabel: 'Unanswered only',
                      onChanged: (v) => setState(() => _unanswered = v),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Input(
                  placeholder: 'Search by name or order…',
                  semanticLabel: 'Search tickets',
                  leading: AshlarIcon(AshlarIconsRoundedStroke.search),
                ),
              ],
            ),
            groups: [
              SidebarGroup.custom(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (
                          k,
                          (i, (from, sent, subject, text, answered, _)),
                        )
                        in tickets.indexed) ...[
                      if (k > 0) const Separator(),
                      Pressable(
                        onPressed: () => setState(() => _open = i),
                        selected: i == _open,
                        semanticLabel: '$from: $subject',
                        builder: (context, state) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: i == _open || state.hovered
                                ? c.sidebarAccent
                                : null,
                            borderRadius: BorderRadius.circular(t.radiusMd),
                          ),
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
                                        fontWeight: answered
                                            ? FontWeight.w500
                                            : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  // Waiting on a reply: a dot by the time, so
                                  // every name starts in the same place.
                                  if (!answered) ...[
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: c.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
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
                      ),
                    ],
                  ],
                ),
              ),
            ],
            child: _Ticket(index: _open),
          ),
        ),
      ],
    );
  }
}

/// The open ticket: who it is and the order, the conversation, and a reply.
class _Ticket extends StatelessWidget {
  const _Ticket({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final (from, sent, subject, text, _, order) = _tickets[index];
    Widget message(String who, String body, String at, {required bool ours}) =>
        Align(
          alignment: ours
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ours ? c.primary : c.muted,
                borderRadius: BorderRadius.circular(t.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    body,
                    style: t.text.sm.copyWith(
                      color: ours ? c.primaryForeground : c.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$who  ·  $at',
                    style: t.text.xs.copyWith(
                      color: (ours ? c.primaryForeground : c.mutedForeground)
                          .withValues(alpha: .8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    return Column(
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
                const SizedBox(
                  height: 16,
                  child: Separator(axis: Axis.vertical),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subject,
                        overflow: TextOverflow.ellipsis,
                        style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '$from  ·  order $order',
                        overflow: TextOverflow.ellipsis,
                        style: t.text.xs.copyWith(color: c.mutedForeground),
                      ),
                    ],
                  ),
                ),
                const Badge(
                  variant: BadgeVariant.outline,
                  child: Text('Delivery'),
                ),
              ],
            ),
          ),
        ),
        const Separator(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              message(from, text, sent, ours: false),
              if (index == 0) ...[
                message(
                  'Mei, Swift Parcel support',
                  'Sorry about this. I have called the driver and asked where exactly he '
                      'left it. Give me ten minutes.',
                  '9:41',
                  ours: true,
                ),
                message(
                  from,
                  'Okay, thank you. I am home all morning.',
                  '9:43',
                  ours: false,
                ),
              ],
            ],
          ),
        ),
        const Separator(),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Textarea(
                  placeholder: 'Write a reply…',
                  semanticLabel: 'Reply',
                  minLines: 1,
                  maxLines: 4,
                ),
              ),
              const SizedBox(width: 8),
              Button(
                leading: const AshlarIcon(AshlarIconsRoundedStroke.send),
                onPressed: () {},
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
