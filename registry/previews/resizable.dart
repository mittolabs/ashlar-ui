// The resizable picture ashlar update --preview draws, from the site's demo.
import 'package:flutter/widgets.dart';

import 'package:ashlar_ui_gallery/ui/resizable.dart';
import 'package:ashlar_ui_gallery/ui/theme.dart';

class ResizableDemo extends StatelessWidget {
  const ResizableDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AshlarTheme.of(context);
    Widget pane(String label) => Center(
      child: Text(label, style: t.text.sm.copyWith(fontWeight: FontWeight.w600)),
    );
    return Container(
      width: 480,
      height: 240,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: t.colors.border),
        borderRadius: BorderRadius.circular(t.radiusLg),
      ),
      child: Resizable(
        withHandle: true,
        panels: [
          ResizablePanel(size: 1, minSize: .2, child: pane('Sidebar')),
          ResizablePanel(
            size: 2,
            minSize: .3,
            child: Resizable(
              axis: Axis.vertical,
              withHandle: true,
              panels: [
                ResizablePanel(size: 1, minSize: .2, child: pane('Editor')),
                ResizablePanel(size: 1, minSize: .2, child: pane('Terminal')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
