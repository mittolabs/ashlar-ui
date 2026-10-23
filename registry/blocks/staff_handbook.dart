// Ashlar UI block: staff-handbook. Copied into your app by `ashlar add staff-handbook`; it
// is yours to change. A handbook to read: its chapters in a floating sidebar with a
// search, a page of plain text, and what is on the page down its other side on a wide
// screen.
//
// The school and its handbook are sample content, there to be replaced.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import '../ui/breadcrumb.dart';
import '../ui/input.dart';
import '../ui/pressable.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/theme.dart';

/// The handbook's chapters, each with its pages.
const _chapters = [
  ('Welcome', ['Our school', 'Your first week', 'Who to ask']),
  ('Teaching', ['Lesson plans', 'Marking', 'Exams', 'Reports home']),
  ('Pupils', ['Attendance', 'Discipline', 'Welfare']),
  ('Staff', ['Leave', 'Pay', 'Training']),
  ('Safety', ['Fire drill', 'First aid', 'Visitors']),
];

/// What is on the Leave page, for the contents beside it.
const _onThisPage = [
  'Annual leave',
  'Sick leave',
  'Asking for leave',
  'Who covers your classes',
];

/// A staff handbook: chapters that fold away in a floating sidebar.
class StaffHandbook extends StatefulWidget {
  const StaffHandbook({super.key});

  @override
  State<StaffHandbook> createState() => _StaffHandbookState();
}

class _StaffHandbookState extends State<StaffHandbook> {
  var _page = 'Leave';

  @override
  Widget build(BuildContext context) => SidebarLayout(
    collapse: SidebarCollapse.offcanvas,
    variant: SidebarVariant.floating,
    header: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _School(),
        SizedBox(height: 8),
        Input(
          placeholder: 'Search the handbook…',
          semanticLabel: 'Search the handbook',
          leading: AshlarIcon(AshlarIconsRoundedStroke.search),
        ),
      ],
    ),
    groups: [
      SidebarGroup([
        for (final (chapter, pages) in _chapters)
          SidebarItem(
            chapter,
            icon: null,
            initiallyOpen: pages.contains(_page),
            children: [
              for (final page in pages)
                SidebarItem(
                  page,
                  icon: null,
                  active: page == _page,
                  onPressed: () => setState(() => _page = page),
                ),
            ],
          ),
      ]),
    ],
    child: _Page(
      chapter: _chapters.firstWhere((c) => c.$2.contains(_page)).$1,
      page: _page,
    ),
  );
}

class _School extends StatelessWidget {
  const _School();

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: c.sidebarPrimary,
              borderRadius: BorderRadius.circular(t.radiusLg),
            ),
            child: AshlarIcon(
              AshlarIconsRoundedStroke.bookOpen,
              color: c.sidebarPrimaryForeground,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hillcrest Academy',
                  overflow: TextOverflow.ellipsis,
                  style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                ),
                Text('Staff handbook, 2026', style: t.text.xs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The page to read, with what is on it beside it where there is room.
class _Page extends StatelessWidget {
  const _Page({required this.chapter, required this.page});

  final String chapter;
  final String page;

  static const _sections = [
    (
      'Annual leave',
      'Teaching staff take their leave in the school holidays. Others have 21 working '
          'days a year, taken when the head of department agrees.',
    ),
    (
      'Sick leave',
      'Tell the deputy head before 7am on the first day you are away. From the third '
          'day, bring a note from a doctor or clinic.',
    ),
    (
      'Asking for leave',
      'Ask at least two weeks ahead, in the staff portal, so cover can be found. Leave for '
          'a funeral or a family emergency can be asked for on the day.',
    ),
    (
      'Who covers your classes',
      'Leave work for each lesson with the deputy head. A colleague from your department '
          'takes the class; an exam class is never left without a teacher.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    final article = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(page, style: t.text.xxl),
        const SizedBox(height: 8),
        Text(
          'Updated by the deputy head in January. Ask the office if anything here is unclear.',
          style: t.text.sm.copyWith(color: c.mutedForeground),
        ),
        for (final (title, text) in _sections) ...[
          const SizedBox(height: 24),
          Text(title, style: t.text.lg.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(text, style: t.text.base.copyWith(height: 1.6)),
        ],
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const SidebarTrigger(),
                const SizedBox(width: 8),
                const SizedBox(
                  height: 16,
                  child: Separator(axis: Axis.vertical),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Breadcrumb(
                    items: [
                      BreadcrumbItem(chapter, onPressed: () {}),
                      BreadcrumbItem(page),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Separator(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: box.maxWidth >= 900
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.topStart,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 640),
                              child: article,
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        const SizedBox(width: 200, child: _Contents()),
                      ],
                    )
                  : article,
            ),
          ),
        ),
      ],
    );
  }
}

/// What is on the page, each a link down to it.
class _Contents extends StatelessWidget {
  const _Contents();

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'On this page',
          style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        for (final (i, title) in _onThisPage.indexed)
          Pressable(
            onPressed: () {},
            semanticLabel: title,
            builder: (context, state) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                title,
                style: t.text.sm.copyWith(
                  color: i == 0 || state.hovered
                      ? c.foreground
                      : c.mutedForeground,
                  decoration: state.focused ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
