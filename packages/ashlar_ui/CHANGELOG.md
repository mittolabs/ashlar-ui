## 0.7.1

- `ticket` is no longer deprecated: it stays as it is. 0.7.0 deprecated it by mistake, and is
  retracted. The four options 0.7.0 deprecated stay deprecated.

## 0.7.0

Ashlar UI is copied into your app, and the look of your app is yours: a shape, a skin or a
size that one design wants is drawn in your app, or changed in your copy, not added to Ashlar
as an option. Five options added in 0.4.0 to 0.6.0 were such looks, and are deprecated. They
still work, and go in a later release.

- `bottom-bar`: `floating` and `named`. Draw a floating bar in your app on `Pressable`, or
  change your copy.
- `input`: `round` and `raised`. Wrap an undecorated `Input` (`decorated: false`) in the box
  your design wants.
- `button`: `ButtonSize.icon2xl`. Size a button of your own, or change your copy.
- `toggle` and `toggle-group`: `ToggleVariant.chip`. Draw chips in your app on `Pressable`.
- `ticket`: the whole component. Keep your copy, or draw the shape with a `ShapeBorder` of
  your own.

## 0.6.0

- `appearance-picker` is new: system, light or dark, picked from three small screens drawn
  in the app's own colours, system being the light screen and the dark one cut on a
  slant. To a screen reader, three choices with one chosen.
- `bottom-bar`: `named`, with `floating`, shows the place you are in as a pill with its name
  beside its icon, the others as icons, and the bar hugs them.
- `input`: `round` for a pill and `raised` for the card colour with a shadow and no
  border until focused: a search field at the top of a screen. The icons either side are
  larger at `xl`.
- `select`: `SelectSize.lg` and `xl`, as tall as the button of the same size, with its
  corners and text.
- `calendar`: `expand` fills the width it is given, each day's column widening and the days
  growing taller, up to 44: a month that is the main thing on a phone's sheet.
- `ashlar shot` waits for pictures before drawing, so photos and avatars show on every
  screen, not only the first; and `--dark` sets the phone dark too, for an app that follows
  the phone rather than a theme mode of its own.

## 0.5.0

- `bottom-bar`: `floating` lays the bar over the page in a rounded bar of its own, icons
  alone and the place you are in a filled circle. The names are still read out, and the
  arrow keys still move along it.
- `toggle` and `toggle-group`: `ToggleVariant.chip`, a filled pill, the secondary
  colour off and the primary on, for filters set in a row with spacing; and
  `ToggleSize.xl`, 48 tall, beside an xl button.
- `button`: `ButtonSize.icon2xl`, a 64 square for the one control a screen is built
  round, a player's play.
- `drawer`: a debug build says so when `showDrawer`'s builder returns no `Drawer`,
  rather than showing what it built bare at the top of the screen.
- `pressable` says that a `semanticLabel` leaves everything it builds unread, buttons
  inside it too, and how to keep them heard.
- `ashlar shot` empties the asset bundle before each screen. An app that reads its data
  from its assets drew its first screen and left the rest empty.

## 0.4.0

- `ticket` is new: two halves on one card, bitten at the sides where they meet, with a
  line to tear along. The bites follow the join, so they stay level with it whatever the
  halves hold and however large the text.
- `button`: `ButtonSize.xl` (48 tall, for a phone's main action) and `iconXl`; `round`
  for a pill, or a circle of an icon button; `badge`, over the top end corner, for a dot
  that something is new.
- `input`: `size`, from `sm` to `xl`, as tall as the button of the same name, so a
  field and its button line up.
- `theme`: `text.xxxl` (30) and `text.display` (36), for headlines and figures that
  stand alone.
- `dialog`, `drawer` and `sheet` open over the whole app, a tab bar included. Inside a
  tab with a navigator of its own, a drawer came up above the tab bar and left it lit and
  tappable. `useRootNavigator: false` keeps the old way.
- `ashlar shot` draws a widget from any Dart file in the app, not only under `lib`: a
  harness under `test` can wrap a screen in its providers and route to draw it.
- `pressable` says how it sizes what it builds: centred, at its own size; give it
  `width: double.infinity` to fill.
- `empty`'s tests come with it alone, rather than once `item` is added too.

## 0.3.1

- `ashlar init` adds ashlaricons 0.3.0: 1,245 more icons fill in Solid, Duotone and Bulk,
  and 271 flags and the outlines of countries and continents are new.

## 0.3.0

The blocks are new: screens from apps people run, a shop, a clinic, a school office, a
support desk, each named for what it is rather than numbered. The old names still find
them in this version.

- Blocks, with the names they replace:
  - `shop-dashboard` (`dashboard-01`): a shop's day, sales by card and cash, four
    figures, a chart that changes range, and the orders still to deliver.
  - `clinic` (`sidebar-07`): a clinic's front desk, branches to switch between, sections
    that fold to icons, and today's appointments.
  - `api-docs` (`sidebar-01`, `-02`, `-03`): API documentation, versions, search,
    sections that fold, and a page with its steps and an example request.
  - `staff-handbook` (`sidebar-04`, `-05`, `-14`): a handbook in a floating sidebar, with
    the page's contents beside it where there is room.
  - `newsroom` (`sidebar-06`): a paper's sections as menus, a morning brief to sign up
    to, and a desk's stories.
  - `school-office` (`sidebar-08`): the page inset as a card, the term's fees and who
    owes most.
  - `support-inbox` (`sidebar-09`): queues, tickets to pick from (unanswered only, if you
    like), and the conversation with a reply.
  - `field-notes` (`sidebar-10`): a field officer's notes on a visit, a checklist, and
    the page's actions in a popover.
  - `code-review` (`sidebar-11`): a change under review, its files as a tree with the
    changed ones above, and the diff.
  - `salon-bookings` (`sidebar-12`, `-15`): a month to pick a day from, who is working,
    and a column of bookings for each of them.
  - `shop-settings` (`sidebar-13`): settings in a dialog, their sections down its side.
  - `rent-tracker` (`sidebar-16`): rent across units, under a header that runs over the
    sidebar.
  - `phone-sign-in` (`login-01`): a phone number, then the code texted to it.
  - `split-sign-in` (`login-02`): the form beside your picture, or a customer's word.
  - `account-picker` (`login-03`): carry on as an account used here before.
  - `till-pin` (`login-04`): a shared till's lock screen, who is serving, then a PIN.
  - `magic-link-sign-in` (`login-05`): an email address, then a link sent to it.
  - `phone-sign-up` (`signup-01`): a name and a phone number, the terms agreed to.
  - `business-sign-up` (`signup-02`, `-04`): an account for a business, its tax number
    checked, what the account gives beside the form.
  - `team-invite` (`signup-03`): join from an invitation, who sent it and who is there.
  - `member-sign-up` (`signup-05`): three steps, details, ID, then a PIN given twice.
  - `assistant-chat` (`chat-01`) and `wallet` (`wallet-01`): the same blocks, renamed.
- `ashlar add`, `view`, `diff` and `update` take a block's old name, use the new one, and
  say so: `login-01 is now phone-sign-in.` The old names go in 0.4.0.
- Phone numbers in `phone-sign-in` and `phone-sign-up` take a country (`dialCode`, `1` to
  begin with) and come back in full, `+14155550123`.
- `button`: a `link` has no padding at its sides, so it lines up with the words and fields
  around it. Where a link follows text in a row, give the row a gap (`Wrap(spacing: 6)`).
- `field`: beside a checkbox, radio or switch on a phone, the label lines up with the
  control's middle rather than the top of its larger press area.
- `collapsible` (and `accordion`): what it reveals starts at the start, rather than in
  the middle when it is narrower than the panel.
- `bubble`: reactions hang over the bubble's edge without covering the message's text.
- `kbd`: a key hugs its text when it is given more height.
- `heatmap`, `radial-chart`, `treemap`: braces on every `if`, so an app that adds them
  analyses clean.
- Sample content in the previews, tests and doc comments comes from around the world,
  money in US dollars, and every sample address is at `example.com`.

### Moving from 0.2

A block already in your app is yours and stays as it is. Adding a block by its old name
now adds the new screen, in a file of its new name.

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
- For AI features:
  - `markdown`: `Markdown`, formatted text drawn as it streams in (headings, lists with
    boxes to tick, tables, quotes, links, pictures, code with a copy button); what is
    not yet closed is drawn as if it were, and `streaming` shows a caret.
  - `prompt-input`: `PromptInput`, text that grows, attachments above it, your actions
    under it, and send that becomes stop while an answer arrives. Enter sends,
    Shift+Enter starts a line, and a word still being composed is left alone.
  - `reasoning`: `Reasoning`, a model's thoughts under "Thinking…", folded away as
    "Thought for 12 seconds" once it is done.
  - `tool-call`: `ToolCall`, what an assistant did with a tool (waiting, running, done,
    failed) with what went in and came out, and Approve and Deny when it asks.
  - `sources`: `Sources`, what an answer rests on, numbered, and `Citation`, the number
    in the answer's text.
  - `plan`: `Plan`, an assistant's steps ticked off as it works.
  - `shimmer`: `Shimmer`, a light passing over text still being worked on; still when
    less motion is asked for.
  - `soundwave`: `Soundwave`, a voice's loudness as bars, from levels your audio gives.
  - `chat-01`: a block, an assistant's whole conversation using them; give it your
    model as a stream of text.
- `wallet-01`: a block, a wallet with its balance (hidden at a tap), how it went this
  month, send, request, pay and top up, and what came in and went out.
- `message-scroller`: a turn sent while scrolled far up is brought into view. It stayed
  out of sight below.
- `ashlar init` writes what a coding agent should know about building with Ashlar UI
  (the components and their names, the theme, Pressable, ashlaricons, start and end,
  `ashlar shot` and `check`) into `AGENTS.md`, and `CLAUDE.md` when there is one,
  between markers; `ashlar apply` keeps it current, `--no-agents` leaves it out.
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
