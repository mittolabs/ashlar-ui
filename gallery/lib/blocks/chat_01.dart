// Ashlar UI block: chat-01. Copied into your app by `ashlar add chat-01`; it is yours to
// change. An assistant's conversation: its thinking, the tools it used, its sources, and
// an answer that streams in.

import 'dart:async';

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/bubble.dart';
import '../ui/button.dart';
import '../ui/markdown.dart';
import '../ui/message.dart';
import '../ui/message_scroller.dart';
import '../ui/prompt_input.dart';
import '../ui/reasoning.dart';
import '../ui/shimmer.dart';
import '../ui/sources.dart';
import '../ui/theme.dart';
import '../ui/tool_call.dart';

/// One turn of the conversation.
class _Turn {
  _Turn.asked(this.text)
    : mine = true,
      done = true,
      tools = const [],
      sources = const [];
  _Turn.answer({
    this.text = '',
    this.done = false,
    this.thought,
    this.took,
    this.tools = const [],
    this.sources = const [],
  }) : mine = false;

  final bool mine;
  String text;
  bool done;
  String? thought;
  Duration? took;
  final List<ToolCall> tools;
  final List<Source> sources;
}

/// An assistant's conversation, from the first question to an answer streaming in, with a
/// prompt box under it.
///
/// Give [answer] your model: it is asked each question and gives back the answer's text a
/// piece at a time. Without it the block answers with a written example, so the screen
/// can be seen working before a model is wired in.
class Chat01 extends StatefulWidget {
  const Chat01({super.key, this.answer, this.onAttach, this.onOpenSource});

  /// Answers [question], as the pieces of text a model streams.
  final Stream<String> Function(String question)? answer;
  final VoidCallback? onAttach;
  final ValueChanged<Source>? onOpenSource;

  @override
  State<Chat01> createState() => _Chat01State();
}

class _Chat01State extends State<Chat01> {
  final _turns = <_Turn>[
    _Turn.asked('Which Westlands orders are late this week?'),
    _Turn.answer(
      done: true,
      thought: 'Late means past its promised time and not yet delivered. I need this week\'s Westlands orders, then compare each promised time with its delivery.',
      took: const Duration(seconds: 4),
      tools: const [
        ToolCall(
          title: 'Look up this week\'s orders',
          name: 'list_orders',
          input: '{"branch": "westlands", "from": "2026-10-19"}',
          output: '{"count": 38, "late": 3}',
        ),
      ],
      sources: const [
        Source(title: 'Orders, Westlands', detail: 'This week, 38 orders'),
        Source(title: 'Deliveries', detail: 'Riders\' check-ins'),
      ],
      text: """Three of this week's 38 orders are late:

| Order | Customer | Promised | Late by |
|---|---|---|---:|
| 1042 | Wanjiru K. | Tue 11:00 | 2 h |
| 1057 | Otieno M. | Wed 15:30 | 45 min |
| 1063 | Njeri W. | Thu 10:00 | 1 h 20 min |

All three went out with the same rider, and **1063** is still on the road. Want me to message the customers?""",
    ),
  ];
  StreamSubscription<String>? _streaming;
  DateTime? _started;

  bool get _busy => _streaming != null;

  void _ask(String question) {
    final answer = _Turn.answer();
    setState(() {
      _turns
        ..add(_Turn.asked(question))
        ..add(answer);
      _started = DateTime.now();
    });
    _streaming = (widget.answer ?? _example)(question).listen(
      (piece) => setState(() {
        answer.took ??= DateTime.now().difference(_started!);
        answer.text += piece;
      }),
      onDone: () => _finish(answer),
      onError: (Object _) {
        if (answer.text.isEmpty) {
          answer.text = 'Something went wrong. Try again.';
        }
        _finish(answer);
      },
    );
  }

  void _finish(_Turn answer) {
    _streaming?.cancel();
    if (mounted) {
      setState(() {
        answer.done = true;
        _streaming = null;
      });
    }
  }

  @override
  void dispose() {
    _streaming?.cancel();
    super.dispose();
  }

  /// A written answer, a word at a time, for before a model is wired in.
  Stream<String> _example(String question) async* {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    const text =
        'This is a written example, not a model. Pass `answer` to **Chat01** and each question goes to your model, its answer streaming in here as it does now.';
    for (final word in text.split(' ')) {
      await Future<void>.delayed(const Duration(milliseconds: 45));
      yield '$word ';
    }
  }

  Widget _answer(_Turn turn) {
    final t = AshlarTheme.of(context);
    final waiting = !turn.done && turn.text.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (turn.thought != null) ...[
          Reasoning(
            thinking: !turn.done && turn.text.isEmpty,
            took: turn.took,
            child: Text(turn.thought!),
          ),
          const SizedBox(height: 10),
        ],
        for (final tool in turn.tools) ...[tool, const SizedBox(height: 10)],
        if (waiting)
          Shimmer(child: Text('Thinking…', style: t.text.sm))
        else
          Markdown(turn.text.trimRight(), streaming: !turn.done),
        if (turn.sources.isNotEmpty && turn.done) ...[
          const SizedBox(height: 12),
          Sources(sources: turn.sources, onOpen: widget.onOpenSource),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    Widget column(Widget child) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: child,
      ),
    );
    return ColoredBox(
      color: c.background,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.border)),
            ),
            child: Row(
              children: [
                AshlarIcon(
                  AshlarIconsRoundedStroke.sparkles,
                  size: 18,
                  color: c.foreground,
                ),
                const SizedBox(width: 8),
                Text(
                  'Assistant',
                  style: t.text.sm.copyWith(
                    color: c.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Orders and deliveries',
                    style: t.text.sm.copyWith(color: c.mutedForeground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: MessageScroller(
              busy: _busy,
              gap: 24,
              items: [
                for (final (i, turn) in _turns.indexed)
                  MessageScrollerItem(
                    id: i,
                    anchor: turn.mine,
                    child: column(
                      turn.mine
                          ? Message(
                              align: MessageAlign.end,
                              child: Bubble(
                                variant: BubbleVariant.muted,
                                child: Text(turn.text),
                              ),
                            )
                          : _answer(turn),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: column(
              PromptInput(
                busy: _busy,
                onSubmit: _ask,
                onStop: () {
                  final last = _turns.last;
                  _finish(last);
                },
                placeholder: 'Ask about orders and deliveries',
                actions: [
                  Button(
                    variant: ButtonVariant.ghost,
                    size: ButtonSize.icon,
                    semanticLabel: 'Attach a file',
                    onPressed: widget.onAttach,
                    child: const AshlarIcon(AshlarIconsRoundedStroke.paperclip),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
