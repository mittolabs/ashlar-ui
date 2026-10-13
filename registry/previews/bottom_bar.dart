// The bottom-bar picture ashlar update --preview draws, from the site's demo.
import 'package:ashlar_icons/ashlar_icons.dart';
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/bottom_bar.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class BottomBarDemo extends StatefulWidget {
  const BottomBarDemo({super.key});

  @override
  State<BottomBarDemo> createState() => _BottomBarDemoState();
}

class _BottomBarDemoState extends State<BottomBarDemo> {
  var page = 0;
  static const pages = ['Home', 'Search', 'Inbox', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    // A phone's screen, the bar along its foot.
    return Container(
      width: 360,
      height: 440,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: t.colors.border),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(child: Text(pages[page], style: t.text.xl)),
          ),
          BottomBar(
            index: page,
            onChanged: (i) => setState(() => page = i),
            items: const [
              BottomBarItem(label: 'Home', icon: AshlarIcon(AshlarIconsRoundedStroke.house)),
              BottomBarItem(label: 'Search', icon: AshlarIcon(AshlarIconsRoundedStroke.search)),
              BottomBarItem(label: 'Inbox', icon: AshlarIcon(AshlarIconsRoundedStroke.inbox), badge: '3'),
              BottomBarItem(label: 'Profile', icon: AshlarIcon(AshlarIconsRoundedStroke.circleUser)),
            ],
          ),
        ],
      ),
    );
  }
}
