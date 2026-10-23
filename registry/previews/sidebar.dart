// The sidebar picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/avatar.dart';
import 'package:ashlar_ui_gallery/ui/sidebar.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class SidebarDemo extends StatefulWidget {
  const SidebarDemo({super.key});

  @override
  State<SidebarDemo> createState() => _SidebarDemoState();
}

class _SidebarDemoState extends State<SidebarDemo> {
  String page = 'Home';

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    SidebarItem item(String label, IconData icon, {String? badge}) => SidebarItem(
      label,
      icon: icon,
      badge: badge,
      active: page == label,
      onPressed: () => setState(() => page = label),
    );
    return Container(
      width: 800,
      height: 480,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: t.colors.border),
        borderRadius: BorderRadius.circular(t.radiusLg),
      ),
      child: SidebarLayout(
        width: 220,
        narrow: 500,
        header: Text('Acme Shop', style: t.text.sm.copyWith(fontWeight: FontWeight.w600)),
        footer: const Row(
          children: [
            Avatar(fallback: 'MT', size: 28),
            SizedBox(width: 8),
            Expanded(child: Text('Maya Thompson', maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
        groups: [
          SidebarGroup(label: 'Shop', [
            item('Home', AshlarIconsRoundedStroke.house),
            item('Orders', AshlarIconsRoundedStroke.inbox, badge: '12'),
            item('Products', AshlarIconsRoundedStroke.folder),
            item('Reports', AshlarIconsRoundedStroke.chartColumn),
          ]),
          SidebarGroup(label: 'Account', [
            item('Team', AshlarIconsRoundedStroke.users),
            item('Settings', AshlarIconsRoundedStroke.settings),
          ]),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const SidebarTrigger(),
                  const SizedBox(width: 8),
                  Text(page, style: t.text.sm.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  decoration: BoxDecoration(color: t.colors.muted, borderRadius: BorderRadius.circular(t.radiusLg)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
