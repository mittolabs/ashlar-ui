# Charts

Where the charts stand against shadcn/ui and Syncfusion's Flutter charts, and what is
still short. Taken stock on 22 October 2026 and rebuilt the same day, as `ashlar_ui`
0.2.0.

## How they are shaped

As in shadcn/ui on Recharts: a chart is your rows and the parts you put in it.

```dart
typedef Visit = ({String month, double desktop, double mobile});

BarChart<Visit>(
  data: visits,
  x: (r) => r.month,
  children: [
    CartesianGrid(),
    XAxis(),
    ChartTooltip(),
    Bar(label: 'Desktop', value: (r) => r.desktop),
    Bar(label: 'Mobile', value: (r) => r.mobile),
  ],
)
```

The one difference from shadcn is on purpose: a series reads its value with a typed
function, not a string key, so a misspelt field fails to compile instead of drawing
nothing. Dart needs the row type named on the chart (`BarChart<Visit>`) to type the parts
inside it; left off, `r` is `Object?` and the parts do not compile, which is the error you
want. Decided with the owner on 22 October 2026, over a Syncfusion-style list of series
with flags.

One engine draws every cartesian chart, so `BarChart`, `LineChart`, `AreaChart`,
`ComposedChart` and `ScatterChart` are the same widget under shadcn's names, and kinds mix
freely. Pie, radar and radial charts are components of their own (decided 22 October 2026),
so an app that wants a bar chart does not copy about 1,450 lines of them; the cartesian
kinds stay in `chart`, since prices, boxes and waterfalls are a few hundred lines of the
one engine and splitting them would make its insides public. Everything is drawn on the canvas here, with no charting package (decided
2026-10-13).

## The components

| Component | What it holds |
|---|---|
| `chart` | the cartesian engine and its parts, `HistogramChart`, `ChartTable`, the grid polar charts share, and the helpers the rest draw with |
| `pie-chart` | `PieChart` and `Pie` |
| `radar-chart` | `RadarChart`, `Radar`, `PolarAngleAxis`, `PolarRadiusAxis` |
| `radial-chart` | `RadialBarChart` and `RadialBar` |
| `sparkline` | `Sparkline`: line, area, bar, win-loss |
| `funnel-chart` | `FunnelChart` with `Funnel` or `Pyramid` |
| `heatmap` | `Heatmap`, `CalendarHeatmap` |
| `treemap` | `Treemap` |
| `chart-indicators` | twelve technical indicators |
| `chart-export` | PNG and PDF bytes of any chart |

## Against shadcn/ui

All 70 of shadcn's chart variants (`apps/v4/registry/new-york-v4/charts`, read
22 October 2026) are on ui.ashlar.ke's Charts page under their names, `chart-bar-label-custom`
and the rest, with five of ours beside them (area even fill, bars to 100%, a line with a
scale, a radial gauge, dashed tooltip marks): 75 in shadcn's seven groups, and 47 more in
thirteen groups of our own, 122 in all.

What shadcn gets from Recharts that we draw ourselves: `CartesianGrid`, `XAxis`, `YAxis`,
`ChartTooltip` (dot, line, dashed or no marks, no label, label and value formatters, a
total, icons, your own content), `ChartLegend` (hides series, by pointer or keyboard),
`LabelList` (as `ChartLabels`, any side of a bar or point), stacks and `stackOffset:
expand`, `layout: vertical`, `activeIndex`, `Cell` colours (`colorOf`), custom dots, radar
grids (polygon, circle, rings of your choosing, filled, no spokes), `PolarRadiusAxis`, and
radial bars stacked, part-ring and labelled.

## Against Syncfusion

`syncfusion_flutter_charts` 35.1.41, from its pub.dev page and help.syncfusion.com, read
22 October 2026.

| Syncfusion | Here |
|---|---|
| line, spline, step line, fast line | `Line` with `curve:`; thinned to the pixel when long |
| column, bar, stacked and 100% stacked column, bar, area, line | `Bar`, `Area`, `Line` with `stackId`, `StackOffset.expand`, `ChartLayout.vertical` |
| area, spline area, step area | `Area` with `curve:` |
| range column, range area, spline range area | `Bar(low:)`, `Area(low:)` with `curve:` |
| scatter, bubble | `Scatter`, with `size:` |
| candle, OHLC, HiLo | `Candlestick`, `Ohlc`, `HiLo` |
| box and whisker, histogram, error bar, waterfall | `BoxPlot`, `HistogramChart`, `error:`, `Waterfall` |
| pie, doughnut, radial bar | `PieChart`, `Pie(innerRadius:)`, `RadialBarChart` |
| pyramid, funnel | `PyramidChart`, `FunnelChart` |
| sparklines: line, area, bar, win-loss, with high, low, first, last markers, plot band, trackball | `Sparkline` |
| numeric, category, date-time, date-time category, log axes | `AxisType.number`, `category`, `time`, `category` over dates, `log` |
| multiple axes, opposed | several `YAxis(id:)`, `right: true` |
| plot bands | `ReferenceArea` |
| annotations | `ChartAnnotation` (any widget) |
| trendlines: linear, exponential, logarithmic, polynomial, power, moving average | `Trendline` with `forward` and `backward` |
| 12 technical indicators | `chart-indicators` |
| zooming and panning, trackball, crosshair, selection, callbacks, tooltip | `zoom: true`, the shared tooltip with dots on each line, `Crosshair`, `onSelect`, `ChartTooltip` |
| auto-scrolling, on-demand loading, live updates | `XAxis(last:)`, `onReachStart`, new values moving from old |
| export to image and PDF | `chart-export` |
| legend that collapses series and wraps | `ChartLegend` |

Ours and not theirs: a radar chart (none in their Flutter package or docs), treemaps and
heatmaps inside the chart family (Syncfusion has them as separate products), `ChartTable`,
and the MIT licence where theirs needs a paid or community licence.

## Still short, said plainly

What Syncfusion or Recharts have that is not here, found while building. None is on a
user's list; each is small.

- Zooming by dragging a rectangle (Syncfusion's selection zooming). Zoom is by wheel,
  pinch and the brush.
- Separate panes stacked under one x axis. Indicators on another scale sit on a second
  value axis of the same plot, which reads fine for RSI and less well for MACD over
  prices.
- Axis options: labels turned at an angle when they crowd, an axis drawn reversed, axes
  crossing at a value other than zero. Crowded category labels are thinned instead.
- Trackball modes beyond two: every series at the row (the default) or the one under
  the pointer (`shared: false`).
- Radial bar labels are written level rather than along the arc.
- The PDF holds the picture uncompressed: a 900 by 500 chart at twice the pixels is
  about 5 MB. Compressing it means writing deflate by hand (no package), which was left
  out.

## Pictures and tests

- `registry/tests/`: a test file per component, copied into apps with it (chart 16,
  pie 4, radar 3, radial 3, sparkline 4, funnel 3, heatmap 3, treemap 2, export 3,
  indicators 5).
- `gallery/test/chart_variants_test.dart`: 39 more over the options, light and dark.
- ui.ashlar.ke's `make shots` draws every variant, light and dark; `make test` checks each
  keeps its text whole at 200%.
- Checked once by hand, 22 October 2026: a new Flutter app with `ashlar init --prefix SL`
  and all ten chart components analyzes clean and passes its 48 copied tests.
