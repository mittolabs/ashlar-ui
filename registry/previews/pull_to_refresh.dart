// The pull-to-refresh picture ashlar update --preview draws, from the site's demo.
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/item.dart';
import 'package:ashlar_ui_gallery/ui/pull_to_refresh.dart';
import 'package:ashlar_ui_gallery/ui/separator.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class PullToRefreshDemo extends StatefulWidget {
  const PullToRefreshDemo({super.key});

  @override
  State<PullToRefreshDemo> createState() => _PullToRefreshDemoState();
}

class _PullToRefreshDemoState extends State<PullToRefreshDemo> {
  var refreshed = 0;

  Future<void> refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    setState(() => refreshed++);
  }

  @override
  Widget build(BuildContext context) => Container(
    width: 340,
    height: 420,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      border: Border.all(color: AshlarTheme.of(context).colors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    // On this page a mouse may pull it too, so it can be tried without a touch screen.
    child: ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad},
      ),
      child: PullToRefresh(
        onRefresh: refresh,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                refreshed == 0 ? 'Pull down to refresh.' : 'Refreshed $refreshed time${refreshed == 1 ? '' : 's'}.',
              ),
            ),
            for (var i = 0; i < 12; i++) ...[
              const Separator(),
              Item(title: Text('Order #${4000 + i}'), description: const Text('Ready for delivery')),
            ],
          ],
        ),
      ),
    ),
  );
}
