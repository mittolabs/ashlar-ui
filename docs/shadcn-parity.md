# Parity with shadcn/ui

What shadcn/ui is, measured from its own repository, against what Ashlar UI has. Read from
`shadcn-ui/ui` at commit `30a58d4` (12 October 2026): `apps/v4/registry` (components, the
showcase examples, blocks, charts, themes, styles), `apps/v4/content/docs` and the CLI's
commands. Update this file when either side moves.

## The honest summary

Counting components made us look close: 55 of their 62. Counting what each component can do,
we are not. shadcn's components are built from many small parts that compose (a dropdown
menu has 15: items, checkbox items, radio items, submenus, groups, labels, shortcuts), and
each one's showcase covers 3 to 26 situations. Ours mostly offer one shape with fixed slots.

| | shadcn | Ashlar UI |
|---|---|---|
| Components | 62 | 62, with the theme, app and helpers besides |
| Showcase situations across components | about 480 | 168: a demo each and 106 examples |
| Blocks (whole screens) | 28: 1 dashboard, 16 sidebars, 5 logins, 5 signups | 27: the same set |
| Chart variants | 71, across area, bar, line, pie, radar, radial, tooltip | 58, across the same seven |
| Themes | 7 base colours and 17 accent colours | the same 7 and 17, with contrast floors |
| Visual styles (presets) | 8: Vega, Nova, Maia, Lyra, Mira, Luma, Sera, Rhea | 6: standard, compact, rounded, sharp, dense, soft |
| Primitive bases | 3: Radix, Base UI (default since July), React Aria | Flutter's widgets layer |
| CLI commands | 15: init, add, apply, build, diff, docs, eject, info, mcp, migrate, preset, search, view, registry, dry run | 9: init, apply, add, view, search, list, diff, build, registries |
| Right-to-left | yes, CLI converts to logical sides | yes, logical sides; tested in both directions |
| Forms | guides and examples for 3 form libraries (34 examples) | Form on Flutter's `Form`: any control, checks, focus on the first error |

## Components they have that we do not

| shadcn | For Flutter |
|---|---|
| Message, Bubble, Attachment, Marker, Message Scroller (June 2026: chat interfaces) | Build. Chat is a common app screen and these are new enough to lead on. |
| Questionnaire (August 2026: multi-step question flows) | Build. |
| Form (field state, validation, error display) | Build on the widgets layer's `Form` and `FormField`, wired to Field's error. |
| Direction (right-to-left provider) | Flutter has `Directionality`; the work is making every component direction-aware. |
| Toast on Base UI (July 2026), beside Sonner | Ours is Sonner-shaped; see Toast below. |
| Table (plain markup table) | Our DataTable covers it; a lighter `Table` styling may still be worth having. |
| Aspect Ratio | Flutter has `AspectRatio`. Document it, do not build it. |
| Native Select | No native select in Flutter. Not applicable; say so in the docs. |

## Component by component

What their showcase covers that ours does not. "Parts" are sub-components we would need for
the same composition.

| Component | Missing in Ashlar UI |
|---|---|
| Accordion | bordered style, disabled items, in-card style |
| Alert Dialog | media slot (icon or image), small size, in-dialog stacking |
| Alert | parity, apart from styles |
| Attachment | whole component: files and images, states, sizes, scrollable group, triggers |
| Avatar | named sizes (sm, default, lg), badge, badge with icon, group, group with count |
| Badge | ghost and link variants, icon right, custom colours |
| Breadcrumb | ellipsis, dropdown in a crumb, custom separator, responsive collapse |
| Bubble | whole component (chat) |
| Button | sizes xs, icon-xs, icon-sm, icon-lg; invalid state |
| Button Group | separator, text part, nested groups, joined Input, Select and Input Group, split button |
| Calendar | multiple dates, booked dates, time, presets, month and year dropdowns, week numbers, two months, custom days, other calendars (Hijri) |
| Card | small size, header and footer borders, edge-to-edge image, title and description as parts |
| Carousel | vertical, controller API, autoplay plugin, sizes and spacing examples |
| Chart | radar, radial; tooltip styles (dot, line, dashed indicator, no label, formatters); legend content; labels on bars, horizontal bars, negative values, step lines, interactive switching; 71 variants in all |
| Checkbox | indeterminate state, invalid, title and description, in table, group |
| Collapsible | file tree and settings examples |
| Combobox | many picks as chips, clear button, groups and separators, disabled items, auto highlight, custom item rendering, invalid, in dialog |
| Command | separator item; otherwise close |
| Context Menu | submenus, checkbox items, radio items, groups, inset items, sides |
| Dialog | separate header and footer parts, scrollable content with a sticky footer |
| Drawer | top, left and right sides |
| Dropdown Menu | submenus, checkbox items, radio items, inset items, groups |
| Empty | muted background and border variants, avatar media |
| Field | FieldSet, FieldLegend, FieldGroup, FieldSeparator, FieldTitle, FieldContent; choice cards; responsive orientation |
| Hover Card | left and right sides |
| Input | file input, sizes |
| Input Group | sizes, InputGroupButton, addon alignment parts |
| Input OTP | close to parity |
| Item | sizes sm and xs, media variants (icon, image), ItemGroup, ItemSeparator, ItemHeader, ItemFooter, as a link |
| Kbd | icons in keys |
| Label | parity |
| Marker | whole component (chat) |
| Menubar | submenus, checkbox and radio items, inset items |
| Message, Message Scroller | whole components (chat) |
| Navigation Menu | animated viewport and indicator |
| Pagination | simple form, rows-per-page select |
| Popover | header, title and description parts; left and right sides |
| Progress | label |
| Questionnaire | whole component |
| Radio Group | grid and card layout, invalid |
| Resizable | controlled sizes |
| Scroll Area | parity |
| Select | groups with labels, separators, icons, small size, scroll buttons, lazy long lists (ours builds every item) |
| Separator | parity |
| Sheet | no-close-button option |
| Sidebar | variants (sidebar, floating, inset), right side, submenus, menu and group actions, skeleton rows, rail, input, controlled state, sizes |
| Skeleton | parity |
| Slider | range with two thumbs, more thumbs, vertical |
| Sonner / Toast | types (success, info, warning, error, loading), promise toasts, cancel, close button, positions, collapsed stack that expands |
| Spinner | parity |
| Switch | small size |
| Table | see Data Table; actions, inputs and selects in cells work |
| Tabs | line variant, vertical, alignment |
| Textarea | parity |
| Toggle | parity |
| Toggle Group | spaced variant, vertical |
| Tooltip | left and right sides, rich content (shortcuts, formatting) |
| Typography | table |

## Beyond components

- **Blocks.** 28 whole screens, the fastest way to see a library is real: a dashboard, 16
  sidebar layouts, 5 login and 5 signup screens.
- **Styles (presets).** Eight looks over the same components: Vega (the familiar default),
  Nova (tighter), Maia (rounder, roomier), Lyra (boxy, for mono fonts), Mira (compact), Luma
  (soft, macOS-like), Sera (editorial, underlined controls, uppercase headings), Rhea (compact
  Luma). Each is a stylesheet of per-component rules. For us this means a theme that carries
  spacing, density and shape per component, not only colours and one radius.
- **Themes.** Seven base colours (neutral, stone, zinc, mauve, olive, mist, taupe) and
  seventeen accents, chosen at `init`.
- **CLI v4.** `apply` switches a preset in an existing project; `preset` shares one as a code;
  `diff` shows what changed upstream in a file you edited; `view` and `search` read registries;
  `build` publishes your own registry; `mcp` serves registries to AI assistants; `--dry-run`
  previews; GitHub repositories, public and private, work as registries.
- **Right-to-left.** Logical start and end throughout.
- **Forms.** Guides and complete examples for three form libraries.
- **Typeset.** A typography system for rendered markdown and streaming chat.
- **The site.** For each component: composition trees, an API reference, a gallery of every
  situation with code, and blocks, charts and themes pages with a theme builder.

## Progress

**Step 1, depth where apps live: done** (13 October 2026). Menus have checkbox, radio and
inset items, groups and submenus; panels and tooltips open on all four sides; Select has
groups, type-to-find and lazy lists; Combobox picks several; Slider takes ranges and stands
upright; Checkbox is indeterminate; Avatar has badges and groups; Button, Switch, Badge, Tabs
and Toggle Group have their sizes and variants; Toast has types, promises and a stack; Sidebar
has variants, submenus, actions and a rail; Card, Field, Item, Breadcrumb, Accordion, the
dialogs, Empty, Drawer, Sheet, Pagination, Radio and Resizable have their parts and options;
Calendar picks several days, shows week numbers, two months and dropdowns; Carousel runs
upright with a controller and autoplay.

Navigation Menu now has one panel that moves between headings (done later the same day). Not
applicable to Flutter: Native Select, a file Input, Aspect Ratio (Flutter has it).

**Step 2, right-to-left: done** (13 October 2026, c323e30). Padding, alignment, borders
and corners are logical (start and end); arrow keys and pointing icons follow the reading
direction in Tabs, Menubar, Toggle Group, Calendar, Carousel, submenus, Pagination,
Breadcrumb, Sidebar, Slider and Resizable; submenus open towards the end of the line;
popovers align to the start edge. `gallery/test/rtl_test.dart` runs each check in both
directions. Physical on purpose: Drawer, Sheet and Toast name screen edges and corners, and
charts keep time running left to right, as their plots are drawn.

**Step 3, forms: done** (13 October 2026, 82b3c24). `ashlar add form`: `FormItem` draws
any control of a Flutter `Form` as a Field with its error; `FormText` keeps an Input in step
with the form; `Validate` has required, lengths, email, pattern, min, max and all;
`submit()` shows every error, focuses the first wrong field on screen (where a screen reader
hears its error) and saves when all are right. Errors appear on sending and clear as each
is put right, as shadcn's react-hook-form examples behave. The site has a Form page.

**Step 4, blocks: done** (13 October 2026, 4528926, cc0fb89). 27 whole screens, as shadcn
has: dashboard-01; sidebar-01 to sidebar-16 (documentation, floating, menus, icon strip,
inset, mail folders, popover actions, file tree, calendar, dialog, right, both sides, site
header); login-01 to 05 and signup-01 to 05, their forms checked by Form. `ashlar add
login-01` writes to `lib/blocks` beside the components with imports pointing at them;
`--blocks` adds all. Sidebar gained custom and bottom groups and a fixed mode; Tabs scroll
when too wide; a stacked area chart now fills to the series below. Social sign-in buttons
carry names only: Ashlar's icons have no Google or Meta marks.

**Step 5, chat: done** (13 October 2026, 148c828 and after). Message (sides that follow
the reading direction, avatar, header, footer), Bubble (seven fills, groups, reactions,
pressable), Marker (plain, separator, border), Attachment (five states shown and spoken,
three sizes, tiles, actions, a scrolling group) and Message Scroller: it opens at the last
turn, lifts a new turn near the top with room below and a peek of the turn before, follows
an answer only while the reader is at the end, keeps its place as older rows load, jumps
to any row and says which turn is being read. Then Questionnaire: one question at a time,
one choice or several or words, required or skippable, conditional questions, letter or
number keys, arrows and Enter. Each has a page on the site.

**Step 6, themes and styles: done** (13 October 2026, f1420a5). Seven bases (neutral,
stone, zinc, mauve, olive, mist, taupe) and seventeen accents, generated from shadcn's oklch
values by `tool/palette.mjs`, with contrast floors shadcn's values miss: muted text reaches
4.5 to 1 on the page and on muted surfaces (olive's was 4.25), and the sidebar's mark 4.5
(dark lime's was 1.85). Six styles of our own naming (standard, compact, rounded, sharp,
dense, soft) carry radius, control density, panel spacing and shadows, which buttons,
inputs, selects, toggles, tabs, menus, cards and panels read. `ashlar init --base --accent
--style` writes `app_theme.dart`. Not carried over: fonts per style (Ashlar ships no
fonts), and shadcn's per-component rules beyond spacing and shape.

**Step 7, CLI: done** (13 October 2026, 85951df). `view`, `search` (with `list`), `diff` (your
changes told from newer versions by fingerprints recorded at install), `apply` (the theme
chosen again), `build` (a registry of your own to host), and `@name/item` from a web
address or a folder named in `ashlar.yaml`, with paths that would leave the project
refused. Not carried over: `mcp`, `migrate`, `eject` and preset codes; `docs` and `info`
are covered by `view` and `list`.

**Step 8, charts: done** (13 October 2026, 0c02b25, 7bde02d). RadarChart (polygon, circle or
no grid, filled bands, outlines, dots, spokes) and RadialChart (rings or stacked, whole or
half circle, track, centre figure). Lines and areas step or run straight, with dots and
values; areas and bars stack to 100%; bars lie along, go below zero, take a colour each
and stand out one at a time; a value axis; pies write names or values, draw a slice out,
drop separators and take an inner ring. Tooltips: dot, line, dashed or no marks, titles
your way, icons, a total. Legends hide and show series by pointer or keyboard. The site's
Charts page shows 58 variants (shadcn has 71; theirs include several near-identical label
and colour versions), each live and with its code.

**Step 9, the site: done** (13 October 2026). Each component page has its demo, Examples
(106 situations across 58 components, each pictured, live on a click, with its code; Chart
and Sidebar point to their pages) and an API reference read from the source: every public
type, each parameter's type, default, whether it is positional, and its doc comment (563
fields were undocumented; 439 now carry docs in the registry, the rest are enum values that
say what they are, and Flutter's inherited form-field parameters, described from Flutter).
New pages: Blocks (27 screens, live), Charts (58 variants), Themes (bases, accents and
styles chosen and seen live, with the `ashlar init` line). The CLI and Theming guides cover
every command and the themes. Building the gallery found six layout faults in components,
now fixed with tests: Alert, Field across and Message grew to the height they were given;
Kbd and Toggle to the width; Switch, Checkbox and Radio stretched in a stretching column.

Where we still trail: shadcn shows about 480 situations to our 168 (62 demos and 106
examples), and 71 chart variants to our 58.

## Plan

In order of what makes Ashlar UI feel complete soonest:

1. **Depth where apps live.** Menus with submenus, checkbox and radio items (Dropdown, Context,
   Menubar); Select groups and lazy lists; Combobox with many picks; Slider ranges; Checkbox
   indeterminate; Avatar group; Tooltip and Popover on all four sides; Toast types; Button
   and Switch sizes; Tabs line and vertical; Sidebar variants, submenus and actions; Field
   sets and choice cards; Card and Item parts and sizes.
2. **Right-to-left** across every component, with tests in both directions.
3. **Forms** on the widgets layer's `Form`, with validation shown through Field.
4. **Blocks**: the dashboard, a sidebar set, logins and signups, as copyable screens.
5. **Chat**: Message, Bubble, Attachment, Marker, Message Scroller; then Questionnaire.
6. **Themes and styles**: the base colours and accents, then presets that carry spacing and
   shape, chosen at `ashlar init`.
7. **CLI**: `diff`, `view`, `search`, `apply`; then registries of your own.
8. **Charts**: radar and radial, tooltip and legend styles, then the variant gallery.
9. **The site**: a gallery of situations per component, API references, and blocks, charts
   and themes pages.

All nine are done.

## Past parity

Three bets for being better than shadcn rather than a copy of it, in order:

1. **Updates that keep your edits.** Done. `ashlar update` keeps a copy of each file as
   written in `.ashlar/base/`, replaces what you have not changed and merges what you have,
   three ways. Where both sides changed the same lines, both are kept between markers.
2. **Fitting the device, without swapping components.** A dialog stays a dialog on a phone.
   What changes is input, not the component. Done:
   - Tap targets: 44 on iOS and 48 on Android around every pressable, with the visual size
     unchanged (`AshlarThemeData.tapTarget`).
   - The keyboard: dialogs, sheets and drawers rise above it (`AboveKeyboard`).
   - Touch: a long press opens a hover card; the select list matches its trigger's width.
   - Phone patterns, each reachable without its gesture: Swipe Actions, Pull to Refresh
     (holds a bouncing list under the spinner) and Bottom Bar (above the home indicator).
3. **Quality you can check.** Done:
   - `ashlar add` writes each component's tests to `test/ashlar`, importing it from the
     app: 53 components carry 207 tests. A change that breaks a promise fails its test.
   - `ashlar check` measures the app's theme for contrast in a flutter test and finds in
     its source icon-only controls without a label, physical left and right where start
     and end belong, and touch targets turned off. It says what it cannot check.
   - Measuring found two failures in every one of our 252 themes, now fixed and held by a
     test: white on the dark destructive red (2.89:1) and the light focus ring (2.3 to
     2.6:1). It found two right-to-left mistakes in the site's data table demo, fixed.
   - Open: field borders are 1.2 to 1.5:1 in every theme, as shadcn's are, under the 3:1
     WCAG 1.4.11 asks of a field's outline. Darker borders change the look; undecided.

Then, done: `ashlar mcp`, the commands for coding agents over MCP (search, view, add,
update, check), each running what a person would run. Checked with the MCP Inspector.
