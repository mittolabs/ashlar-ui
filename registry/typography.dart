// Ashlar UI: Typography. Copied into your app by `ashlar add typography`; it is yours to
// change.

import 'package:flutter/widgets.dart';

import 'theme.dart';

TextStyle _style(
  BuildContext context,
  TextStyle Function(AshlarText t) size, {
  FontWeight? weight,
  double? spacing,
  Color? color,
}) {
  final t = AshlarTheme.of(context);
  return size(t.text).copyWith(
    color: color ?? t.colors.foreground,
    fontWeight: weight,
    letterSpacing: spacing,
  );
}

Widget _heading(BuildContext context, String text, TextStyle style) =>
    Semantics(header: true, child: Text(text, style: style));

/// The page's title: 36, bold.
class H1 extends StatelessWidget {
  const H1(this.text, {super.key});

  /// The words.
  final String text;

  @override
  Widget build(BuildContext context) => _heading(
    context,
    text,
    _style(
      context,
      (t) => t.xxl,
      weight: FontWeight.w800,
      spacing: -.9,
    ).copyWith(fontSize: 36, height: 40 / 36),
  );
}

/// A section: 30, semibold.
class H2 extends StatelessWidget {
  const H2(this.text, {super.key});

  /// The words.
  final String text;

  @override
  Widget build(BuildContext context) => _heading(
    context,
    text,
    _style(
      context,
      (t) => t.xxl,
      weight: FontWeight.w600,
      spacing: -.75,
    ).copyWith(fontSize: 30, height: 36 / 30),
  );
}

/// A part of a section: 24, semibold.
class H3 extends StatelessWidget {
  const H3(this.text, {super.key});

  /// The words.
  final String text;

  @override
  Widget build(BuildContext context) => _heading(
    context,
    text,
    _style(context, (t) => t.xxl, weight: FontWeight.w600, spacing: -.6),
  );
}

/// A small heading: 20, semibold.
class H4 extends StatelessWidget {
  const H4(this.text, {super.key});

  /// The words.
  final String text;

  @override
  Widget build(BuildContext context) => _heading(
    context,
    text,
    _style(context, (t) => t.xl, weight: FontWeight.w600, spacing: -.5),
  );
}

/// A paragraph of reading text: 16, with room between lines.
class P extends StatelessWidget {
  const P(this.text, {super.key});

  /// The words.
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: _style(context, (t) => t.base).copyWith(height: 28 / 16),
  );
}

/// The opening paragraph, larger and quieter: 20, muted.
class Lead extends StatelessWidget {
  const Lead(this.text, {super.key});

  /// The words.
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: _style(
      context,
      (t) => t.xl,
      color: AshlarTheme.of(context).colors.mutedForeground,
    ),
  );
}

/// Text that stands out a little: 18, semibold.
class Large extends StatelessWidget {
  const Large(this.text, {super.key});

  /// The words.
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: _style(context, (t) => t.lg, weight: FontWeight.w600));
}

/// A small note: 14, medium.
class Small extends StatelessWidget {
  const Small(this.text, {super.key});

  /// The words.
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: _style(context, (t) => t.sm, weight: FontWeight.w500));
}

/// Text that recedes: 14, muted.
class Muted extends StatelessWidget {
  const Muted(this.text, {super.key});

  /// The words.
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: _style(
      context,
      (t) => t.sm,
      color: AshlarTheme.of(context).colors.mutedForeground,
    ),
  );
}

/// A quotation, set in from a line at its left.
class Blockquote extends StatelessWidget {
  const Blockquote(this.text, {super.key});

  /// The words.
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.only(start: 24),
    decoration: BoxDecoration(
      border: BorderDirectional(
        start: BorderSide(
          color: AshlarTheme.of(context).colors.border,
          width: 2,
        ),
      ),
    ),
    child: Text(
      text,
      style: _style(
        context,
        (t) => t.base,
      ).copyWith(fontStyle: FontStyle.italic, height: 28 / 16),
    ),
  );
}

/// A word of code inside a sentence.
class InlineCode extends StatelessWidget {
  const InlineCode(this.text, {super.key});

  /// The words.
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: t.colors.muted,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: t.text.sm.copyWith(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
          color: t.colors.foreground,
        ),
      ),
    );
  }
}

/// A bulleted list.
class BulletList extends StatelessWidget {
  const BulletList(this.items, {super.key});

  /// The points, in order.
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final style = _style(context, (t) => t.base);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 24, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(child: Text('•  ', style: style)),
                Expanded(child: Text(item, style: style)),
              ],
            ),
          ),
      ],
    );
  }
}

/// A small table in running text: headings and rows of plain words, lined and banded.
class TypographyTable extends StatelessWidget {
  const TypographyTable({
    super.key,
    required this.headings,
    required this.rows,
  });

  /// The column headings.
  final List<String> headings;

  /// The rows, each a list of cells.
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final line = BorderSide(color: c.border);
    TableRow row(
      List<String> cells, {
      bool head = false,
      bool band = false,
    }) => TableRow(
      decoration: BoxDecoration(color: band ? c.muted : null),
      children: [
        for (final cell in cells)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(left: line, right: line, top: line, bottom: line),
            ),
            child: Semantics(
              header: head,
              child: Text(
                cell,
                style: t.text.base.copyWith(
                  color: c.foreground,
                  fontWeight: head ? FontWeight.w700 : null,
                ),
              ),
            ),
          ),
      ],
    );
    return Table(
      children: [
        row(headings, head: true),
        for (final (i, r) in rows.indexed) row(r, band: i.isOdd),
      ],
    );
  }
}
