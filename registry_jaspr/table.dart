// Ashlar UI for Jaspr: DataTable. Copied into your app by `ashlar add table`; it is yours to change.

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// A column of a [DataTable]: its heading, and whether it holds numbers, which line up
/// on the right in figures of one width.
class TableColumn {
  const TableColumn(this.label, {this.numeric = false});

  final String label;
  final bool numeric;
}

/// Rows of data under headings, in a real <table>: read by screen readers, copied as a
/// table, and scrolled sideways when it is wider than its place.
///
/// ```dart
/// DataTable(
///   columns: [TableColumn('Patch'), TableColumn('Installs', numeric: true)],
///   rows: [for (final p in patches) [Component.text('#${p.number}'), Component.text('${p.installs}')]],
///   empty: 'No patches yet.',
/// )
/// ```
class DataTable extends StatelessComponent {
  const DataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.empty,
    this.caption,
  });

  final List<TableColumn> columns;

  /// One component per column in each row.
  final List<List<Component>> rows;

  /// Shown in place of the rows when there are none.
  final String? empty;

  /// What the table is, for screen readers.
  final String? caption;

  @override
  Component build(BuildContext context) {
    String? cellClass(int i) => columns[i].numeric ? 'ash-table-numeric' : null;
    return div(classes: 'ash-table-scroll', [
      table(classes: 'ash-table', [
        if (caption != null) Component.element(tag: 'caption', classes: 'ash-sr-only', children: [Component.text(caption!)]),
        thead([
          tr([
            for (var i = 0; i < columns.length; i++)
              th(classes: cellClass(i), attributes: {'scope': 'col'}, [Component.text(columns[i].label)]),
          ]),
        ]),
        tbody([
          if (rows.isEmpty && empty != null)
            tr([
              td(classes: 'ash-table-empty', attributes: {'colspan': '${columns.length}'}, [Component.text(empty!)]),
            ]),
          for (final row in rows)
            tr([for (var i = 0; i < row.length; i++) td(classes: cellClass(i), [row[i]])]),
        ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('.ash-table-scroll').styles(raw: {'width': '100%', 'overflow-x': 'auto'}),
    css('.ash-table', [
      css('&').styles(
        raw: {'width': '100%', 'border-collapse': 'collapse', 'font-size': '14px', 'line-height': '20px'},
      ),
      css('th').styles(
        raw: {
          'height': '40px',
          'padding': '0 8px',
          'text-align': 'left',
          'vertical-align': 'middle',
          'font-weight': '500',
          'white-space': 'nowrap',
          'color': 'var(--ash-foreground)',
          'border-bottom': '1px solid var(--ash-border)',
        },
      ),
      css('td').styles(
        raw: {'padding': '8px', 'vertical-align': 'middle', 'border-bottom': '1px solid var(--ash-border)'},
      ),
      css('tbody tr:last-child td').styles(raw: {'border-bottom': '0'}),
      css('tbody tr:hover td').styles(raw: {'background': 'color-mix(in srgb, var(--ash-muted) 50%, transparent)'}),
      css('.ash-table-numeric').styles(raw: {'text-align': 'right', 'font-variant-numeric': 'tabular-nums'}),
      css('.ash-table-empty').styles(
        raw: {'height': '96px', 'text-align': 'center', 'color': 'var(--ash-muted-foreground)'},
      ),
    ]),
  ];
}
