// Ashlar UI block: api-docs. Copied into your app by `ashlar add api-docs`; it is yours
// to change. An API's documentation: its versions and a search at the top, sections that
// fold away, and a page with its steps and an example request.
//
// The API, its pages and its example are sample content, there to be replaced.

import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../ui/badge.dart';
import '../ui/breadcrumb.dart';
import '../ui/button.dart';
import '../ui/dropdown_menu.dart';
import '../ui/input.dart';
import '../ui/separator.dart';
import '../ui/sidebar.dart';
import '../ui/theme.dart';

/// The documentation's sections, each with its pages.
const _sections = [
  ('Start here', ['Your keys', 'Test and live', 'Errors']),
  (
    'Payments',
    ['Take a payment', 'Check a payment', 'Refunds', 'Payment links'],
  ),
  ('Payouts', ['Send money', 'Pay a merchant', 'Pay a bill']),
  ('Webhooks', ['Events', 'Retries', 'Verify a signature']),
  ('Libraries', ['Dart', 'Node', 'Python']),
];

/// An API's documentation, its sections folding away.
class ApiDocs extends StatefulWidget {
  const ApiDocs({super.key});

  @override
  State<ApiDocs> createState() => _ApiDocsState();
}

class _ApiDocsState extends State<ApiDocs> {
  var _page = 'Take a payment';
  var _version = 'v3';

  @override
  Widget build(BuildContext context) => SidebarLayout(
    collapse: SidebarCollapse.offcanvas,
    header: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Versions(
          version: _version,
          onChanged: (v) => setState(() => _version = v),
        ),
        const SizedBox(height: 8),
        const Input(
          placeholder: 'Search the API…',
          semanticLabel: 'Search the API',
          leading: AshlarIcon(AshlarIconsRoundedStroke.search),
        ),
      ],
    ),
    groups: [
      SidebarGroup([
        for (final (section, pages) in _sections)
          SidebarItem(
            section,
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
      SidebarGroup(atEnd: true, [
        SidebarItem(
          'Status',
          icon: AshlarIconsRoundedStroke.activity,
          badge: 'Up',
          onPressed: () {},
        ),
        SidebarItem(
          'Changelog',
          icon: AshlarIconsRoundedStroke.rotateCcwClock,
          onPressed: () {},
        ),
      ]),
    ],
    child: _Page(
      section: _sections.firstWhere((s) => s.$2.contains(_page)).$1,
      page: _page,
    ),
  );
}

/// The API's mark and name, and a menu of its versions.
class _Versions extends StatelessWidget {
  const _Versions({required this.version, required this.onChanged});

  final String version;
  final ValueChanged<String> onChanged;

  static const _versions = [
    ('v3', 'Current'),
    ('v2', 'Until June 2027'),
    ('v1', 'Retired'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return DropdownMenu(
      builder: (context, menu) => Button(
        variant: ButtonVariant.ghost,
        expand: true,
        semanticLabel: 'Paylane API, version $version',
        onPressed: menu.open,
        trailing: const AshlarIcon(AshlarIconsRoundedStroke.chevronsUpDown),
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
                AshlarIconsRoundedStroke.braces,
                color: c.sidebarPrimaryForeground,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paylane API',
                    style: t.text.sm.copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(version, style: t.text.xs),
                ],
              ),
            ),
          ],
        ),
      ),
      items: [
        for (final (v, note) in _versions)
          MenuItem(
            onPressed: () => onChanged(v),
            trailing: v == version
                ? const AshlarIcon(AshlarIconsRoundedStroke.check)
                : null,
            child: Text('$v  ·  $note'),
          ),
      ],
    );
  }
}

/// The page: where it sits along the top, then its steps and an example request.
class _Page extends StatelessWidget {
  const _Page({required this.section, required this.page});

  final String section;
  final String page;

  static const _request = """curl https://api.paylane.example/v3/payments \\
  -H "Authorization: Bearer \$PAYLANE_KEY" \\
  -d phone=+14155550123 \\
  -d amount=1350 \\
  -d reference=ORDER-1042""";

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    Widget step(int n, String title, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.border),
            ),
            child: Text('$n', style: t.text.xs),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.text.sm.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(text, style: t.text.sm.copyWith(color: c.mutedForeground)),
              ],
            ),
          ),
        ],
      ),
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
                      BreadcrumbItem(section, onPressed: () {}),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Badge(
                      variant: BadgeVariant.outline,
                      child: Text('POST /v3/payments'),
                    ),
                    const SizedBox(height: 12),
                    Text(page, style: t.text.xxl),
                    const SizedBox(height: 8),
                    Text(
                      'Ask a customer to pay from their phone. They get a prompt in their '
                      'wallet app, approve it, and you hear back on your webhook within seconds.',
                      style: t.text.base.copyWith(color: c.mutedForeground),
                    ),
                    const SizedBox(height: 24),
                    step(
                      1,
                      'Send the request',
                      'The phone number in full, the amount in cents, and your own '
                          'reference to match the payment later.',
                    ),
                    step(
                      2,
                      'The customer approves it',
                      'They have two minutes to approve it before the payment expires.',
                    ),
                    step(
                      3,
                      'Hear the result',
                      'A payment.succeeded or payment.failed event arrives on your webhook.',
                    ),
                    const SizedBox(height: 8),
                    _Code(_request),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// An example request, with a button to copy it.
class _Code extends StatelessWidget {
  const _Code(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    final c = t.colors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.muted,
        borderRadius: BorderRadius.circular(t.radiusLg),
        border: Border.all(color: c.border),
      ),
      // The copy button in a bar of its own, so the code never scrolls under it.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 4, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Request',
                    style: t.text.xs.copyWith(color: c.mutedForeground),
                  ),
                ),
                Button(
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.iconSm,
                  semanticLabel: 'Copy the request',
                  onPressed: () => Clipboard.setData(ClipboardData(text: code)),
                  child: const AshlarIcon(AshlarIconsRoundedStroke.copy),
                ),
              ],
            ),
          ),
          Container(height: 1, color: c.border),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Text(
              code,
              style: t.text.sm.copyWith(fontFamily: 'monospace', height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
