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
| Components | 62 | 55 |
| Showcase situations across components | about 480 | 55 (one demo each) |
| Blocks (whole screens) | 28: 1 dashboard, 16 sidebars, 5 logins, 5 signups | 0 |
| Chart variants | 71, across area, bar, line, pie, radar, radial, tooltip | 4 kinds, no radar or radial |
| Themes | 7 base colours and 17 accent colours | neutral only |
| Visual styles (presets) | 8: Vega, Nova, Maia, Lyra, Mira, Luma, Sera, Rhea | 1 |
| Primitive bases | 3: Radix, Base UI (default since July), React Aria | Flutter's widgets layer |
| CLI commands | 15: init, add, apply, build, diff, docs, eject, info, mcp, migrate, preset, search, view, registry, dry run | 3: init, add, list |
| Right-to-left | yes, CLI converts to logical sides | yes, logical sides; tested in both directions |
| Forms | guides and examples for 3 form libraries (34 examples) | none |

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

Left from step 1, smaller: Navigation Menu's shared animated viewport between panels. Not
applicable to Flutter: Native Select, a file Input, Aspect Ratio (Flutter has it).

**Step 2, right-to-left: done** (13 October 2026, c323e30). Padding, alignment, borders
and corners are logical (start and end); arrow keys and pointing icons follow the reading
direction in Tabs, Menubar, Toggle Group, Calendar, Carousel, submenus, Pagination,
Breadcrumb, Sidebar, Slider and Resizable; submenus open towards the end of the line;
popovers align to the start edge. `gallery/test/rtl_test.dart` runs each check in both
directions. Physical on purpose: Drawer, Sheet and Toast name screen edges and corners, and
charts keep time running left to right, as their plots are drawn.

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
