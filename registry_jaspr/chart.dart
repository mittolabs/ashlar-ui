// Ashlar UI for Jaspr: BarChart. Copied into your app by `ashlar add chart`; it is yours to change.

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'table.dart';

/// One bar of a [BarChart]: what it is called, and its value.
class BarPoint {
  const BarPoint(this.label, this.value);

  final String label;
  final num value;
}

/// One series as bars on a baseline: counts over time, or across a few named things.
///
/// Hovering or focusing a bar says its label and value, and the same numbers are one
/// click away as a table. With nothing above zero it says [emptyText] instead of
/// drawing an empty plot.
///
/// ```dart
/// BarChart(
///   title: 'Patch installs by day',
///   points: [for (final d in days) BarPoint(d.label, d.count)],
///   emptyText: 'No installs reported yet.',
/// )
/// ```
class BarChart extends StatefulComponent {
  const BarChart({
    super.key,
    required this.title,
    required this.points,
    this.format,
    this.emptyText = 'Nothing to show yet.',
    this.height = 160,
    this.valueLabel = 'Value',
  });

  /// What it shows. Read by screen readers; draw a heading of your own to show it.
  final String title;
  final List<BarPoint> points;

  /// How a value is written. Whole numbers with separators unless you say.
  final String Function(num value)? format;
  final String emptyText;

  /// The plot's height in pixels.
  final int height;

  /// The values' column heading in the table.
  final String valueLabel;

  @override
  State<BarChart> createState() => _BarChartState();

  @css
  static List<StyleRule> get styles => [
    css('.ash-chart').styles(raw: {'margin': '0', 'display': 'grid', 'gap': '8px', 'min-width': '0'}),
    css('.ash-chart-readout').styles(
      raw: {
        'display': 'flex',
        'gap': '8px',
        'align-items': 'baseline',
        'min-height': '20px',
        'font-size': '14px',
        'line-height': '20px',
      },
    ),
    css('.ash-chart-readout-label').styles(raw: {'color': 'var(--ash-muted-foreground)'}),
    css('.ash-chart-readout-value').styles(raw: {'font-weight': '600', 'font-variant-numeric': 'tabular-nums'}),
    css('.ash-chart-plot').styles(
      raw: {
        'display': 'flex',
        'align-items': 'flex-end',
        // The surface's gap between bars.
        'gap': '2px',
        'border-bottom': '1px solid var(--ash-border)',
      },
    ),
    css('.ash-chart-slot', [
      css('&').styles(
        raw: {
          'flex': '1 1 0',
          'min-width': '0',
          'height': '100%',
          'display': 'flex',
          'align-items': 'flex-end',
          'justify-content': 'center',
          'outline': 'none',
          'border-radius': 'var(--ash-radius-sm) var(--ash-radius-sm) 0 0',
        },
      ),
      css('&:focus-visible').styles(raw: {'box-shadow': 'var(--ash-focus)'}),
    ]),
    css('.ash-chart-bar').styles(
      raw: {
        'width': '100%',
        'max-width': '24px',
        'background': 'var(--ash-chart-1)',
        // Rounded at the data end, square on the baseline.
        'border-radius': '4px 4px 0 0',
        'transition': 'opacity 120ms',
      },
    ),
    css('.ash-chart-plot:hover .ash-chart-bar, .ash-chart-plot:focus-within .ash-chart-bar').styles(
      raw: {'opacity': '0.45'},
    ),
    css('.ash-chart-plot .ash-chart-active .ash-chart-bar').styles(raw: {'opacity': '1'}),
    css('.ash-chart-axis').styles(
      raw: {
        'display': 'flex',
        'justify-content': 'space-between',
        'font-size': '12px',
        'line-height': '16px',
        'color': 'var(--ash-muted-foreground)',
      },
    ),
    css('.ash-chart-table', [
      css('&').styles(raw: {'font-size': '14px'}),
      css('summary').styles(raw: {'cursor': 'pointer', 'color': 'var(--ash-muted-foreground)', 'width': 'fit-content'}),
    ]),
    css('.ash-chart-empty').styles(
      raw: {
        'display': 'flex',
        'align-items': 'center',
        'justify-content': 'center',
        'border': '1px dashed var(--ash-border)',
        'border-radius': 'var(--ash-radius-lg)',
        'font-size': '14px',
        'color': 'var(--ash-muted-foreground)',
      },
    ),
  ];
}

class _BarChartState extends State<BarChart> {
  int? _active;

  String _format(num value) => component.format?.call(value) ?? _grouped(value);

  @override
  Component build(BuildContext context) {
    final points = component.points;
    final max = points.fold<num>(0, (m, point) => point.value > m ? point.value : m);
    if (max <= 0) {
      return div(
        classes: 'ash-chart-empty',
        styles: Styles(raw: {'height': '${component.height}px'}),
        attributes: {'role': 'img', 'aria-label': '${component.title}: ${component.emptyText}'},
        [Component.text(component.emptyText)],
      );
    }
    final active = _active == null || _active! >= points.length ? null : points[_active!];
    return Component.element(
      tag: 'figure',
      classes: 'ash-chart',
      children: [
        div(classes: 'ash-chart-readout', attributes: {'aria-hidden': 'true'}, [
          if (active != null) ...[
            span(classes: 'ash-chart-readout-label', [Component.text(active.label)]),
            span(classes: 'ash-chart-readout-value', [Component.text(_format(active.value))]),
          ] else
            span(classes: 'ash-chart-readout-label', [Component.text('Highest ${_format(max)}')]),
        ]),
        div(
          classes: 'ash-chart-plot',
          styles: Styles(raw: {'height': '${component.height}px'}),
          attributes: {'role': 'list', 'aria-label': component.title},
          [
            for (var i = 0; i < points.length; i++)
              div(
                classes: ['ash-chart-slot', if (i == _active) 'ash-chart-active'].join(' '),
                attributes: {
                  'role': 'listitem',
                  'tabindex': '0',
                  'aria-label': '${points[i].label}: ${_format(points[i].value)}',
                },
                events: {
                  'mouseenter': (_) => setState(() => _active = i),
                  'focus': (_) => setState(() => _active = i),
                  'mouseleave': (_) => setState(() => _active = null),
                  'blur': (_) => setState(() => _active = null),
                },
                [
                  div(
                    classes: 'ash-chart-bar',
                    styles: Styles(raw: {'height': '${(points[i].value / max * 100).clamp(0, 100)}%'}),
                    [],
                  ),
                ],
              ),
          ],
        ),
        div(classes: 'ash-chart-axis', attributes: {'aria-hidden': 'true'}, [
          span([Component.text(points.first.label)]),
          if (points.length > 1) span([Component.text(points.last.label)]),
        ]),
        Component.element(
          tag: 'details',
          classes: 'ash-chart-table',
          children: [
            Component.element(tag: 'summary', children: [Component.text('Show as a table')]),
            DataTable(
              caption: component.title,
              columns: [const TableColumn(''), TableColumn(component.valueLabel, numeric: true)],
              rows: [
                for (final point in points) [Component.text(point.label), Component.text(_format(point.value))],
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// 12345 as 12,345; fractions to one place.
String _grouped(num value) {
  final whole = value == value.roundToDouble();
  final text = whole ? value.round().abs().toString() : value.abs().toStringAsFixed(1);
  final [head, ...rest] = text.split('.');
  final grouped = head.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '${value < 0 ? '-' : ''}$grouped${rest.isEmpty ? '' : '.${rest.first}'}';
}
