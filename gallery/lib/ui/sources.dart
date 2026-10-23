// Ashlar UI: Sources. Copied into your app by `ashlar add sources`; it is yours to change.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'collapsible.dart';
import 'pressable.dart';
import 'theme.dart';

/// One thing an answer rests on: a page, a document, a row in your data.
class Source {
  const Source({required this.title, this.detail, this.url});

  /// What it is called: a page's title, a file's name.
  final String title;

  /// Where it is from, under the title: a site, a folder, a date. Taken from [url] when
  /// not given.
  final String? detail;

  /// Its address, given back to [Sources.onOpen].
  final String? url;

  String? get _from =>
      detail ??
      (url == null ? null : Uri.tryParse(url!)?.host.replaceFirst('www.', ''));
}

/// What an answer rests on, folded under a line that counts them ("Used 4 sources"), each
/// numbered as the answer cites it. [Citation] draws that number in the answer's text.
///
/// ```dart
/// Sources(
///   sources: [Source(title: 'Returns policy', url: 'https://shop.example.com/returns')],
///   onOpen: (source) => launch(source.url!),
/// )
/// ```
class Sources extends StatelessWidget {
  const Sources({
    super.key,
    required this.sources,
    this.onOpen,
    this.initiallyOpen = false,
  });

  final List<Source> sources;

  /// Called with the source tapped; they are not tappable without it.
  final ValueChanged<Source>? onOpen;
  final bool initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final count = sources.length == 1
        ? 'Used 1 source'
        : 'Used ${sources.length} sources';
    return Collapsible(
      initiallyOpen: initiallyOpen,
      builder: (context, open, toggle) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Pressable(
          onPressed: toggle,
          expanded: open,
          semanticLabel: count,
          builder: (context, state) {
            final ink = state.hovered || state.focused
                ? c.foreground
                : c.mutedForeground;
            return AnimatedContainer(
              duration: t.duration,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(t.radiusSm),
                border: Border.all(
                  color: state.focused ? c.ring : c.ring.withValues(alpha: 0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AshlarIcon(
                    AshlarIconsRoundedStroke.bookOpen,
                    size: 16,
                    color: ink,
                  ),
                  const SizedBox(width: 6),
                  Text(count, style: t.text.sm.copyWith(color: ink)),
                  const SizedBox(width: 2),
                  AnimatedRotation(
                    turns: open ? 0 : -.25,
                    duration: t.duration,
                    child: AshlarIcon(
                      AshlarIconsRoundedStroke.chevronDown,
                      size: 16,
                      color: ink,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, s) in sources.indexed)
              Pressable(
                onPressed: onOpen == null ? null : () => onOpen!(s),
                link: s.url != null,
                semanticLabel:
                    '${i + 1}. ${s.title}${s._from == null ? '' : ', ${s._from}'}',
                builder: (context, state) => AnimatedContainer(
                  duration: t.duration,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: state.hovered && onOpen != null
                        ? c.accent
                        : c.accent.withValues(alpha: 0),
                    borderRadius: BorderRadius.circular(t.radiusMd),
                    border: Border.all(
                      color: state.focused
                          ? c.ring
                          : c.ring.withValues(alpha: 0),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: _Number(i + 1),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.text.sm.copyWith(
                                color: c.foreground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (s._from case final from?)
                              Text(
                                from,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: t.text.xs.copyWith(
                                  color: c.mutedForeground,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The number of a source, in a small rounded square.
class _Number extends StatelessWidget {
  const _Number(this.n, {this.hovered = false});

  final int n;
  final bool hovered;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return Container(
      // At least a small square, and taller when the text is made larger.
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: hovered ? c.primary : c.muted,
        borderRadius: BorderRadius.circular(t.radiusSm),
      ),
      // As wide as its number, so it sits in a line of text.
      child: Center(
        widthFactor: 1,
        child: Text(
          '$n',
          style: t.text.xs.copyWith(
            color: hovered ? c.primaryForeground : c.mutedForeground,
            fontWeight: FontWeight.w600,
            fontSize: 11,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// A source's number in an answer's text, as `[2]` is written: tap it to open the source.
///
/// ```dart
/// Text.rich(TextSpan(children: [TextSpan(text: 'Returns take 14 days '), WidgetSpan(child: Citation(1, onPressed: open))]))
/// ```
class Citation extends StatelessWidget {
  const Citation(this.number, {super.key, this.onPressed, this.title});

  final int number;
  final VoidCallback? onPressed;

  /// What it cites, for a screen reader: "Source 1, Returns policy".
  final String? title;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    // In a sentence, a finger-sized press area would push the lines apart; a link inside
    // text is exempt from that minimum, as on the web.
    return AshlarTheme(
      data: t.copyWith(tapTarget: 0),
      child: Pressable(
        onPressed: onPressed,
        link: true,
        semanticLabel: 'Source $number${title == null ? '' : ', $title'}',
        builder: (context, state) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: state.focused ? c.ring : c.ring.withValues(alpha: 0),
            ),
          ),
          child: _Number(number, hovered: state.hovered),
        ),
      ),
    );
  }
}
