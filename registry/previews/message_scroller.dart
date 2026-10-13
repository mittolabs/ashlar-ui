// The message-scroller picture ashlar update --preview draws, from the site's demo.
import 'dart:async';

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/bubble.dart';
import 'package:ashlar_ui_gallery/ui/button.dart';
import 'package:ashlar_ui_gallery/ui/input.dart';
import 'package:ashlar_ui_gallery/ui/marker.dart';
import 'package:ashlar_ui_gallery/ui/message.dart';
import 'package:ashlar_ui_gallery/ui/message_scroller.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class MessageScrollerDemo extends StatefulWidget {
  const MessageScrollerDemo({super.key});

  @override
  State<MessageScrollerDemo> createState() => _MessageScrollerDemoState();
}

class _MessageScrollerDemoState extends State<MessageScrollerDemo> {
  // Each turn: what was asked, and the answer so far.
  final _turns = <(String, String)>[
    (
      'What does Ashlar UI build on?',
      'Flutter\'s widgets layer alone: no Material, no Cupertino. Each component is a file in your app, yours to change.',
    ),
    (
      'How do I add one?',
      'Run ashlar add and the name, say ashlar add dialog. It copies the file and anything it needs.',
    ),
    ('Can it scroll a chat?', 'This is one. Ask something and watch where your question lands.'),
  ];
  final _input = TextEditingController();
  Timer? _stream;

  static const _answer =
      'A new question rises near the top, with room below for the answer to '
      'grow into. While you stay at the end, it follows the answer as it '
      'streams. Scroll up to read, and it leaves you there; the button '
      'brings you back to the latest.';

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty || _stream != null) return;
    _input.clear();
    setState(() => _turns.add((text, '')));
    final words = _answer.split(' ');
    var n = 0;
    _stream = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      n++;
      setState(() {
        _turns.last = (_turns.last.$1, words.take(n).join(' '));
        if (n >= words.length) {
          timer.cancel();
          _stream = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _stream?.cancel();
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return Container(
      width: 440,
      height: 480,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(t.radiusXl),
        border: Border.all(color: t.colors.border),
      ),
      child: Column(
        children: [
          Expanded(
            child: MessageScroller(
              busy: _stream != null,
              items: [
                const MessageScrollerItem(
                  id: 'today',
                  child: Marker(
                    variant: MarkerVariant.separator,
                    child: Text('Today'),
                  ),
                ),
                for (final (i, (asked, answer)) in _turns.indexed) ...[
                  MessageScrollerItem(
                    id: 'q$i',
                    anchor: true,
                    child: Message(
                      align: MessageAlign.end,
                      child: Bubble(child: Text(asked)),
                    ),
                  ),
                  MessageScrollerItem(
                    id: 'a$i',
                    child: Message(
                      child: answer.isEmpty
                          ? const Marker(child: Text('Thinking…'))
                          : Bubble(
                              variant: BubbleVariant.ghost,
                              child: Text(answer),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Input(
                    controller: _input,
                    placeholder: 'Ask something…',
                    semanticLabel: 'Message',
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                Button(
                  size: ButtonSize.icon,
                  semanticLabel: 'Send',
                  onPressed: _send,
                  child: const AshlarIcon(AshlarIconsRoundedStroke.arrowUp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
