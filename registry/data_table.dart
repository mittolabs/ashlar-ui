// Ashlar UI: Data Table. Copied into your app by `ashlar add data-table`; it is yours to
// change. (Flutter's widgets layer has a Table for layout; this one is for data.)

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// A column of a [DataTable]: its heading, its share of the width, and how its cells line
/// up (numbers to the end).
@immutable
class DataColumn {
  const DataColumn(this.label, {this.flex = 1, this.numeric = false});

  final Widget label;
  final int flex;
  final bool numeric;
}

/// Rows of data under column headings, with a line between rows, the row under the
/// pointer lit, an optional footer row (totals) and a caption.
///
/// ```dart
/// DataTable(
///   columns: [DataColumn(Text('Invoice')), DataColumn(Text('Status')), DataColumn(Text('Amount'), numeric: true)],
///   rows: [
///     [Text('INV001'), Text('Paid'), Text('KES 2,500')],
///     [Text('INV002'), Text('Pending'), Text('KES 1,500')],
///   ],
///   footer: [Text('Total'), SizedBox(), Text('KES 4,000')],
///   caption: Text('Your recent invoices.'),
/// )
/// ```
class DataTable extends StatelessWidget {
  const DataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.footer,
    this.caption,
    this.onRowPressed,
  });

  final List<DataColumn> columns;

  /// One widget per column in each row.
  final List<List<Widget>> rows;
  final List<Widget>? footer;
  final Widget? caption;

  /// Makes each row a button.
  final ValueChanged<int>? onRowPressed;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    Widget line(
      List<Widget> cells, {
      required TextStyle style,
      double height = 40,
    }) => Row(
      children: [
        for (final (i, col) in columns.indexed)
          Expanded(
            flex: col.flex,
            child: Container(
              constraints: BoxConstraints(minHeight: height),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              alignment: col.numeric
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: DefaultTextStyle.merge(
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: col.numeric ? TextAlign.end : TextAlign.start,
                child: i < cells.length ? cells[i] : const SizedBox(),
              ),
            ),
          ),
      ],
    );
    final border = BorderSide(color: c.border);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(border: Border(bottom: border)),
          child: line(
            [
              for (final col in columns)
                Semantics(header: true, child: col.label),
            ],
            style: t.text.sm.copyWith(
              color: c.foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        for (final (i, row) in rows.indexed)
          _Row(
            last: i == rows.length - 1 && footer == null,
            onPressed: onRowPressed == null ? null : () => onRowPressed!(i),
            child: line(row, style: t.text.sm.copyWith(color: c.foreground)),
          ),
        if (footer != null)
          DecoratedBox(
            decoration: BoxDecoration(
              color: c.muted.withValues(alpha: c.muted.a * .5),
              border: Border(top: border),
            ),
            child: line(
              footer!,
              style: t.text.sm.copyWith(
                color: c.foreground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: DefaultTextStyle.merge(
              style: t.text.sm.copyWith(color: c.mutedForeground),
              textAlign: TextAlign.center,
              child: caption!,
            ),
          ),
      ],
    );
  }
}

class _Row extends StatefulWidget {
  const _Row({required this.child, required this.last, this.onPressed});

  final Widget child;
  final bool last;
  final VoidCallback? onPressed;

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    Widget row = MouseRegion(
      cursor: widget.onPressed == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: t.duration,
        decoration: BoxDecoration(
          color: _hovered
              ? c.muted.withValues(alpha: c.muted.a * .5)
              : const Color(0x00000000),
          border: Border(
            bottom: BorderSide(
              color: widget.last ? const Color(0x00000000) : c.border,
            ),
          ),
        ),
        child: widget.child,
      ),
    );
    if (widget.onPressed != null) {
      row = Semantics(
        button: true,
        onTap: widget.onPressed,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: row,
        ),
      );
    }
    return MergeSemantics(child: row);
  }
}
