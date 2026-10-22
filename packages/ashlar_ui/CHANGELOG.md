## 0.2.0

Charts are rebuilt as your rows and the parts you put in them, and cover far more kinds.
This breaks code written against 0.1.x charts: see "Moving from 0.1" below.

- `chart`: a chart is your rows and the parts you put in it.
  `BarChart<Visit>(data: visits, x: (r) => r.month, children: [CartesianGrid(), XAxis(),
  ChartTooltip(), Bar(label: 'Desktop', value: (r) => r.desktop)])`. Name the row type on
  the chart; the parts take it from there, and a misspelt field fails to compile.
  - One engine draws every cartesian chart (`BarChart`, `LineChart`, `AreaChart`,
    `ComposedChart`, `ScatterChart`), so kinds mix: `Bar`, `Line`, `Area`, `Scatter`
    (bubbles with `size`), `Candlestick`, `Ohlc`, `HiLo`, `BoxPlot`, `Waterfall`; ranges
    (`low`) and error bars (`error`); stacks and 100% stacks of bars, lines and areas.
  - Axes: category, number, time (rows placed by when they fall) and log, several value
    axes on either side, upright or lying (`layout: ChartLayout.vertical`).
  - `ReferenceLine`, `ReferenceArea`, `ReferenceDot`, `ChartAnnotation` (any widget at a
    row and a value), `Trendline` (linear, exponential, logarithmic, polynomial, power,
    moving average, run past the data), `Brush`, `Crosshair`.
  - `zoom: true` (wheel, pinch, drag, double tap), `XAxis(last: 30)` to follow the latest
    rows, `onReachStart` to load earlier ones, `onSelect` with the row and series tapped
    or chosen with Enter. New values move from the old ones. Many points are thinned to
    the pixel.
  - `ChartLabels` write values or your own text at any side of a bar or point;
    `ChartDot` gives dots a size, shape, icon or a colour per row.
  - `HistogramChart` (with `chartBins` and the normal curve) and `ChartTable`, the values
    as a table (any `ChartColumn` is a column).
  - The drawing helpers the other chart components share are public, for charts of your
    own: `ChartGrowth`, `chartText`, `chartMark`, `chartGlyph`, `chartDashed`,
    `chartPlain`, `ChartTooltipCard`, `ChartLegendView`.
- `pie-chart`: `PieChart` with `Pie` rings (padding, rounded corners, labels inside or
  outside, a figure in the middle). Was in `chart`.
- `radar-chart`: `RadarChart` with `PolarGrid`, `PolarAngleAxis`, `PolarRadiusAxis` and
  `Radar`. Was in `chart`.
- `radial-chart`: `RadialBarChart` with `RadialBar` (stacked, part rings, names at the
  start). Was in `chart`.
- `sparkline`: `Sparkline`, a line, area, bars or wins and losses with no axes.
- `funnel-chart`: `FunnelChart` with a `Funnel` or `Pyramid`.
- `heatmap`: `Heatmap` and `CalendarHeatmap`.
- `treemap`: `Treemap`, grouped if you like.
- `chart-indicators`: `Sma`, `Ema`, `Wma`, `Tma`, `Bollinger`, `Macd`, `Rsi`,
  `Stochastic`, `Atr`, `AccumulationDistribution`, `Momentum` and `RateOfChange`.
- `chart-export`: `ChartExport` and its controller give a chart as PNG or PDF bytes.
- `dashboard-01`: its chart places the days on a time axis.
- `color-picker`: `ColorPicker`, a square for saturation and brightness, a hue strip,
  opacity if asked, a hex field and swatches, each part by pointer, keys or a screen
  reader; `ColorPickerButton` opens one from a swatch.
- `ashlar shot` draws the app's own screens to pictures without running it, in its
  theme and fonts, at a phone's, a tablet's or a desktop's size, light or dark, and
  names what Flutter complained of while drawing with the file and line. `ashlar mcp`
  has it as `shot_screen`, so a coding agent can see what it built.
- `ashlar init --preset` and `ashlar apply --preset` take a theme made on
  ui.ashlar.ke/themes: its base, accent and style, and any colours (light and dark),
  corners, spacing and shadows changed on them, written into `app_theme.dart`. The
  preset is kept in `ashlar.yaml`; `--preset none` drops its changes.
  `package:ashlar_ui/preset.dart` reads and writes the codes.

### Moving from 0.1

| 0.1 | 0.2 |
|---|---|
| `labels: [...]`, `series: [ChartSeries('Desktop', [...])]` | `data: rows`, `x: (r) => r.month`, `Bar(label: 'Desktop', value: (r) => r.desktop)` |
| `stacked: true` | the same `stackId` on each series |
| `expand: true` | `stackOffset: StackOffset.expand` |
| `horizontal: true` | `layout: ChartLayout.vertical` |
| `axis: true` | `YAxis()` |
| `grid: true` (the default) | `CartesianGrid()`; nothing is drawn unless you put it in |
| row labels (always drawn) | `XAxis()` |
| `legend: ChartLegend.bottom` (the default) | `ChartLegend()`; `ChartLegend(position: ChartLegendPosition.top)` |
| `tooltip: ChartTooltip(...)` (on by default) | `ChartTooltip(...)` in the children |
| `ChartTooltip(showTitle: false)`, `title:` | `hideLabel: true`, `labelFormatter:` |
| `dots: true`, `curve:`, `gradient:` | on each `Line` or `Area` |
| `valueLabels: true` | `labels: [ChartLabels()]` on the series |
| `ChartSeries(colors: [...])` | `Bar(colorOf: (r) => ...)` |
| `PieChart`, `RadarChart`, `RadialChart` in `chart` | `ashlar add pie-chart`, `radar-chart`, `radial-chart` |
| `PieChart(slices: [ChartSlice(...)])` | `PieChart(data:, children: [Pie(value:, name:)])` |
| `donut: true`, `inner:`, `active:` | `Pie(innerRadius: .6)`, a second `Pie`, `Pie(activeIndex:)` |
| `PieLabels.amounts`, `PieLabels.titles` | `ChartLabels(position: ChartLabelPosition.inside)`, `ChartLabels(text: ...)` |
| `RadarChart(labels:, series:, grid:, spokes:, gridFill:)` | `RadarChart(data:, axis:)` with `PolarGrid(type:, radialLines:, fill:)` and `Radar` |
| `RadialChart(slices:, half: true, track:)` | `RadialBarChart(data:, startAngle: -90, endAngle: 90)` with `RadialBar(background:)` |

## 0.1.5

- `DrawerSheet`, in `drawer`: a drawer that stays on the page and rests at snap points,
  dragged or flicked between them, its content scrolling once it is fully up. Its handle
  is a control (a tap, Enter or a screen reader's increase and decrease move it a snap),
  and a `DrawerSheetController` moves it and says where it rests. `drawer` now needs
  `pressable`.

## 0.1.4

- `AshlarApp.router` takes a `RouterConfig`, for go_router and other routers, with the same
  theme, text and icon defaults around every page as `AshlarApp`.
- `ashlar init` now copies the app shell's test with it; `--no-tests` leaves it out.

## 0.1.3

- `ashlar init --blocks` and `--tests` set where blocks and tests go, as `--path` does for
  components. A folder outside the project is refused.

## 0.1.2

- Toggle keeps its height: given room, it stretched to fill it since 0.1.0. A framed Empty
  and a MessageGroup are as tall as what they hold.

## 0.1.1

- An example of using the command, and doc comments on what the package exports.

## 0.1.0

The first release of the `ashlar` command for Ashlar UI: Flutter components built on the
widgets layer alone, copied into your app as source you own.

- 65 components and 27 blocks (whole screens), each with the tests that check what it
  promises, written to `test/ashlar` with it.
- `ashlar init` and `ashlar apply`: seven bases, seventeen accents and six styles, and your
  own prefix on every name (`--prefix SL` for `SLButton`, `SLTheme`, `showSLToast`).
- `ashlar add`, `view`, `search`, `list`: the components and what they need.
- `ashlar diff` and `ashlar update`: newer versions merged with your changes, compared as
  your own formatter lays out code; `--preview` draws what an update would change, in your
  theme, before and after.
- `ashlar check`: your theme's contrast measured, and in your code icon-only buttons
  without a label, left and right where start and end belong, and touch targets turned off.
- `ashlar book`: a catalog of your components, in your theme, to run as an app.
- `ashlar mcp`: the commands for coding agents, over the Model Context Protocol.
- `ashlar build`: a registry of your own.
- Settings in `ashlar.yaml`; what ashlar wrote, in `.ashlar`.
